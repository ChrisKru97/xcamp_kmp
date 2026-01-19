# Progress: places

Started: Sun Jan 18 20:53:31 CET 2026
Last Updated: Mon Jan 19 09:03:00 CET 2026

## Status

IN_PROGRESS

## Analysis

### What Already Exists

**Shared Kotlin Layer:**
- ✅ Complete `Place` data model in `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/domain/model/Place.kt`
- ✅ Complete SQLDelight schema with all CRUD operations in `XcampDatabase.sq`
- ✅ Generated SQLDelight database code
- ✅ `AppTab.PLACES` enum defined in `AppConfigService.kt`
- ✅ Places tab configured to show in PRE_EVENT and ACTIVE_EVENT states
- ✅ `BaseRepository<T>` pattern established with `syncFromFirestore()` template method
- ✅ `FirestoreService` with 5-second timeout protection
- ✅ `DatabaseManager` with Place operations in `clearAllData()`

**iOS Layer:**
- ✅ Tab navigation integrated in `ContentView.swift` (lines 47-52)
- ✅ `PlacesView.swift` exists as placeholder
- ✅ Tab text localized in `Strings.kt` as "Místa"
- ✅ `AppViewModel` pattern for service management established
- ✅ Design system components: `GlassCard`, `LinkTile`, spacing constants
- ✅ Modern iOS patterns with SwiftUI and environment objects

**Flutter Reference Implementation:**
- Comprehensive Flutter implementation at `~/Documents/xcamp_app` provides excellent reference
- Shows data model structure, Firestore sync patterns, and UI design approach
- Glass morphism effects, staggered animations, hero transitions
- Pull-to-refresh and lazy loading patterns documented

### What's Missing

**Shared Kotlin Layer:**
- ❌ `PlacesRepository` implementation (core missing piece)
- ❌ Places service integration in `AppViewModel` (getter method)
- ❌ Background sync coordinator for lazy loading
- ❌ Pull-to-refresh trigger mechanism

**iOS UI Layer:**
- ❌ `PlacesListView` component (list of all places)
- ❌ `PlaceListItem` component (individual place card)
- ❌ `PlaceDetailView` component (detail screen with map integration)
- ❌ Navigation to detail view
- ❌ Pull-to-refresh implementation
- ❌ Loading and empty states
- ❌ Image loading with Firebase Storage integration
- ❌ Map integration for coordinates (open in Maps app)

**Design & UX:**
- ❌ Modern "liquid glass" design system alignment
- ❌ Smooth animations and transitions
- ❌ Responsive layout for different screen sizes
- ❌ Accessibility labels and traits

### Architecture Patterns to Follow

**Repository Pattern (from SpeakersRepository):**
```kotlin
class PlacesRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Place>(databaseManager, firestoreService) {
    override val collectionName = "places"
    suspend fun getAllPlaces(): List<Place>
    suspend fun getPlaceById(id: Long): Place?
    suspend fun insertPlaces(places: List<Place>)
    suspend fun syncFromFirestore(): Result<Unit>
}
```

**Service Pattern (from AppViewModel):**
```swift
func getPlacesService() -> PlacesService {
    guard let placesService = placesService else {
        let newPlacesService = PlacesService(
            placesRepository: getPlacesRepository()
        )
        self.placesService = newPlacesService
        return newPlacesService
    }
    return placesService
}
```

**iOS Component Pattern:**
- Use `GlassCard` for card-based layout
- Implement lazy loading in `onAppear` of the view
- Use `@Published` properties for reactive updates
- SwiftUI previews for all components

### Dependencies & Contingencies

**Task Dependencies:**
1. `PlacesRepository` must exist before iOS service can be created
2. iOS service must exist before `PlacesView` can display data
3. Pull-to-refresh requires async repository sync
4. Image loading requires Firebase Storage integration

**Potential Contingencies:**
- Firestore may not have "places" collection configured (add fallback to empty state)
- Places may not have images (handle gracefully with placeholder)
- Geolocation may be null (hide map button when no coordinates)
- Network may be unavailable (show cached data with error indicator)
- Empty places list (show appropriate empty state)
- Large images may cause performance issues (implement thumbnail loading)

**Design Considerations:**
- Glass morphism effects require iOS 15+ (already covered by minimum iOS 14.1 target)
- Hero animations require NavigationView setup
- Staggered animations need ForEach with indexed delays
- Dark mode support required (test with `.preferredColorScheme(.dark)`)

### Technical Specifications

**Firestore Collection:** `places`
**Query Pattern:** Order by `priority`, then `name` (ascending)
**Timeout:** 5 seconds (inherited from BaseRepository)
**Insert Strategy:** INSERT OR REPLACE (upsert)
**Offline-First:** Load from SQLite first, sync from Firestore in background

**iOS Design Requirements:**
- Modern, minimalistic "liquid glass" aesthetic
- Glass morphism cards with backdrop blur
- Smooth animations and transitions
- Pull-to-refresh with manual sync trigger
- Map integration for places with coordinates
- Hero transitions from list to detail
- Loading states with progress indicators
- Empty states with retry functionality

## Task List

### Phase 1: Shared Kotlin Layer

- [x] **Task 1.1:** Create `PlacesRepository` class extending `BaseRepository<Place>`
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/PlacesRepository.kt`
  - Implement `getAllPlaces()` method using `selectAllPlaces`
  - Implement `getPlaceById(id: Long)` method using `selectPlaceById`
  - Implement `insertPlaces(places: List<Place>)` using transaction
  - Implement `syncFromFirestore()` using BaseRepository template method
  - Add `mapToPlace()` mapper function from database entity to domain model

- [x] **Task 1.2:** Register `PlacesRepository` in Koin dependency injection
  - NOTE: Koin DI is not used in this project - factory pattern via DatabaseFactory instead
  - PlacesRepository is instantiated directly in PlacesService via DatabaseFactory
  - Ensure `DatabaseManager` and `FirestoreService` are injected

### Phase 2: iOS Service Layer

- [x] **Task 2.1:** Create `PlacesService` Kotlin class for iOS interop
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/PlacesService.kt`
  - Implement `getAllPlaces(): List<Place>` method (cached from SQLite)
  - Implement `getPlaceById(id: Long): Place?` method
  - Implement `refreshPlaces(): Result<List<Place>>` method for pull-to-refresh
  - Use coroutines for async operations

- [x] **Task 2.2:** Add `getPlacesService()` getter to iOS `AppViewModel`
  - File: `iosApp/iosApp/AppViewModel.swift`
  - Add private `placesService` property
  - Implement lazy initialization pattern (same as `getLinksService()`)
  - Ensure thread-safe singleton pattern

### Phase 3: iOS UI Components (Design System)

- [x] **Task 3.1:** Create `PlaceListItem` component for individual place cards
  - File: `iosApp/iosApp/views/PlacesView.swift` (embedded)
  - Implement glass morphism card design with GlassCard
  - Display place name, description (truncated if needed)
  - Show thumbnail image (if available) with AsyncImage
  - Add tap gesture to navigate to detail via NavigationLink
  - Implement SwiftUI preview with sample data

- [x] **Task 3.2:** Create `PlacesListView` component for list display
  - File: `iosApp/iosApp/views/PlacesView.swift` (embedded)
  - Implement LazyVStack for list rendering
  - Add pull-to-refresh with `.refreshable` modifier
  - Show loading state with ProgressView
  - Show empty state with message and retry button
  - Show error state with alert
  - Implement SwiftUI preview with states

- [x] **Task 3.3:** Create `PlaceDetailView` for place details
  - File: `iosApp/iosApp/views/PlacesView.swift` (embedded)
  - Implement hero image with gradient overlay
  - Display place name, full description in GlassCard
  - Add map button if coordinates available
  - Add SwiftUI preview with sample place data

- [ ] **Task 3.4:** Create `PlaceImageView` for full-screen image viewing
  - SKIPPED: Not implemented as part of initial scope
  - Current implementation shows hero image in detail view
  - Can be added later if needed

### Phase 4: Integration & Navigation

- [x] **Task 4.1:** Update `PlacesView` to use new components
  - File: `iosApp/iosApp/views/PlacesView.swift`
  - Connected to `appViewModel.getPlacesService()`
  - Implement navigation to `PlaceDetailView` via NavigationLink
  - Add loading state handling with PlacesViewModel
  - Fixed Kotlin-Swift interop issues (KotlinDouble, optional handling)

- [x] **Task 4.2:** Add map integration for place coordinates
  - File: `iosApp/iosApp/views/PlacesView.swift`
  - Implement button to open Apple Maps with coordinates
  - Use `URL(string: "http://maps.apple.com/?ll=...&q=...")` for deep link
  - Hide button if coordinates are null
  - Convert KotlinDouble to Double via .doubleValue

### Phase 5: Polish & Refinement

- [ ] **Task 5.1:** Implement lazy loading on app startup
  - File: `iosApp/iosApp/AppViewModel.swift`
  - Add background sync after Remote Config loads
  - Use Task.detached for non-blocking sync
  - Update UI when sync completes
  - Handle errors gracefully

- [x] **Task 5.2:** Add "Enable for debugging" override
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/AppConfigService.kt`
  - Add override flag to show Places tab regardless of app state
  - Comment out the override logic (keep it for future debugging)
  - Document how to enable for debugging

- [ ] **Task 5.3:** Test all UI states and edge cases
  - Test with empty places list (show empty state)
  - Test with no network connection (show cached data)
  - Test with network errors (show error message)
  - Test with missing images (show placeholder)
  - Test with missing coordinates (hide map button)
  - Test pull-to-refresh functionality
  - Test navigation between list and detail
  - Test on different screen sizes (iPhone SE, iPhone 15 Pro Max)
  - Test in light and dark mode
  - Test accessibility with VoiceOver

- [ ] **Task 5.4:** Optimize performance and animations
  - Profile image loading with Instruments
  - Optimize list rendering with LazyVStack
  - Smooth out staggered animations
  - Add haptic feedback for interactions
  - Reduce memory footprint for large images
  - Add caching for frequently accessed places

- [ ] **Task 5.5:** Code review and documentation
  - Review all code for KISS/DRY violations
  - Ensure no hardcoded strings (use localization)
  - Add inline comments for complex logic
  - Verify SwiftUI previews exist for all components
  - Update CLAUDE.md with Places feature documentation
  - Add to APP_FEATURES.md if applicable

### Contingency Tasks (if needed)

- [ ] **Contingency C.1:** If Firestore "places" collection doesn't exist
  - Create mock data service for testing
  - Add fallback to show empty state gracefully
  - Document Firestore collection structure

- [ ] **Contingency C.2:** If image loading is slow
  - Implement thumbnail loading strategy
  - Add progressive image loading
  - Cache images in memory with NSCache
  - Show low-res placeholder while loading

- [ ] **Contingency C.3:** If animations are janky
  - Reduce animation complexity
  - Use SwiftUI's built-in animations instead of custom
  - Test on older devices for performance

- [ ] **Contingency C.4:** If map integration fails
  - Add fallback to show coordinates as text
  - Provide option to copy coordinates
  - Document platform-specific map URL schemes

## Notes

**Important Discoveries:**
1. `SpeakersView` is also a TODO - this pattern suggests similar features may need implementation
2. Places tab is already configured in navigation - just needs data and UI
3. BaseRepository pattern makes repository implementation straightforward
4. Glass morphism design system is already established in the app
5. Flutter reference implementation is comprehensive and well-structured

**Design Decisions:**
- Use SwiftUI's `.refreshable` modifier for pull-to-refresh (iOS 15+)
- Implement hero animations using NavigationView's built-in transitions
- Use AsyncImage for Firebase Storage image loading
- Show map button only when both latitude AND longitude are present
- Use glass morphism for all cards (consistent with app design)
- Implement staggered animations for list items (400ms base + 100ms per item)

**Testing Strategy:**
- Use SwiftUI previews extensively for UI components
- Test with mock data for various scenarios
- Build and run on simulator for integration testing
- Test on physical device for map integration
- Use Instruments for performance profiling

**Code Quality:**
- Follow existing patterns from `SpeakersRepository` and `MediaView`
- Use Result<T> for error handling in Kotlin
- Use @Published properties for reactive UI updates
- Ensure all components have SwiftUI previews
- Add accessibility labels for VoiceOver support

## Completed This Iteration

**Task 1.1 - PlacesRepository Implementation (2026-01-18):**
- Created `PlacesRepository.kt` at `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/PlacesRepository.kt`
- Followed the exact pattern from `SpeakersRepository`
- Implemented all required methods:
  - `getAllPlaces()`: Fetches all places ordered by priority, then name
  - `getPlaceById(id: Long)`: Fetches a single place by ID
  - `insertPlaces(places: List<Place>)`: Transactional insert with INSERT OR REPLACE
  - `syncFromFirestore()`: Uses BaseRepository template method for Firestore sync
  - `mapToPlace()`: Maps database entity to domain model
- Build verified successful with `./gradlew :shared:compileKotlinMetadata`

**Task 2.1 - PlacesService Implementation (Already Complete):**
- Found existing `PlacesService.kt` at `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/PlacesService.kt`
- Service properly integrates PlacesRepository with DatabaseFactory
- Includes `getAllPlaces()`, `getPlaceById()`, `syncFromFirestore()`, and `refreshPlaces()` methods

**Task 2.2 - AppViewModel Integration (Already Complete):**
- Found existing `getPlacesService()` getter in `iosApp/iosApp/AppViewModel.swift`
- Properly implements lazy singleton pattern

**Tasks 3.1-3.3 & 4.1-4.2 - iOS UI Implementation (Already Complete):**
- Found complete implementation in `iosApp/iosApp/views/PlacesView.swift`
- Includes PlacesViewModel, PlaceListItem, PlaceDetailView all in one file
- Pull-to-refresh, loading states, empty states, error states all implemented
- Map integration via Apple Maps deep links

**Task 4.2 & 5.2 - Bug Fixes and Debug Override (2026-01-19):**
- Fixed Kotlin-Swift interop issues in PlacesView.swift:
  - Changed `place.description` optional handling (Kotlin String? behaves differently)
  - Fixed KotlinDouble to Double conversion using `.doubleValue`
  - Fixed Result type handling in refreshPlaces()
  - Fixed error handling in loadPlaces()
- Added debug override in AppConfigService.kt:
  - Added commented line to force PRE_EVENT mode for debugging
  - Enables Places tab visibility regardless of Remote Config state
- Build verified successful with Xcode build on iOS Simulator
