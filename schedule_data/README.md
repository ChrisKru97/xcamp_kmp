# Schedule Data Upload

This directory contains JSON files with schedule entries for XcamP. The entries are uploaded to Firestore using the `upload_schedule.py` script.

## File Structure

| File | Description |
|------|-------------|
| `food.json` | Meal times (breakfast, lunch, dinner) |
| `gospel.json` | Gospel sessions and evangelistic meetings |
| `prayers.json` | Prayer meetings |
| `night.json` | Evening programs and entertainment |
| `seminars.json` | Teaching sessions and lectures |
| `workshops.json` | Interactive workshops and activities |

## JSON Entry Format

Each JSON file contains an array of schedule entries:

```json
[
  {
    "name": "Umění knihařství: Ruční šití notesů*",
    "days": [21, 22],
    "startTime": "12:00",
    "endTime": "13:45",
    "type": "main",
    "leader": "Karin Krutsche",
    "description": "*Jedná se o dvojdílní workshop",
    "place": "elqXMvc9fP9b7vG016UJ"
  },
  {
    "name": "Moje zkušenost se závislostí",
    "days": [21],
    "startTime": "09:00",
    "endTime": "10:30",
    "speakers": ["3h7pexmzcg1AWQIpQ3p5"],
    "type": "main"
  }
]
```

## Field Specifications

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Event name |
| `days` | array[int] | Yes | Day numbers in event month (e.g., `[21, 22]` for July 21-22) |
| `startTime` | string | Yes | Start time in `HH:MM` format |
| `endTime` | string | Yes | End time in `HH:MM` format |
| `type` | string | Yes | Event type (see values below) |
| `place` | string | No | Place ID from `PLACES.md` |
| `speakers` | array[string] | No | Array of speaker IDs from `SPEAKERS.md` |
| `leader` | string | No | Leader name (for workshops) |
| `description` | string | No | Event description |

## Type Values

Must match the `SectionType` enum in the Kotlin code:

- `main` - Main sessions and teaching
- `internal` - Internal/staff meetings
- `gospel` - Gospel sessions and evangelistic meetings
- `food` - Meal times

## Multi-Day Events

Multi-day events are stored as **single** Firestore documents with a `days` array. The Kotlin app expands these at runtime for display.

Example:
```json
{
  "name": "Dvojdílní workshop",
  "days": [21, 22],
  "startTime": "14:00",
  "endTime": "16:00",
  "type": "main"
}
```

This creates one document that appears on both July 21 and July 22 in the app.

## Referencing Places and Speakers

- **Places**: Use the document ID from `PLACES.md` (e.g., `"elqXMvc9fP9b7vG016UJ"` for "Hospodářská budova")
- **Speakers**: Use the document ID from `SPEAKERS.md` (e.g., `"3h7pexmzcg1AWQIpQ3p5"` for "Aleš Hejlek")

## Upload Script

### Prerequisites

```bash
# Install dependencies
pip install -r ../scripts/requirements.txt
```

### Firebase Credentials

The script requires Firebase Admin SDK credentials. Either:

1. Place a service account JSON file at `../scripts/firebase-credentials.json`
2. Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable

### Running the Upload

```bash
cd ../scripts
python upload_schedule.py
```

The script will:
1. Load all JSON files from `schedule_data/`
2. Validate each entry (required fields, time format, type values)
3. Generate a UUID v4 for each entry as the document ID
4. Upload to Firestore in batches of 500

## Date Base

The app uses Firebase Remote Config `startDate` (default: `2026-07-18`) as the base date. The `days` array contains day numbers within the event month.

For example, if `startDate` is `2026-07-18`:
- Day 18 = July 18 (first day)
- Day 21 = July 21 (fourth day)
- Day 27 = July 27 (tenth day)
