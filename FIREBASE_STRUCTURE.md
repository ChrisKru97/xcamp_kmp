# XcamP Firebase Structure Documentation

## Overview
This document outlines the complete Firebase structure for the XcamP Flutter application, including Firestore collections and Firebase Storage organization.

**Project ID:** `xcamp-dea26`

---

## Firestore Database

### Collections Overview
The database contains collections serving different aspects of the camp management system. Some collections are deleted after events finish to clean up data.

#### Active Collections (Persistent)
| Collection | Purpose | Document Count | Status |
|------------|---------|----------------|--------|
| `chrost` | Anonymous messaging system | Multiple | Active |
| `feedback` | User feedback for camp improvements | Multiple | Active |
| `info` | App configuration and contact information | 1 | Active |
| `merch` | Merchandise catalog | Multiple | Active |
| `notifications` | User notification preferences | Multiple | Active |
| `places` | Camp location data with GPS coordinates | Multiple | Active |
| `rating` | Event/content ratings by users | Multiple | Active |
| `songs` | Song lyrics with numbering | Multiple | Active |
| `speakers` | Speaker profiles and information | Multiple | Active |
| `textRating` | Textual feedback for specific events | Multiple | Active |
| `users` | User device information and FCM tokens | Multiple | Active |

#### Deleted Collections (Post-Event Cleanup)
| Collection | Purpose | Document Count | Status |
|------------|---------|----------------|--------|
| `schedule` | Complete event schedule and sessions | 200+ | Deleted after event |
| `groupLeaders` | Group leader information and portraits | 50+ | Deleted after event |
| `news` | Event announcements and news updates | Multiple | Deleted after event |

---

## Detailed Collection Schemas

### Active Collections

#### 1. `chrost` Collection
Anonymous messaging system for camp participants.

**Document Structure:**
```json
{
  "createdAt": "2025-07-19T20:27:15.645Z",
  "messages": "[Message content array as string]",
  "updatedAt": "2025-07-21T16:33:50.698Z"  // Optional
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** Real-time anonymous communication between participants

#### 2. `feedback` Collection
Feedback collection for camp improvements and suggestions.

**Document Structure:**
```json
{
  "2025": "Feedback text for year 2025"
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** Annual feedback collection, keyed by year

#### 3. `info` Collection
Central configuration and contact information for the app.

**Document Structure:**
```json
{
  "facebook": "https://www.facebook.com/festivalXcamP/",
  "instagram": "https://www.instagram.com/festivalxcamp/",
  "website": "https://www.xcamp.cz",
  "mail": "info@xcamp.cz",
  "phone": "+420732378740",
  "address": "Smilovice 79",
  "registration": "https://www.xcamp.cz/registrace/",
  "health": "Health information text",
  "leave": "Camp leaving policy text",
  "main": "Main announcement text"
}
```

**Document ID:** Fixed ID `R6EC4NE2HMrmkMXbdxie`  
**Usage:** App-wide configuration, contact info, policies

#### 4. `merch` Collection
Merchandise catalog for camp store.

**Document Structure:**
```json
{
  "name": "Product name",
  "price": 100,
  "image": "merch/product_image.jpg"  // Firebase Storage reference
}
```

**Document ID:** Auto-generated Firestore ID  
**Usage:** E-commerce functionality for camp merchandise

#### 5. `notifications` Collection
User notification preferences and settings.

**Document Structure:**
```json
{
  "internal": false,
  "gospel": false
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** FCM notification targeting and user preferences

#### 6. `places` Collection
Camp location data with GPS coordinates and descriptions.

**Document Structure:**
```json
{
  "name": "Location name",
  "description": "Location description text",
  "latitude": 49.661596,
  "longitude": 18.575048,
  "priority": 3,
  "image": "places/location_image.jpg"  // Optional, Firebase Storage reference
}
```

**Document ID:** Auto-generated Firestore ID
**Usage:** Interactive camp map, location finder, navigation

> **See also:** [`PLACES.md`](../PLACES.md) for complete name → ID mapping

#### 7. `rating` Collection
Numeric ratings for events, sessions, or content.

**Document Structure:**
```json
{
  "createdAt": "2025-07-21T16:06:58.128Z",
  "updatedAt": "2025-07-21T16:07:26.010Z",
  "EVENT_ID_1": 5,      // Rating 1-5
  "EVENT_ID_2": 3.5,    // Rating 1-5
  "EVENT_ID_N": 4       // Multiple event ratings per user
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** Event feedback system, analytics, quality tracking

#### 8. `songs` Collection
Song lyrics database with numbering system.

**Document Structure:**
```json
{
  "name": "Song title",
  "number": 24,
  "text": "Complete song lyrics with verses and choruses"
}
```

**Document ID:** Auto-generated Firestore ID  
**Usage:** Digital songbook, worship sessions, group singing

#### 9. `speakers` Collection
Speaker profiles and biographical information.

**Document Structure:**
```json
{
  "name": "Speaker name",
  "description": "Biographical text and background",
  "priority": 4,
  "image": "speakers/speaker_image.jpg",  // Firebase Storage reference
  "id": "DOCUMENT_ID"  // Self-referencing ID
}
```

**Document ID:** Auto-generated Firestore ID
**Usage:** Speaker profiles, session information, about pages

> **See also:** [`SPEAKERS.md`](../SPEAKERS.md) for complete name → ID mapping

#### 10. `textRating` Collection
Textual feedback for specific events or sessions.

**Document Structure:**
```json
{
  "createdAt": "2025-07-23T16:37:37.328Z",
  "EVENT_ID": "[Feedback text in brackets]",
  "updatedAt": "2025-07-27T16:09:01.185Z"  // Optional
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** Qualitative feedback collection, event improvement

#### 11. `users` Collection
Device information and FCM tokens for push notifications.

**Document Structure:**
```json
{
  "id": "USER_AUTH_UID",
  "brand": "samsung",
  "manufacturer": "samsung", 
  "model": "SM-N975F",
  "product": "d2seea",
  "board": "exynos9825",
  "system": "SP1A.210812.016.N975FXXS9HWHA",
  "serialNumber": "unknown",
  "token": "FCM_TOKEN_STRING",
  "createdAt": "2024-07-10T22:58:51.869Z",
  "name": "localhost",    // Optional - iOS devices
  "vendor": "UUID"        // Optional - iOS devices
}
```

**Document ID:** User Firebase Auth UID  
**Usage:** Push notification delivery, device analytics, user management

### Deleted Collections (Event-Specific)

#### 12. `schedule` Collection ⚠️ DELETED POST-EVENT
Complete event schedule including all sessions, workshops, meals, and activities.

**Document Structure (New Format - 2026+):**
```json
{
  "uid": "UUID-V4-DOCUMENT-ID",
  "name": "Event name",
  "description": "Event description with details",
  "days": [21, 22],
  "startTime": "14:00",
  "endTime": "16:00",
  "type": "main",
  "place": "PLACE_ID",
  "speakers": ["SPEAKER_ID"],
  "leader": "Leader name",
  "favorite": false
}
```

**Multi-Day Events (New Syntax):**

Multi-day events are stored as **SINGLE** documents with a `days` array. The client app expands these at runtime for display.

**Example - Two-Day Workshop:**
```json
{
  "uid": "a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d",
  "name": "Umění knihařství: Ruční šití notesů",
  "days": [21, 22],
  "startTime": "12:00",
  "endTime": "13:45",
  "type": "main",
  "leader": "Karin Krutsche",
  "place": "elqXMvc9fP9b7vG016UJ"
}
```

**Field Details:**
- `uid`: UUID v4 as document ID (auto-generated on upload)
- `days`: Array of day numbers within the event month (e.g., `[21, 22]` for July 21-22)
- `startTime`/`endTime`: Time strings in `HH:MM` format (not full timestamps)
- Client app expands multi-day entries into individual day instances for display

**Date Base:** Uses Firebase Remote Config `startDate` (default: `2026-07-18`)

**Event Types:**
- `main` - Main sessions and teaching
- `internal` - Internal/attendants meetings
- `gospel` - Gospel sessions and evangelistic meetings
- `food` - Meal times
- `basic` - Deprecated, same as `main`

**Document ID:** UUID v4 (generated by upload script)
**Usage:** Complete camp schedule system, personal planning, notifications

**Upload Script:** See `schedule_data/README.md` for JSON format and upload instructions.

#### 13. `groupLeaders` Collection ⚠️ DELETED POST-EVENT
Group leader profiles with contact information and portraits.

**Document Structure:**
```json
{
  "name": "Leader name",
  "number": 12,                    // Group number
  "portrait": "leaders/portrait.jpg", // Firebase Storage reference
  "congregation": "Church name"     // Optional affiliation
}
```

**Document ID:** Auto-generated Firestore ID  
**Usage:** Group management, contact directory, group assignments

#### 14. `news` Collection ⚠️ DELETED POST-EVENT  
Event announcements, updates, and real-time communications.

**Document Structure:**
```json
{
  "title": "Announcement title",
  "text": "Full announcement text content",
  "time": "2025-07-20T10:00:00.000Z"
}
```

**Document ID:** Auto-generated Firestore ID  
**Usage:** Push notifications, in-app announcements, camp communication

---

## Firebase Storage

### Current Status
- **Root Directory:** Empty (files deleted post-event or in different bucket)
- **Expected Structure:** Based on Firestore references and backup data

### Storage Structure (Pre-Deletion)

```
/
├── speakers/
│   ├── boleslav_taska.jpg
│   ├── ales_hejlek.jpg  
│   ├── sue_barlow.jpeg
│   ├── marie_szymeczek.jpg
│   └── steve_barlow.jpeg
├── places/
│   ├── areal.jpg           # Areal/camp map hero image
│   ├── stanky_infobudka.jpg
│   ├── infobudka.jpg
│   ├── IMG_6428.jpeg
│   └── alternativa.jpg
├── merch/
│   └── propiska.jpg
└── leaders/          // Deleted with groupLeaders collection
    ├── leader1.jpg
    ├── leader2.jpg
    └── ...
```

### Storage Usage Patterns
- **Speakers:** Profile photos for bio pages - Persistent
- **Places:** Location photos for map/navigation - Persistent  
- **Merch:** Product images for store - Persistent
- **Leaders:** Group leader portraits - Deleted post-event

**Note:** Storage appears to be cleaned up after events, consistent with the post-event data cleanup strategy.

---

## Data Relationships

### User-Centric Collections
- `users` ↔ `notifications` (1:1 by Auth UID)
- `users` ↔ `rating` (1:1 by Auth UID)
- `users` ↔ `textRating` (1:1 by Auth UID)
- `users` ↔ `feedback` (1:1 by Auth UID)
- `users` ↔ `chrost` (1:1 by Auth UID)

### Reference Collections
- `info` → App-wide configuration (singleton)
- `places` → GPS locations with Storage image refs
- `speakers` → Speaker profiles with Storage image refs
- `songs` → Numbered song lyrics
- `merch` → Products with Storage image refs

### Event-Specific Relationships (When Active)
- `schedule` → `places` (via place field reference)
- `schedule` → `speakers` (via speakers array references)
- `groupLeaders` → Firebase Storage (leaders/ directory)
- `rating` & `textRating` → `schedule` (via event IDs as field names)

### Rating System
- `rating` → Numeric ratings (1-5 scale)
- `textRating` → Textual feedback
- Both keyed by user Auth UID and event/content IDs

---

## App Architecture Integration

### Flutter Provider Classes
```dart
// Persistent providers
SpeakersProvider     // speakers collection
SongsProvider        // songs collection  
PlacesProvider       // places collection
NotificationsProvider // notifications + users collections

// Event-specific providers (when collections exist)
ScheduleProvider     // schedule collection
GroupLeadersProvider // groupLeaders collection  
NewsProvider         // news collection
```

### Data Sync Strategy
- **Offline-First:** All data cached in ObjectBox local database
- **5-Second Timeouts:** All Firestore operations have timeout protection
- **Graceful Degradation:** Falls back to local cache on sync failures
- **Selective Sync:** Providers sync only relevant data subsets

### Security & Access Patterns

#### Firestore Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-specific data
    match /{collection}/{userId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == userId
        && collection in ['chrost', 'feedback', 'notifications', 'rating', 'textRating'];
    }
    
    // Public read-only data
    match /{collection}/{document} {
      allow read: if request.auth != null
        && collection in ['info', 'places', 'speakers', 'songs', 'merch'];
      allow write: if request.auth != null && hasRole('admin');
    }
    
    // Event-specific data (when active)
    match /{collection}/{document} {
      allow read: if request.auth != null
        && collection in ['schedule', 'groupLeaders', 'news'];
      allow write: if request.auth != null && hasRole('admin');
    }
  }
}
```

---

## Data Lifecycle Management

### Pre-Event Phase
1. **Setup Collections:** Create `schedule`, `groupLeaders`, `news`  
2. **Populate Content:** Load speakers, places, songs, schedule data
3. **Configure Info:** Update contact info, policies, announcements

### During Event Phase  
1. **Active Sync:** All collections active and syncing
2. **User Interaction:** Ratings, feedback, chrost messages flowing
3. **Real-time Updates:** News and schedule changes pushed live

### Post-Event Phase
1. **Data Preservation:** Export `rating`, `textRating`, `feedback` for analysis
2. **Cleanup Collections:** Delete `schedule`, `groupLeaders`, `news`
3. **Storage Cleanup:** Remove event-specific images (leaders/ directory)
4. **Archive Preparation:** Backup event data to scripts/ directory

### Backup Strategy
Event data preserved in `scripts/` directory as JSON:
- `scripts/schedule/backup.json` - Complete schedule export
- `scripts/schedule/workshops.json` - Workshop-specific data  
- `scripts/schedule/seminars.json` - Seminar-specific data
- `scripts/schedule/gospel.json` - Gospel session data
- `scripts/speakers/speakers.json` - Speaker profiles
- `scripts/group-leaders/data.json` - Group leader information

---

## Usage Analytics & Performance

### Collection Activity Levels
**High Volume Collections:**
- `users` - Device registrations and FCM tokens
- `rating` - Continuous user feedback during events
- `textRating` - Qualitative feedback collection
- `schedule` (when active) - Most accessed during events

**Medium Volume Collections:**  
- `chrost` - Anonymous messaging platform
- `feedback` - Annual feedback surveys
- `places` - Location lookups and navigation
- `speakers` - Profile browsing
- `songs` - Digital songbook usage

**Low Volume Collections:**
- `notifications` - Preference settings (set once)
- `merch` - Product browsing 
- `info` - Configuration reads
- `news` (when active) - Administrative announcements

### Performance Optimizations
- **ObjectBox Integration:** Local-first data access
- **Selective Listeners:** Providers use targeted queries
- **Image Caching:** Firebase Storage URLs cached locally
- **Timeout Protection:** All operations limited to 5 seconds
- **Error Handling:** Comprehensive Firebase Crashlytics integration

---

## Maintenance & Monitoring

### Health Checks
- Monitor collection document counts
- Track sync failure rates via Crashlytics  
- Verify FCM token validity in `users` collection
- Check image reference integrity between Firestore and Storage

### Regular Maintenance
- **Annual:** Create new year keys in `feedback` collection
- **Post-Event:** Execute data cleanup procedures
- **Pre-Event:** Restore event collections from backup data
- **Quarterly:** Review and update Firebase security rules

### Troubleshooting
- **Empty Storage:** Expected post-event, files moved to CDN or deleted
- **Missing Collections:** Check event phase - some collections temporary
- **Sync Failures:** Firestore operations timeout after 5 seconds
- **Rating Mismatches:** Event IDs in ratings may reference deleted schedule items

---

*Last Updated: August 14, 2025*  
*Firebase Project: xcamp-dea26*  
*Event Data Status: Post-2025 Event Cleanup Complete*