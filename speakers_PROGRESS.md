# Progress: speakers

Started: Mon Jan 19 09:22:49 CET 2026
Last Updated: Mon Jan 19 2026

## Status

IN_PROGRESS

## Completed This Iteration
- Task 1.1: Created SpeakersService in shared module following PlacesService pattern with lazy initialization and all required methods (getAllSpeakers, getSpeakerById, syncFromFirestore, refreshSpeakers)
- Task 2.1: Added getSpeakersService() to AppViewModel.swift following getPlacesService() pattern with lazy initialization and caching

## Task List

### Existing Components (Already Implemented)

**Shared Module (Kotlin):**
1. **Speaker Domain Model** - `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/domain/model/Speaker.kt`
   - Complete with id, uid, name, description, priority, image, imageUrl fields
   - Properly serializable for Firestore

2. **SpeakersRepository** - `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/SpeakersRepository.kt`
   - Inherits from BaseRepository
   - Implements getAllSpeakers(), getSpeakerById(), insertSpeakers(), syncFromFirestore()
   - Collection name: "speakers"

3. **SQLDelight Schema** - `shared/src/commonMain/sqldelight/cz/krutsche/xcamp/shared/db/XcampDatabase.sq`
   - Speaker table fully defined with all CRUD operations
   - Proper indexing on priority and name

**iOS Module:**
1. **SpeakersView.swift** - `iosApp/iosApp/views/SpeakersView.swift`
   - Currently a placeholder with "TODO"
   - Has proper navigation title setup

2. **Tab Configuration** - Speakers tab already configured in ContentView.swift
   - Tab visible in PRE_EVENT and ACTIVE_EVENT modes
   - Icon: "person.2.fill"
   - Tab label: "Řečníci" (Strings.Tabs.shared.SPEAKERS)

**Localization:**
- Tab name "Řečníci" already defined in Strings.kt

### Missing Components (Need Implementation)

**Shared Module:**
1. **SpeakersService** - Service layer following PlacesService pattern
   - No service wrapper exists yet for iOS to consume
   - Needs to expose repository methods to iOS

2. **Speakers background sync** - No lazy loading on app startup
   - Needs to be added to AppViewModel.swift like Places

**iOS Module:**
1. **SpeakersViewModel** - State management for list/detail views
2. **SpeakerListItem** - Grid/list item component for speaker cards
3. **SpeakerDetailView** - Detail screen with hero image and bio
4. **UI Strings** - Missing speaker-specific localized strings (loading, empty, error states)

### Design Reference

Flutter app (`~/Documents/xcamp_app`) provides design reference:
- 2-column grid layout for speaker list
- Card-based design with rounded corners (16px)
- Gradient overlays on images
- Staggered animation on load
- Hero image section in detail view
- About section with speaker bio

### Implementation Strategy

Follow the **Places pattern** established in the codebase:
1. Create SpeakersService in shared module
2. Create SpeakersViewModel with state management
3. Implement SpeakersView with list/grid layout
4. Create SpeakerListItem component
5. Create SpeakerDetailView with hero image
6. Add background sync in AppViewModel
7. Add debug override for testing (keep logic commented out)
8. Add localized strings for all UI states
9. Add SwiftUI previews

## Task List

### Phase 1: Shared Module Setup

- [x] Task 1.1: Create SpeakersService in shared module
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/SpeakersService.kt`
  - Follow PlacesService pattern exactly
  - Methods: getAllSpeakers(), getSpeakerById(), syncFromFirestore(), refreshSpeakers()
  - Lazy initialization of repository and databaseManager

### Phase 2: iOS Service Integration

- [x] Task 2.1: Add getSpeakersService() to AppViewModel.swift
  - Follow getPlacesService() pattern
  - Lazy initialization with caching
  - File: `iosApp/iosApp/AppViewModel.swift`

- [ ] Task 2.2: Add syncSpeakersInBackground() method to AppViewModel.swift
  - Follow syncPlacesInBackground() pattern
  - Task.detached with .background priority
  - Call in initializeApp() after syncPlacesInBackground()
  - Silently handle errors

### Phase 3: iOS UI - ViewModel

- [ ] Task 3.1: Create SpeakersViewModel in SpeakersView.swift
  - Follow PlacesViewModel pattern
  - State enum: loading, loaded([Speaker]), error
  - Methods: loadSpeakers(), refreshSpeakers()
  - @MainActor class with @Published state

### Phase 4: iOS UI - List View

- [ ] Task 4.1: Implement SpeakersView list layout
  - Replace TODO placeholder with proper view structure
  - Use ZStack with Color.background
  - State handling: loadingView, loadedView, emptyView, errorView
  - .task modifier for initial load
  - .refreshable for pull-to-refresh

- [ ] Task 4.2: Create SpeakerListItem component
  - Grid-style card layout (2 columns following Flutter design)
  - GlassCard wrapper
  - AsyncImage for speaker photo with fallback
  - Speaker name overlay with gradient
  - Priority-based ordering handled by repository
  - NavigationLink to SpeakerDetailView

### Phase 5: iOS UI - Detail View

- [ ] Task 5.1: Create SpeakerDetailView
  - ScrollView with VStack
  - Hero image section (250pt height, gradient overlay)
  - GlassCard for speaker description
  - .inline navigationTitleDisplayMode
  - AsyncImage with loading/error states

- [ ] Task 5.2: Add image tap-to-fullscreen functionality (optional, if time permits)
  - Zoom/expand on hero image tap
  - Follow iOS design patterns

### Phase 6: Localization

- [ ] Task 6.1: Add Speakers section to Strings.kt
  - Constants: LOADING, EMPTY_TITLE, ERROR_TITLE, RETRY
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt`

### Phase 7: Debug Override

- [ ] Task 7.1: Add debug override to AppConfigService.kt
  - Add commented debug line to force PRE_EVENT mode
  - Comment: "DEBUG: Force PRE_EVENT mode to show Speakers tab for debugging"
  - Keep logic commented out as per requirements
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/AppConfigService.kt`

### Phase 8: SwiftUI Previews

- [ ] Task 8.1: Add SwiftUI preview for SpeakersView
  - Test with AppViewModel environment

- [ ] Task 8.2: Add SwiftUI preview for SpeakerListItem
  - Test with sample speaker data (with and without image)

- [ ] Task 8.3: Add SwiftUI preview for SpeakerDetailView
  - Test with sample speaker data (with and without description)

### Phase 9: Testing & Verification

- [ ] Task 9.1: Build iOS app with Xcode MCP
  - Verify no build errors

- [ ] Task 9.2: Run in iOS simulator with MCP
  - Verify tab appears (with debug override enabled)
  - Test loading state

- [ ] Task 9.3: Test speaker list functionality
  - Verify speakers load from Firestore
  - Test pull-to-refresh
  - Verify grid layout displays correctly
  - Test empty state

- [ ] Task 9.4: Test speaker detail functionality
  - Tap list item to navigate to detail
  - Verify hero image displays
  - Verify description text renders
  - Test back navigation

- [ ] Task 9.5: Test edge cases
  - Missing speaker image (placeholder)
  - Missing description (empty state)
  - Network error handling
  - Offline mode (local cache)

### Phase 10: Code Review

- [ ] Task 10.1: Run code-reviewer agent
  - Verify no code quality issues
  - Check for anti-patterns

- [ ] Task 10.2: Run ui-reviewer agent
  - Verify KISS/DRY principles
  - Check component separation

## Contingencies & Edge Cases

### Data Handling
- **Empty speakers list**: Show empty state with retry button
- **Missing imageUrl**: Use placeholder icon (person.fill photo)
- **Missing description**: Hide description card entirely
- **Firestore timeout**: Already handled by 5-second timeout in FirestoreService
- **Network failure**: Silent fallback to local cache in background sync

### UI States
- **Loading**: ProgressView with "Načítám řečníky..." text
- **Empty**: "Žádní řečníci" with retry button
- **Error**: "Nepodařilo se načíst řečníky" with retry button
- **Offline**: Show cached data with visual indicator

### Design Considerations
- **Liquid glass aesthetic**: Use GlassCard component, ultraThinMaterial backgrounds
- **Grid layout**: 2 columns following Flutter design reference
- **Gradient overlays**: Black gradient from transparent to 0.5 opacity
- **Spacing**: Follow existing Spacing constants (xs, sm, md, lg, xl, xxl)
- **Corner radii**: Follow existing CornerRadius constants

### Potential Issues
1. **Kotlin-Swift interop**: Speaker model must properly expose to Swift (verified from Places pattern)
2. **AsyncImage caching**: iOS caches automatically, but verify behavior
3. **Firestore speaker collection**: Must exist in Firebase with proper structure
4. **Tab visibility**: Requires PRE_EVENT or ACTIVE_EVENT app state

## Dependencies

**Task Order (must complete in this order):**
1. Phase 1 (Shared Module) must complete before Phase 2
2. Phase 2 (Service Integration) must complete before Phase 3
3. Phase 3 (ViewModel) must complete before Phase 4
4. Phase 4-5 (UI implementation) can proceed in parallel after Phase 3
5. Phase 6 (Localization) can be done anytime before Phase 9
6. Phase 7 (Debug) can be done anytime
7. Phase 8 (Previews) can be done in parallel with UI implementation
8. Phase 9 (Testing) must complete after all implementation phases
9. Phase 10 (Code Review) must complete last

## Notes

### Design Reference (Flutter)
- Grid layout: 2 columns with 16px spacing
- Card design: 16px corner radius, gradient overlays
- Image handling: Cached network images with fallback
- Animation: Staggered load animations (consider for polish)

### Follows Established Patterns
- **Places pattern**: Complete template for list/detail views
- **Service pattern**: Lazy initialization, Result<T> error handling
- **ViewModel pattern**: @MainActor, @Published state, async/await
- **UI patterns**: GlassCard, Spacing constants, Color.background

### Files to Modify
1. `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/SpeakersService.kt` (NEW)
2. `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt` (MODIFY)
3. `iosApp/iosApp/AppViewModel.swift` (MODIFY)
4. `iosApp/iosApp/views/SpeakersView.swift` (MODIFY - major changes)

### Debug Override Location
The debug override should be added near the existing Places debug override in AppConfigService.kt (lines 43-45). Add a similar commented line for Speakers testing.

### iOS 26 "Liquid Glass" Design
- Use `.ultraThinMaterial` for glass effects
- Subtle gradients for depth
- Smooth animations for transitions
- Card-based layout with rounded corners
- Consistent spacing and typography