# Progress: firestore

Started: Mon Jan 19 15:14:36 CET 2026

## Status

IN_PROGRESS

## Analysis

### Current State

**What Exists:**
1. **Shared Module Firebase Setup** (Fully implemented in commonMain):
   - `FirestoreService.kt` - Generic CRUD operations with 5-second timeout
   - `AuthService.kt` - Anonymous authentication
   - `StorageService.kt` - File operations
   - `RemoteConfigService.kt` - App configuration
   - Firebase GitLive SDK 2.4.0 configured in `libs.versions.toml`
   - Repositories: `SpeakersRepository`, `PlacesRepository` with `BaseRepository` pattern
   - Services: `SpeakersService`, `PlacesService` with `refresh()` methods
   - Data models: `Speaker`, `Place` with proper serialization

2. **iOS App Setup** (Partially configured):
   - `XcampApp.swift` - Has `FirebaseApp.configure()` call
   - `AppViewModel.swift` - Background sync for places and speakers implemented
   - `GoogleService-Info.plist` - Firebase configuration file present
   - Xcode project has Firebase SDK dependencies via SPM (firebase-ios-sdk)
   - SwiftUI views: `SpeakersView`, `PlacesView` with loading states

3. **Repository Pattern** (Working):
   - `syncFromFirestore()` method in `BaseRepository`
   - `getAllSpeakers()`, `getAllPlaces()` from SQLite
   - `refreshSpeakers()`, `refreshPlaces()` sync from Firestore then return local data

### What's Missing

**Critical Issue - iOS Firebase Integration:**
1. **No iOS-specific Firebase implementation** in `iosMain/kotlin/`:
   - GitLive Firebase SDK requires platform-specific implementations
   - Need `Firebase` expect/actual class for iOS
   - Need iOS-specific Firebase configuration

2. **Swift Package Manager (SPM) Configuration**:
   - Xcode project references firebase-ios-sdk but may not be properly linked
   - Native Firebase SDK needs to be available to GitLive's iOS bindings
   - May need to add explicit SPM package references

3. **Authentication Initialization**:
   - `AuthService.initialize()` is called but may not be working on iOS
   - Need to ensure Firebase auth is properly initialized before Firestore calls

4. **Error Handling & Debugging**:
   - No logging to verify Firebase connection
   - No way to see if Firestore queries are actually executing
   - Silent error handling in background sync masks issues

### Root Cause Analysis

The GitLive Firebase SDK for Kotlin Multiplatform requires:
1. **Native Firebase SDKs** to be present in each platform (Android/iOS)
2. **Platform-specific implementations** that bridge Kotlin to native SDKs
3. **Proper Firebase initialization** before use

Currently:
- Android: Likely works (has google-services.json and Gradle plugin)
- iOS: **Broken** - Missing iosMain Firebase implementation, GitLive can't bridge to native Firebase SDK

### Dependencies

1. **Firebase iOS SDK** → GitLive needs this to function
2. **iosMain Firebase implementation** → Bridges Kotlin to iOS SDK
3. **Auth initialization** → Required before Firestore access
4. **Firestore queries** → Depend on auth and bridge working
5. **UI data display** → Depends on successful data fetch

### Contingencies

1. **SPM package resolution issues** → May need to clean build folder, reset SPM cache
2. **Framework linking** → shared.framework may not include Firebase dependencies
3. **Firebase configuration** → GoogleService-Info.plist may not be loaded properly
4. **Network permissions** → iOS may need Info.plist entries for network access
5. **Serialization mismatches** → Firestore data may not match Kotlin models

## Task List

### Phase 1: iOS Firebase Foundation (CRITICAL - BLOCKER)

- [ ] Task 1.1: Add iosMain Firebase expect/actual implementation
  - Create `Firebase.kt` in iosMain with actual implementations
  - Implement FirebaseApp, FirebaseAuth, FirebaseFirestore bridges
  - Use native Firebase SDK via platform interop

- [ ] Task 1.2: Verify Swift Package Manager configuration
  - Confirm firebase-ios-sdk is properly linked in Xcode
  - Check that all required Firebase modules are included
  - Clean build folder and resolve SPM packages if needed

- [ ] Task 1.3: Add iOS-specific Firebase configuration
  - Ensure GoogleService-Info.plist is bundled correctly
  - Add Firebase initialization debugging
  - Verify FirebaseApp.configure() is called before any Firebase operations

### Phase 2: Authentication & Connection

- [ ] Task 2.1: Implement iOS auth debugging
  - Add logging to AuthService.initialize()
  - Verify anonymous auth succeeds on iOS
  - Check auth state after initialization

- [ ] Task 2.2: Add network permissions to Info.plist
  - Verify network access permissions exist
  - Add any required Firebase-specific permissions

### Phase 3: Firestore Integration

- [ ] Task 3.1: Add Firestore query debugging
  - Add logging to FirestoreService.getCollection()
  - Log query execution, success, and failures
  - Add timeout handling with specific error messages

- [ ] Task 3.2: Test speakers collection fetch
  - Add debug logging in SpeakersService.refreshSpeakers()
  - Verify Firestore query executes
  - Check data parsing and SQLite insertion

- [ ] Task 3.3: Test places collection fetch
  - Add debug logging in PlacesService.refreshPlaces()
  - Verify Firestore query executes
  - Check data parsing and SQLite insertion

### Phase 4: Data Validation & Display

- [ ] Task 4.1: Add data validation
  - Verify Firestore data structure matches Speaker/Place models
  - Add validation for required fields
  - Handle missing or malformed data gracefully

- [ ] Task 4.2: Test UI data display
  - Build and run iOS app in simulator
  - Navigate to Speakers tab
  - Navigate to Places tab
  - Verify real Firestore data appears

### Phase 5: Error Handling & Verification

- [ ] Task 5.1: Improve error reporting
  - Replace silent error handling with proper logging
  - Add user-friendly error messages
  - Implement retry logic for transient failures

- [ ] Task 5.2: Final verification
  - Confirm speakers show real data from Firestore
  - Confirm places show real data from Firestore
  - Test pull-to-refresh functionality
  - Verify offline fallback works

## Notes

### Critical Discoveries

1. **GitLive SDK Architecture**: The GitLive Firebase SDK is a wrapper that bridges Kotlin code to native Firebase SDKs. It requires the actual native Firebase SDKs to be present in the platform projects.

2. **iOS Implementation Gap**: While commonMain has the Firebase service classes, there are NO iosMain implementations. This is the root cause - GitLive has no native Firebase SDK to bridge to on iOS.

3. **SPM vs Gradle**: The native Firebase iOS SDK must be added via Swift Package Manager in Xcode, separate from the Gradle dependencies that only affect the Kotlin side.

4. **Reference Project Pattern**: The Flutter reference project uses direct Firebase SDK calls, while this KMP project uses GitLive wrapper. Different approaches, but both need native SDKs present.

### Implementation Strategy

**Primary Approach** (GitLive with iOS native SDK):
1. Create iosMain expect/actual implementations for Firebase
2. Ensure Firebase iOS SDK is installed via SPM
3. Bridge between Kotlin and iOS Firebase SDK using platform interop
4. Initialize Firebase on iOS before any Kotlin Firebase operations

**Alternative** (if GitLive doesn't work):
1. Create iOS-specific services in Swift
2. Call these from Kotlin via platform interop
3. Keep shared module logic but use native implementations for Firebase ops

### Key Files to Modify

- `shared/src/iosMain/kotlin/cz/krutsche/xcamp/shared/firebase/` (CREATE)
- `iosApp/iosApp/XcampApp.swift` (may need changes)
- `iosApp/iosApp/Info.plist` (may need permissions)
- `iosApp/iosApp.xcodeproj/project.pbxproj` (SPM packages)

### Success Criteria

✅ iOS app builds without errors
✅ Firebase initializes successfully on iOS
✅ Anonymous auth completes
✅ Firestore queries execute successfully
✅ Real speaker data appears in SpeakersView
✅ Real place data appears in PlacesView
✅ Pull-to-refresh fetches updated data
✅ No database modifications (READ-ONLY maintained)
