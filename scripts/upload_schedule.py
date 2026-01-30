#!/usr/bin/env python3
"""
Schedule Upload Script for XcamP

Uploads schedule entries from JSON files to Firestore.
Each entry gets a unique UUID v4 as document ID.
Multi-day entries use a single document with a days array.
"""

import json
import os
import sys
import uuid
from pathlib import Path
from typing import Any, List

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("Error: firebase-admin not installed. Run: pip install -r requirements.txt")
    sys.exit(1)

# Configuration
START_DATE = "2026-07-18"
COLLECTION_NAME = "schedule"
SCHEDULE_DATA_DIR = Path(__file__).parent.parent / "schedule_data"
CREDENTIALS_PATH = Path(__file__).parent / "firebase-credentials.json"

# Valid type values matching SectionType enum (lowercase for Firestore)
VALID_TYPES = {"main", "internal", "gospel", "food"}

# Required fields for each entry
REQUIRED_FIELDS = {"name", "days", "startTime", "endTime", "type"}


def generate_uid() -> str:
    """Generate a UUID v4 as string."""
    return str(uuid.uuid4())


def validate_uuid_format(uuid_str: str) -> bool:
    """Validate if a string is a valid UUID v4 format."""
    try:
        uuid_obj = uuid.UUID(uuid_str)
        return uuid_obj.version == 4
    except (ValueError, AttributeError):
        return False


def validate_time_format(time_str: str) -> bool:
    """Validate HH:MM time format."""
    try:
        parts = time_str.split(":")
        if len(parts) != 2:
            return False
        hour, minute = int(parts[0]), int(parts[1])
        return 0 <= hour <= 23 and 0 <= minute <= 59
    except (ValueError, AttributeError):
        return False


def validate_entry(entry: dict[str, Any], filename: str) -> tuple[bool, str]:
    """
    Validate a schedule entry.

    Returns (is_valid, error_message)
    """
    # Check required fields
    missing_fields = REQUIRED_FIELDS - entry.keys()
    if missing_fields:
        return False, f"Missing required fields: {missing_fields}"

    # Validate type
    if entry["type"] not in VALID_TYPES:
        return False, f"Invalid type '{entry['type']}'. Must be one of: {VALID_TYPES}"

    # Validate time format
    if not validate_time_format(entry["startTime"]):
        return False, f"Invalid startTime format '{entry['startTime']}'. Expected HH:MM"

    if not validate_time_format(entry["endTime"]):
        return False, f"Invalid endTime format '{entry['endTime']}'. Expected HH:MM"

    # Validate days
    if not isinstance(entry["days"], list) or not entry["days"]:
        return False, "days must be a non-empty array of integers"

    if not all(isinstance(d, int) for d in entry["days"]):
        return False, "All values in days array must be integers"

    # Validate optional fields
    if "place" in entry and not isinstance(entry["place"], str):
        return False, "place must be a string"

    if "speakers" in entry:
        if not isinstance(entry["speakers"], list):
            return False, "speakers must be an array of speaker IDs"
        if not all(isinstance(s, str) for s in entry["speakers"]):
            return False, "All speaker IDs must be strings"

    if "leader" in entry and not isinstance(entry["leader"], str):
        return False, "leader must be a string"

    if "description" in entry and not isinstance(entry["description"], str):
        return False, "description must be a string"

    # Validate optional 'id' field
    if "id" in entry:
        if not isinstance(entry["id"], str):
            return False, "id must be a string"
        if not validate_uuid_format(entry["id"]):
            return False, f"Invalid UUID v4 format for 'id': '{entry['id']}'. Expected format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

    return True, ""


def load_json_files() -> List[dict[str, Any]]:
    """Load all JSON files from schedule_data directory."""
    entries = []

    if not SCHEDULE_DATA_DIR.exists():
        print(f"Error: Directory '{SCHEDULE_DATA_DIR}' not found.")
        print(f"Please create it and add JSON files with schedule data.")
        sys.exit(1)

    json_files = list(SCHEDULE_DATA_DIR.glob("*.json"))

    if not json_files:
        print(f"Error: No JSON files found in '{SCHEDULE_DATA_DIR}'")
        sys.exit(1)

    for json_file in json_files:
        print(f"Loading {json_file.name}...")

        try:
            with open(json_file, "r", encoding="utf-8") as f:
                file_entries = json.load(f)

            if not isinstance(file_entries, list):
                print(f"Warning: {json_file.name} does not contain a JSON array. Skipping.")
                continue

            for idx, entry in enumerate(file_entries):
                is_valid, error_msg = validate_entry(entry, json_file.name)

                if not is_valid:
                    print(f"  Warning: Entry {idx + 1} validation failed: {error_msg}. Skipping.")
                    continue

                entries.append(entry)

            print(f"  Loaded {len(file_entries)} entries from {json_file.name}")

        except json.JSONDecodeError as e:
            print(f"Error: Failed to parse {json_file.name}: {e}")
            continue
        except Exception as e:
            print(f"Error reading {json_file.name}: {e}")
            continue

    return entries


def initialize_firebase() -> firestore.Client:
    """Initialize Firebase Admin SDK."""
    # Check if already initialized
    if firebase_admin._apps:
        return firestore.client()

    # Try to load credentials
    cred = None

    if CREDENTIALS_PATH.exists():
        # Use local credentials file
        cred = credentials.Certificate(str(CREDENTIALS_PATH))
        firebase_admin.initialize_app(cred)
        print(f"Using credentials from {CREDENTIALS_PATH}")
    elif os.environ.get("GOOGLE_APPLICATION_CREDENTIALS"):
        # Use environment variable
        cred = credentials.Certificate(os.environ["GOOGLE_APPLICATION_CREDENTIALS"])
        firebase_admin.initialize_app(cred)
        print(f"Using credentials from GOOGLE_APPLICATION_CREDENTIALS")
    else:
        print("Error: Firebase credentials not found.")
        print("Either:")
        print(f"1. Place a service account JSON file at {CREDENTIALS_PATH}")
        print("2. Set GOOGLE_APPLICATION_CREDENTIALS environment variable")
        sys.exit(1)

    return firestore.client()


def upload_entries(db: firestore.Client, entries: List[dict[str, Any]]) -> int:
    """Upload entries to Firestore in batches."""
    if not entries:
        print("No entries to upload.")
        return 0

    collection = db.collection(COLLECTION_NAME)
    uploaded = 0
    failed = 0
    auto_generated = 0
    stable_ids = 0

    # Firestore batch size limit is 500
    batch_size = 500

    for i in range(0, len(entries), batch_size):
        batch = db.batch()
        batch_entries = entries[i:i + batch_size]

        for entry in batch_entries:
            # Use provided 'id' or generate UID
            uid = entry.get("id") or generate_uid()

            # Track statistics
            if "id" in entry:
                stable_ids += 1
            else:
                auto_generated += 1

            # Create document reference with UID as document ID
            doc_ref = collection.document(uid)

            # Prepare document data
            doc_data = {
                "uid": uid,
                "name": entry["name"],
                "days": entry["days"],
                "startTime": entry["startTime"],
                "endTime": entry["endTime"],
                "type": entry["type"],
            }

            # Add optional fields (excluding 'id' which is used as document ID)
            for key in ["place", "speakers", "leader", "description"]:
                if key in entry:
                    doc_data[key] = entry[key]

            # Add to batch
            batch.set(doc_ref, doc_data)

        try:
            batch.commit()
            uploaded += len(batch_entries)
            print(f"Uploaded batch {i // batch_size + 1}: {len(batch_entries)} entries")
        except Exception as e:
            print(f"Error uploading batch: {e}")
            failed += len(batch_entries)

    print()
    print("Document ID Summary:")
    print(f"  Stable IDs (from JSON): {stable_ids}")
    print(f"  Auto-generated IDs: {auto_generated}")
    print(f"  Total: {uploaded}")

    return uploaded


def main():
    """Main function to upload schedule data."""
    print("=" * 60)
    print("XcamP Schedule Upload Script")
    print("=" * 60)
    print()

    # Load and validate entries
    print("Loading schedule entries from JSON files...")
    entries = load_json_files()
    print(f"\nTotal valid entries: {len(entries)}")

    if not entries:
        print("No valid entries to upload. Exiting.")
        return

    # Initialize Firebase
    print("\nInitializing Firebase...")
    db = initialize_firebase()

    # Upload entries
    print(f"\nUploading to Firestore collection '{COLLECTION_NAME}'...")
    uploaded = upload_entries(db, entries)

    print()
    print("=" * 60)
    if uploaded > 0:
        print(f"Successfully uploaded {uploaded} entries!")
    else:
        print("Upload failed. Check errors above.")
    print("=" * 60)


if __name__ == "__main__":
    main()
