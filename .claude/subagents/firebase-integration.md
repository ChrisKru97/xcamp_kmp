# Firebase Integration Subagent

Specialized guidance for Firebase integration in the XcamP KMP project.

## Trigger Keywords
Firebase, Firestore, Storage, Remote Config, Auth

## Firebase Project Configuration
- **Project ID**: `xcamp-dea26`
- **SDK**: Firebase GitLive SDK 2.3.0 (Multiplatform)

## Services Overview

### Authentication
- **Method**: Anonymous auth on app start
- **Implementation**: `XcampApp.kt` initializes Firebase and performs anonymous auth
- **Purpose**: Enables personalized features and data access

### Firestore Database
- **Timeout**: All queries protected with 5-second timeout
- **Collections**: See "Collections Structure" below
- **Operations**: Use Repository pattern with `Result<T>` return types

### Firebase Storage
- **Photo Uploads**: User photos, speaker/place images
- **Organization**: Structured paths for different content types
- **Progress Tracking**: Real-time upload indicators

### Remote Config
- **Feature Flags**: Controls app functionality and state
- **Key Parameters**:
  - `showAppData` (Boolean) - Controls event features
  - `startDate` (String) - Event start date (default: '2026-07-18')
- **App State**: Determined by `showAppData` + current date vs `startDate`

### Analytics & Crashlytics
- **Analytics**: Track user behavior and feature usage
- **Crashlytics**: Error monitoring and debugging
- **Logging**: Comprehensive logging for production issues

## Collections Structure

### Persistent Collections (never deleted)
- `chrost` - Camp newsletter content
- `feedback` - User feedback submissions
- `info` - General information pages
- `places` - Location/venue information
- `rating` - Event ratings
- `songs` - Songbook entries
- `speakers` - Speaker profiles
- `textRating` - Text-based ratings
- `users` - User data and profiles
- `notifications` - Push notification history
- `merch` - Merchandise items

### Event-Specific Collections (deleted post-event)
- `schedule` - Event schedule/sections
- `news` - Event news and updates

## 5-Second Timeout Pattern

**All network operations must include timeout protection:**

```kotlin
withTimeout(5_000) {
    // Firebase operation
    firestore.get(collection).first()
}
```

## Implementation Patterns

### Repository Pattern
```kotlin
class ExampleRepository(
    private val firestore: Firestore
) {
    suspend fun getData(): Result<Data> = try {
        withTimeout(5_000) {
            val data = firestore.collection("example")
                .get()
                .first()
            Result.success(data)
        }
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### Offline-First Sync
1. Read from local SQLite first
2. Fetch from Firebase with timeout
3. Update local database on success
4. Handle errors gracefully with `Result<T>`

## Remote Config Usage

### App State Logic
- **Limited Mode**: `showAppData = false` → Home, Media, Info tabs
- **Active Event**: `showAppData = true` + during event dates → Full tabs
- **Post-Event**: `showAppData = true` + after event → Schedule, Rating tabs

### Access Pattern
```kotlin
val showAppData = remoteConfig.getBoolean("showAppData")
val startDate = remoteConfig.getString("startDate")
```

## Firebase KMP SDK (GitLive 2.3.0)

The GitLive SDK provides multiplatform Firebase services. Key considerations:
- Use coroutines for async operations (`first()`, `collect()`)
- Follow GitLive patterns for Firestore queries
- Handle platform-specific differences via expect/actual

## Security Rules Reference
- Anonymous auth required for reads
- Write validation based on user claims
- Storage rules enforce proper content types
