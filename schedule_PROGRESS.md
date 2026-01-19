# Progress: schedule

Started: Mon Jan 19 10:42:19 CET 2026
Updated: Mon Jan 19 13:15:00 CET 2026

## Status
IN_PROGRESS

## Analysis

### What Already Exists (Backend - COMPLETE)
The schedule feature has a **complete backend implementation** already in place:

1. **Domain Model** (`shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/domain/model/Section.kt`):
   - `Section` data class with all required fields (id, uid, name, description, startTime, endTime, place, speakers, leader, type, favorite, repeatedDates)
   - `SectionType` enum: MAIN, INTERNAL, GOSPEL, FOOD, BASIC (deprecated)

2. **SQLDelight Database** (`XcampDatabase.sq`):
   - Complete `Section` table with all columns
   - CRUD operations: selectAllSections, selectSectionById, selectSectionsByType, selectFavoriteSections, selectSectionsByDateRange
   - Operations: insertSection, insertSections, updateSectionFavorite, deleteAllSections, deleteSectionById, countSections

3. **Repository** (`ScheduleRepository.kt`):
   - Full implementation with all standard methods
   - Firebase sync via `syncFromFirestore()`
   - JSON serialization for speakers array and repeatedDates
   - Time-based queries using Kotlin Instant

4. **iOS Integration**:
   - Schedule tab exists in navigation (ContentView.swift)
   - ScheduleView.swift placeholder exists
   - Uses `Strings.Tabs.shared.SCHEDULE` for title

### What's Missing (iOS UI - TODO)
Only the **iOS UI implementation** is needed:

1. **ScheduleService** - Kotlin service layer (follows SpeakersService/PlacesService pattern)
2. **AppViewModel integration** - Expose ScheduleService to iOS
3. **ScheduleViewModel** - iOS ViewModel for state management
4. **ScheduleView** - Main schedule list view with day tabs
5. **SectionListItem** - Schedule item component
6. **SectionDetailView** - Individual schedule item detail view
7. **Strings** - Localized strings for schedule UI

### Design Inspiration from Flutter
Reference Flutter project has these features to replicate:
- 8-day tab navigation (Sobota through Sobota)
- Type filtering (bottom sheet with color-coded types)
- Favorites system (star toggle)
- Auto-navigation to current day
- Time-based display (past events dimmed/hidden)
- Glassmorphism UI design
- Pull-to-refresh support
- Color coding by section type

### Dependencies Between Tasks
1. ScheduleService must be created before AppViewModel integration
2. AppViewModel integration before ScheduleViewModel can use it
3. Strings must be added before UI components
4. SectionListItem before ScheduleView (uses it)
5. SectionDetailView can be done in parallel with list components

### Contingencies & Edge Cases
1. **Empty state**: No schedule data available
2. **Error state**: Firebase sync fails
3. **Loading state**: Initial data fetch
4. **No favorites**: All sections unfavorited
5. **Single day**: Only one day of events
6. **No speakers/place**: Section without speaker or place references
7. **Debug mode override**: Need to force show schedule tab even with showAppData=false
8. **Time zone handling**: Schedule times are Instant - need proper iOS date formatting
9. **Section type colors**: Need color scheme for each type (matching Flutter)
10. **Repeated events**: Handle repeatedDates array for recurring sections
11. **Current day detection**: Auto-select current/nearest day tab
12. **Past events**: Visual distinction for events that have ended

## Task List

### Phase 1: Kotlin Service Layer
- [x] Task 1.1: Create ScheduleService in shared module
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/ScheduleService.kt`
  - Follow SpeakersService/PlacesService pattern
  - Methods: getAllSections(), getSectionById(), syncFromFirestore(), refreshSections()
  - Lazy initialization of repository

- [x] Task 1.2: Add getScheduleService() to AppViewModel.swift
  - File: `iosApp/iosApp/AppViewModel.swift`
  - Add private scheduleService property
  - Add getScheduleService() getter method
  - Add syncScheduleInBackground() method (called after app init, like places/speakers)

### Phase 2: Strings & Localization
- [x] Task 2.1: Add schedule-related strings to Strings.kt
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/util/Strings.kt`
  - Add Schedule object with: LOADING, EMPTY_TITLE, ERROR_TITLE, RETRY, FILTER_TITLE, FILTER_ALL, FAVORITES, SHOW_ALL
  - Add SectionType strings: MAIN, INTERNAL, GOSPEL, FOOD labels
  - Add day names: MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, SUNDAY
  - Add detail view strings: TIME, PLACE, SPEAKERS, LEADER, TYPE, DESCRIPTION, ADD_TO_FAVORITES, REMOVE_FROM_FAVORITES

### Phase 3: iOS ViewModels & State
- [x] Task 3.1: Create ScheduleViewModel
  - File: `iosApp/iosApp/viewmodels/ScheduleViewModel.swift` (included in ScheduleView.swift)
  - State enum: loading, loaded([Section]), error
  - loadSections() method
  - refreshSections() method (pull-to-refresh)
  - toggleFavorite() method
  - Group sections by day (8-day structure)
  - Determine current/nearest day for auto-navigation
  - Filter by section type
  - Filter by favorites

### Phase 4: iOS UI Components
- [x] Task 4.1: Create SectionListItem component
  - File: `iosApp/iosApp/components/schedule/SectionListItem.swift` (included in ScheduleView.swift)
  - GlassCard container
  - Time display (start time)
  - Section name and description (truncated)
  - Type indicator (color-coded)
  - Favorite star indicator
  - Navigate to detail on tap
  - Haptic feedback on tap

- [x] Task 4.2: Create SectionDetailView
  - File: `iosApp/iosApp/views/SectionDetailView.swift` (included in ScheduleView.swift)
  - Hero section with type color gradient
  - Section name, description
  - Time display (start - end)
  - Place (if available, link to PlaceDetailView)
  - Speakers (if available, list with links to SpeakerDetailView)
  - Leader (if available)
  - Favorite toggle button
  - GlassCard content sections

- [x] Task 4.3: Create ScheduleDayTab component
  - File: `iosApp/iosApp/views/ScheduleView.swift` (included in ScheduleView.swift)
  - Scrollable tab bar for 8 days
  - Czech day names
  - Visual indicator for selected day (secondary color with border)
  - Visual indicator for current day
  - Horizontal scroll with leading/trailing padding

- [ ] Task 4.4: Create ScheduleFilterView (bottom sheet)
  - File: `iosApp/iosApp/components/schedule/ScheduleFilterView.swift`
  - Sheet presentation
  - Filter toggle for each SectionType
  - Color-coded type indicators
  - "Show All" / "Hide All" quick actions
  - Favorites-only toggle

### Phase 5: Main Schedule View
- [x] Task 5.1: Implement ScheduleView
  - File: `iosApp/iosApp/views/ScheduleView.swift` (replaced placeholder)
  - NavigationView wrapper
  - ScheduleDayTab component at top
  - ScrollView with LazyVStack for sections
  - Filter FAB (floating action button)
  - Loading, empty, error states
  - Pull-to-refresh support
  - .task modifier for initial load
  - Auto-select current day on first load

### Phase 6: Design & Polish
- [ ] Task 6.1: Define SectionType color scheme
  - File: `iosApp/iosApp/utils/SectionTypeColors.swift` (new file)
  - Color extension for each section type
  - Match Flutter implementation colors
  - Handle both light/dark mode

- [x] Task 6.2: Add time formatting utilities
  - File: `iosApp/iosApp/utils/KotlinInstantExtensions.swift` (created)
  - Format Kotlin Instant to readable time
  - Format date range for display
  - Czech locale support

### Phase 7: Debug Mode Integration
- [ ] Task 7.1: Add debug override for schedule tab
  - Modify: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/AppConfigService.kt`
  - Add debug flag or check for build configuration
  - Force include schedule tab in debug mode regardless of showAppData
  - Comment out logic per requirements (keep but disable)

### Phase 8: Testing & Verification
- [x] Task 8.1: Build and run iOS app
  - Use MCP build_run_sim to compile and launch
  - Verify no compilation errors

- [ ] Task 8.2: Visual testing
  - Use MCP screenshot to capture schedule view
  - Use MCP describe_ui to verify hierarchy
  - Test all interactions (tap, swipe, scroll)

- [ ] Task 8.3: Functional testing
  - Test loading state
  - Test empty state (no schedule data)
  - Test error state (network failure)
  - Test day tab navigation
  - Test filter functionality
  - Test favorite toggle
  - Test section detail navigation
  - Test pull-to-refresh
  - Test auto-navigation to current day

### Phase 9: Code Review
- [ ] Task 9.1: Run code-reviewer agent
  - Comprehensive code quality review
  - Address all violations

- [ ] Task 9.2: Run ui-reviewer agent
  - KISS/DRY UI component review
  - Ensure proper component separation

## Completed This Iteration
- Task 2.1: Added schedule-related strings to Strings.kt including Schedule object with LOADING, EMPTY_TITLE, ERROR_TITLE, RETRY, FILTER_TITLE, FILTER_ALL, FAVORITES, SHOW_ALL, SectionType labels, day names, and Detail view strings.
- Task 3.1: Created ScheduleViewModel in ScheduleView.swift with state management, load/refresh methods, favorite toggle, type filtering, favorites-only filter, and current day auto-selection.
- Task 4.1: Created SectionListItem component with GlassCard, time display, section info, favorite star indicator, and navigation.
- Task 4.2: Created SectionDetailView with hero section (color gradient by type), time display, description, and favorite toggle button in toolbar.
- Task 4.3: Created ScheduleDayTab component with scrollable 8-day tab bar, Czech day names (Sobota → Sobota), visual indicators for selected day (secondary color with border) and current day detection, horizontal scroll with padding, and smooth animations on selection.
- Task 5.1: Implemented ScheduleView with NavigationView, loading/empty/error states, ScrollView with LazyVStack, pull-to-refresh support, and .task modifier for initial load.
- Task 6.2: Created KotlinInstantExtensions.swift with epochMillis computed property for easy time conversion.
- Task 8.1: iOS build successful - no compilation errors.

**Implementation Notes:**
- Used typealias `ScheduleSection = shared.Section` to avoid ambiguity with SwiftUI.Section
- Kotlin nullable strings are exposed as regular Swift strings (empty when null)
- Kotlin Instant needs extension for epochMillis access (via toEpochMilliseconds())
- Added default cases to switch statements for SectionType exhaustiveness
- Color scheme: purple (main/basic), green (internal), pink (gospel), yellow (food)
- ScheduleDayTab uses closure-based selection instead of @Binding for cleaner separation of concerns
- Day names hardcoded in Swift due to Kotlin nested object access issues (nested `Days` object not properly exposed to Swift)

## Notes

### Important Implementation Details

1. **Time Handling**: Section uses `kotlin.time.Instant` which converts to epoch milliseconds in database. iOS will receive this as Kotlin Instant type - need to convert to Date for display.

2. **JSON Arrays**: Speakers and repeatedDates are stored as JSON strings in SQLite. The repository handles serialization/deserialization.

3. **Favorites**: Toggle updates database immediately via `updateSectionFavorite()`.

4. **8-Day Structure**: Event is 8 days (Saturday through Saturday). Need to group sections by day based on startTime.

5. **Type Filtering**: Should filter visible sections in real-time without re-fetching from service.

6. **Debug Mode**: Per requirements, schedule should be enabled for debugging with override code but kept commented out.

7. **Lazy Loading**: Follow existing pattern - sync in background after app init, load from local cache for UI.

8. **Design System**: Use existing Spacing, CornerRadius, Color.background, GlassCard components.

9. **Navigation**: ScheduleView → SectionDetailView, with links to PlaceDetailView and SpeakerDetailView from section detail.

10. **State Management**: Use @StateObject for ViewModel, @EnvironmentObject for AppViewModel.

### File Structure Reference

```
shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/
├── data/
│   ├── config/
│   │   ├── ScheduleService.kt (NEW)
│   │   └── AppConfigService.kt (modify for debug)
│   └── repository/
│       └── ScheduleRepository.kt (EXISTS - no changes)
└── util/
    └── Strings.kt (modify - add schedule strings)

iosApp/iosApp/
├── AppViewModel.swift (modify - add schedule service)
├── utils/
│   ├── SectionTypeColors.swift (NEW)
│   └── DateFormatter+Extensions.swift (extend or create)
├── components/
│   └── schedule/ (NEW directory)
│       ├── SectionListItem.swift (NEW)
│       ├── ScheduleDayTab.swift (NEW)
│       └── ScheduleFilterView.swift (NEW)
├── views/
│   ├── ScheduleView.swift (replace placeholder)
│   └── SectionDetailView.swift (NEW)
└── viewmodels/
    └── ScheduleViewModel.swift (NEW)
```

### Pattern References to Follow

**Kotlin Service** (SpeakersService.kt):
- Lazy initialization pattern
- Repository access via lazy delegate
- refreshX() method that syncs then returns local data

**iOS ViewModel** (SpeakersViewModel.swift):
- @MainActor class
- @Published state property
- State enum with loading/loaded/error cases
- Separate load() and refresh() methods

**iOS View** (SpeakersView.swift):
- NavigationView wrapper
- ZStack with Color.background
- Switch on viewModel.state
- .task modifier for initial load
- .refreshable for pull-to-refresh
- Separate computed views for loading/empty/error

**List Item** (SpeakerListItem.swift):
- GlassCard container
- HStack layout with image + info + chevron
- AsyncImage with phase handling
- NavigationLink with PlainButtonStyle

**Detail View** (SpeakerDetailView.swift):
- ScrollView with VStack
- Hero image with gradient overlay
- GlassCard content with negative top padding
- Inline navigation title display mode
