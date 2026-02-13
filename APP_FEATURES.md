# Keywords

- "Xcamp" - the name of the event
- "Chrost" - the name of the magazine/redaction being print out physically during the event

# App Global State & Navigation

## Show App Data State

- **true**: Full event data available - shows complete navigation and features
- **false**: Limited mode - shows only Home, Media, and O festivalu tabs for staying connected with users

## Dynamic Bottom Navigation

The app uses a **dynamic bottom tab system** that adapts based on event state and remote configuration:

### Limited Mode (showAppData = false)
**Tabs:** Home → Media → O festivalu

### During Active Event
**Tabs:** Home → Schedule → Speakers & Places → Media → O festivalu

### Post-Event Mode
**Tabs:** Home → Schedule → Rating → Media → O festivalu

---

# Main Navigation Tabs

## Home Tab

### Limited Mode (showAppData = false)
- Countdown to the next event
- Main info from Remote Config
- Upcoming news from Firestore
- No QR code scanner access

### Full Mode (showAppData = true)
- All of the above plus:
- **QR Code Scanner**: Header button for accessing QR scanning/display functionality, (shown only after startDate)
- News and updates during active event
- Current and nearest upcoming schedule

## Schedule Tab ("Program")
**Available only when showAppData = true**

- **8-Day Schedule**: Sobota through Sobota (Saturday to Saturday)
- **Auto-Navigation**: Automatically shows current day during event
- **Event Types**: Main, Internal, Gospel, Food - each with distinct colors
- **Favorites System**: Star/unstar events across all days
- **Smart Filtering**: Filter by event type via floating action button
- **Time-Aware Display**: Past events dimmed or hidden
- **Pull-to-Refresh**: Swipe down to refresh schedule data
- **Individual Event Details**: Tap events to see full details page

## Speakers & Places Tab ("Informace")
**Available only during active event and a while before it (if showAppData = true)**

Combined tab using a segmented picker interface to switch between:

### Speakers Sub-Tab ("Řečníci")
- **Speaker Profiles**: Masonry layout with photos and information
- **Individual Speaker Pages**: Detailed speaker information
- **Speaker Information**: Include photo, name, bio and list of his scheduled parts of program (sections)

> **See also:** [`SPEAKERS.md`](SPEAKERS.md) for complete Firestore speaker ID mapping

### Places Sub-Tab ("Místa")
- **Areal Map**: Full-screen camp areal/map image at top with QuickLook support for zoom/pan
- **Interactive Map**: Location information and details - as an image
- **Place List**: List of all camp important locations with basic information
- **Place Details**: Individual location pages with comprehensive information - name, photo, location

> **See also:** [`PLACES.md`](PLACES.md) for complete Firestore place ID mapping

## Rating Tab ("Hodnocení")
**Available only after the event ends (if showAppData = true)**

> **Important**: Rating is an **online-only feature**. It requires network connectivity and does NOT persist data locally. The feature should be hidden or disabled when offline.

- **Post-Event Feedback**: Rating and evaluation system for attendees
- **Event Rating**: Comprehensive feedback collection (via anonymous stars and comments)
- **Feedback Categories**: Harmonogram dne, Chrost, Duchovní poradenství, Svolávací znělka, Infobudka, Výzdoba stanu a modlitební místnosti, Mercy café, Ostatní

## Media Tab

### Core Media Links (always shown)
- **Photo Gallery**: External link to event photos
- **YouTube Playlist**: External link to video recordings
- **Spotify Playlist**: External link to podcast recordings
- **Apple Podcasts**: External link to podcast recordings
- **Songbook Access**: Navigation to songs collection
- **Chrost Reader**: Access to digital camp newsletter

### Additional Features (showAppData = true)
- **Photo Upload**: Upload photos to Chrost magazine
- **Message to Chrost**: Send messages to newsletter editors

### Placeholder Features (TODO) - hidden for now
- Lost and Found functionality
- Xcamp Merchandise

## O Festivalu Tab ("O festivalu")
**Always available**

- Contact information (email, phone, webpage)
- Event location with map link (Smilovice 79, 739 55)
- Organizer information (https://ks-sch.cz/)
- Social networks (Facebook, Instagram)
- Notifications settings (hidden if showAppData = false)
- Emergency pills (expandable cards for critical info - medical help, camp leaving procedures)
- Current app version display

---

# Additional Navigation Routes

## Event & Content Detail Pages
- **Section Details** (`/section`): Individual schedule event information - title, description, time, location, speaker
- **Speaker Profile** (`/speaker`): Detailed speaker biography and information and his scheduled parts of program
- **Place Details** (`/place`): Location name, photo, map link and description
- **Song Display** (`/song`): Individual song lyrics
- **Full-Screen Image** (`/image`): Image viewer with gesture support

## Interactive Features
- **QR Code Scanner/Display** (`/qr`): Scan/save your QR code
- **Photo Upload** (`/upload`): Upload photos for Chrost magazine
- **Notification Settings** (`/notifications-settings`): Granular push notification preferences

## Chrost (Newsletter) Features
- **Chrost Reader** (`/chrost/read`): Browse newsletter pages from Firebase Storage
- **Chrost Message** (`/chrost/message`): Send messages to newsletter editors

## Songbook System
- **Song List** (`/songs`): Browse and search camp songbook
- **Individual Song** (`/song`): Display song lyrics with scrolling support

---

# Remote Configuration Controls

## Feature Flags
- **showAppData**: Controls availability of main event features

## Event State Configuration
- **startDate**: Configurable event start date (default: '2026-07-18')
- **Event Over Logic**: Automatically determined as 1 week after start date
- **Auto Tab Selection**: Schedule automatically navigates to current event day

---

# Feature Implementation Details

## Songbook System

### Song List Page (`/songs`)
- Complete list of camp songs
- **Real-time Search**: Search by song name or number as you type
- **Multi-field Search**: Searches across song titles and lyrics
- **Czech Language Support**: Proper handling of Czech diacritics
- **Navigation**: Clicking song opens individual song detail page

### Song Detail Page (`/song`)
- **Full Song Display**: Complete song lyrics with proper formatting
- **Scrollable Content**: Optimized for long lyrics
- **App Bar Title**: Song title displayed in header
- **Clean Layout**: Focus on readability

## Notification Settings (`/notifications-settings`)
- **Granular Controls**: Individual toggles for different notification types
- **Default State**: All notifications enabled by default (if user accepts system prompt)
- **User Choice**: Users can selectively disable specific notification categories

## Chrost Reader (`/chrost/read`)
- **Digital Newsletter**: Browse Chrost magazine pages
- **Firebase Storage Integration**: Images loaded from cloud storage
- **Caching System**: Pages cached locally for offline viewing
- **Lazy Loading**: Pages loaded one by one for performance
- **Image Optimization**: Compressed images for faster loading

## Upload System (`/upload`)
- **Multi-Photo Selection**: Select and upload multiple photos simultaneously
- **Progress Tracking**: Real-time upload progress indicators
- **User Organization**: Separate tabs for uploading new photos and viewing your uploaded photos
- **Error Handling**: Graceful failure handling with retry options
- **Firebase Storage**: Secure cloud storage with user-based folders

## QR Code System (`/qr`)
- **Initialization**: Scans your QR code after registering at event and saves it locally
- **Camera Permissions**: Graceful handling with instructions if denied
- **Brightness Control**: Auto-adjusts screen brightness when displaying QR code
- **Data Persistence**: QR data stored locally with platform-specific key-value storage
- **Admin Reset**: Hidden admin pin can reset stored QR data
- **Offline Operation**: Full functionality without internet connection

---

# Data Synchronization & Firebase Fetching Patterns

## App Startup Sequence
1. **Firebase Core**: Initialize Firebase, Auth (anonymous), Remote Config, Crashlytics
2. **SQLDelight**: Open local SQLite database for offline storage
3. **Cleanup Check**: Optional SQLDelight data cleanup without app restart

## Data Loading Patterns

### On App Start
- **Immediate**: Remote Config values (cached, fast access)
- **Deferred**: All collection data loaded only when UI components need them

### Lazy Loading by UI Component
- **Home Tab**: News collection (loaded on first access)
- **Schedule Tab**: Schedule sections (loaded on first access)
- **Speakers Sub-Tab**: Speakers collection (loaded on first access)
- **Places Sub-Tab**: Places collection (loaded on first access)
- **Songs Tab**: Songs collection (loaded on first access)

### Loading Strategy
1. **Check Local Cache**: Query SQLDelight first (instant if data exists)
2. **Firebase Sync**: If cache empty or needs refresh → Firestore query with 5-second timeout
3. **Data Validation**: Filter invalid documents, convert to domain models
4. **Batch Storage**: Store valid data in SQLDelight for offline access
5. **UI Update**: Notify listeners → update UI state

### Performance Optimizations
- **Timeout Protection**: 5-second max for Firestore queries
- **Selective Rebuilds**: UI observers prevent unnecessary rebuilds
- **Async Loading**: Async queries for all SQLDelight operations to prevent UI blocking
- **Error Recovery**: Graceful degradation - continue with cached data if sync fails

### Collection-Specific Patterns
- **News**: Auto-loads on Home tab, filters by visibility dates
- **Schedule**: Large dataset (~200 sessions), loads all at once, cached locally
- **Speakers**: Medium dataset (~20 speakers), includes Firebase Storage image URLs
- **Places**: Small dataset (~10 locations), includes GPS coordinates
- **Songs**: Medium dataset (~30 songs), text-heavy content with numbering

---

# App State Management

## Event Timeline States

### Pre-Event (showAppData = false)
- **Purpose**: Keep users engaged before event data is available
- **Features**: Countdown, news, media links, contact info
- **Tabs**: Home, Media, O festivalu only

### Active Event (showAppData = true, event ongoing)
- **Purpose**: Full camp management and information system
- **Features**: Complete schedule, speakers, places, live updates
- **Tabs**: Home, Schedule, Speakers & Places, Media, O festivalu

### Post-Event (showAppData = true, event ended)
- **Purpose**: Feedback collection and media access
- **Features**: Event rating, media access, schedule review
- **Tabs**: Home, Schedule, Rating, Media, O festivalu
