# Progress: code-review

Started: Mon Jan 19 15:07:43 CET 2026
Analysis Complete: Mon Jan 19 15:45:00 CET 2026
Phase 1-4 Complete: Mon Jan 19 23:06:00 CET 2026

## Status

IN_PROGRESS - All Critical and High priority issues resolved (15/20 tasks complete). Remaining: 5 Medium/Low priority tasks.

## Analysis

### Commits Reviewed
Total commits analyzed: 17 commits from `7ed9af795cb6bd193446d6af0f784e798f76aef1` to `HEAD`

**Places Feature (7 commits)**:
- 27886a3 Implement PlacesRepository for Places feature
- c841508 Implement PlacesService and DatabaseFactory for shared Kotlin layer
- d84cddf Fix PlacesView Kotlin-Swift interop issues and add debug override
- fbc3d23 Update places_PROGRESS.md with completed tasks status
- ee8505c Implement lazy loading for places on app startup
- 7f61f0d Complete Task 5.3 - UI states and edge cases testing for Places
- 24a685d Complete Places feature - Tasks 5.4 and 5.5

**Speakers Feature (5 commits)**:
- e19e8f7 Add SpeakersService to shared module
- ebbc0bc Add getSpeakersService() to AppViewModel.swift
- 2ddbd99 Implement Speakers feature for iOS
- 0606121 Mark speakers feature as RALPH_DONE - all tasks verified complete
- 1e80b29 Mark speakers feature as RALPH_DONE - all tasks verified complete

**Schedule Feature (6 commits)**:
- e801d9a Implement ScheduleService in shared module
- 3edefb6 Add ScheduleService to AppViewModel with background sync
- 8d4a32a Implement Schedule feature iOS UI (Tasks 2.1, 3.1, 4.1, 4.2, 5.1, 6.2, 8.1)
- 9e3d945 Implement ScheduleDayTab component (Task 4.3)
- d3174b4 Implement ScheduleFilterView (Task 4.4)
- 09aa4ba Verify Schedule feature implementation (Tasks 2-8)

### Issues Summary

| Severity | Count | Files Affected |
|----------|-------|----------------|
| Critical | 6 | 3 files |
| High | 8 | 5 files |
| Medium | 7 | 4 files |
| Low | 4 | 3 files |

## Task List

### Critical Issues (Must Fix)

- [x] **CRITICAL-001**: Disable active debug override in AppConfigService.kt:43-45
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/AppConfigService.kt`
  - **Issue**: Line 45 `return AppState.PRE_EVENT` is active, bypassing Remote Config
  - **Fix**: Comment out the debug override line

- [x] **CRITICAL-002**: Extract database mapping duplication in ScheduleRepository.kt
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/ScheduleRepository.kt`
  - **Issue**: 5 identical mapping blocks (18 lines each) in lines 20-145
  - **Fix**: Create `toDomain()` extension function, reduce file from 218 to ~120 lines

- [x] **CRITICAL-003**: Add timeout protection to ScheduleRepository.syncFromFirestore()
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/ScheduleRepository.kt`
  - **Lines**: 196-211
  - **Issue**: Missing 5-second timeout wrapper on Firestore operations

- [x] **CRITICAL-004**: Split ScheduleView.swift (812 lines) into separate files
  - **File**: `iosApp/iosApp/views/ScheduleView.swift`
  - **Issue**: Contains 7 components in one file (8x the 100-line guideline)
  - **Fix**: Create directory structure with separate files for each component

- [x] **CRITICAL-005**: Fix hardcoded Czech strings in ScheduleView.swift
  - **File**: `iosApp/iosApp/views/ScheduleView.swift`, `iosApp/iosApp/components/schedule/SectionDetailView.swift`, `iosApp/iosApp/utils/SectionTypeExtensions.swift`
  - **Lines**: 93-102, SectionDetailView.swift:62,83, SectionTypeExtensions.swift:38-46
  - **Issue**: Day names, "Čas", "Popis", type labels hardcoded
  - **Fix**: Moved to Strings.kt, updated to use localized constants

- [x] **CRITICAL-006**: Implement or remove TODO in calculateDayIndex()
  - **File**: `iosApp/iosApp/components/schedule/ScheduleViewModel.swift`
  - **Line**: 123-162 (previously ScheduleView.swift:261)
  - **Issue**: TODO with incomplete implementation, always returns 0
  - **Fix**: Implemented proper day calculation using Remote Config startDate with ISO-8601 date parsing, day difference calculation, and proper clamping for 8-day event

### High Priority Issues

- [x] **HIGH-001**: Fix SectionDetailView favorite toggle persistence
  - **File**: `iosApp/iosApp/components/schedule/SectionDetailView.swift`
  - **Lines**: 4-11 (init), 24-36 (toolbar)
  - **Issue**: Toggle only updates local @State, doesn't call service.toggleFavorite()
  - **Fix**: Added service and onFavoriteToggled callback parameters to SectionDetailView, persist favorite toggle via service.toggleFavorite() and refresh parent view

- [x] **HIGH-002**: Remove redundant client-side sorting in SpeakersViewModel
  - **File**: `iosApp/iosApp/views/SpeakersView.swift`
  - **Lines**: 105-111 (removed)
  - **Issue**: O(n log n) sort on data already sorted by SQL
  - **Fix**: Removed redundant sorting; SQL query already includes `ORDER BY priority, name`

- [x] **HIGH-003**: Consolidate multiple FirestoreService instances
  - **Files**: SpeakersService.kt:13, PlacesService.kt:13, ScheduleService.kt:15
  - **Issue**: Each service creates its own FirestoreService instance
  - **Fix**: Created ServiceFactory with getFirestoreService() singleton, following DatabaseFactory pattern. All three services now use ServiceFactory.getFirestoreService()

- [x] **HIGH-004**: Add error state to ScheduleViewModel
  - **File**: `iosApp/iosApp/components/schedule/ScheduleViewModel.swift`
  - **Lines**: 17, 23, 69-71, 79-81 (updated)
  - **Issue**: Empty catch blocks silently swallow errors
  - **Fix**: Added @Published var lastError: Error? and clearError() method, set lastError in catch blocks

- [x] **HIGH-005**: Add missing SwiftUI previews for Schedule components
  - **Files**: `iosApp/iosApp/components/schedule/SectionListItem.swift`, `SectionDetailView.swift`
  - **Issue**: Preview placeholders don't show actual component rendering
  - **Fix**: Enhanced SectionListItem and SectionDetailView previews with simulated data showing full component layout in both light and dark modes. ScheduleDayTab and ScheduleFilterView already had comprehensive previews.

- [x] **HIGH-006**: Revert LinkTile.swift color changes for dark mode
  - **File**: `iosApp/iosApp/components/common/LinkTile.swift`
  - **Lines**: 26, 31
  - **Issue**: Changed from `.primary` to `.black` (doesn't work in dark mode)
  - **Fix**: Already using `.primary.opacity(0.8)` - no changes needed, task already complete

- [x] **HIGH-007**: Add nil-safe URL wrapper for AsyncImage
  - **Files**: SpeakersView.swift:148,207, PlacesView.swift:147,215
  - **Issue**: Using `URL(string: imageUrl ?? "")` can create invalid URLs
  - **Fix**: Created computed properties `imageUrl` that safely return optional URL in SpeakerListItem, SpeakerDetailView, PlaceListItem, and PlaceDetailView

- [x] **HIGH-008**: Extract SectionType mappings to reusable extension
  - **File**: `iosApp/iosApp/utils/SectionTypeExtensions.swift`
  - **Issue**: colorForSectionType, iconForSectionType, labelForType duplicated
  - **Fix**: Already implemented - SectionTypeExtensions.swift exists with color, icon, and label computed properties

### Medium Priority Issues

- [x] **MEDIUM-001**: Extract duplicate AsyncImage phase handling
  - **Files**: SpeakersView.swift, PlacesView.swift
  - **Issue**: 60+ lines of identical AsyncImage phase handling code
  - **Fix**: Created AsyncImageWithFallback component with HeroAsyncImageWithFallback variant

- [ ] **MEDIUM-002**: Create shared date formatting utilities
  - **Files**: ScheduleView.swift:308-314, 503-509
  - **Issue**: formatTime() duplicated, creates new DateFormatter on every call
  - **Fix**: Create Date+Extensions.swift with cached static formatter

- [ ] **MEDIUM-003**: Add "Skrýt vše" to Strings.kt
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/util/Strings.kt`
  - **Fix**: Add to Strings.Schedule object

- [ ] **MEDIUM-004**: Update debug comment in AppConfigService
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/AppConfigService.kt`
  - **Line**: 43
  - **Issue**: Comment mentions "Speakers tab" only, should mention "Speakers/Places tabs"

- [ ] **MEDIUM-005**: Optimize insertPlaces() batch insert pattern
  - **File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/PlacesRepository.kt`
  - **Lines**: 22-38
  - **Issue**: Individual inserts in loop vs batch operation
  - **Note**: Codebase-wide pattern, not a violation

### Low Priority Issues

- [ ] **LOW-001**: Consider file organization for 300+ line view files
  - **Files**: SpeakersView.swift (314 lines), PlacesView.swift (349 lines)
  - **Status**: Acceptable with clear MARK comments, future consideration

## Implementation Order

### Phase 1: Critical Fixes (Blocks Production)
1. CRITICAL-001: Disable debug override
2. CRITICAL-002: Extract database mapping
3. CRITICAL-003: Add timeout protection
4. CRITICAL-006: Implement calculateDayIndex

### Phase 2: Architecture & Structure
5. CRITICAL-004: Split ScheduleView.swift into separate files
6. CRITICAL-005: Fix hardcoded strings (requires Phase 5 first)
7. HIGH-003: Consolidate FirestoreService instances

### Phase 3: Functionality Fixes
8. HIGH-001: Fix favorite toggle persistence
9. HIGH-002: Remove redundant sorting
10. HIGH-006: Fix LinkTile dark mode colors
11. HIGH-007: Add nil-safe URL wrappers

### Phase 4: Developer Experience
12. HIGH-004: Add error state handling
13. HIGH-005: Add missing SwiftUI previews
14. MEDIUM-004: Update debug comment

### Phase 5: Code Quality & DRY
15. HIGH-008: Create SectionType extensions
16. MEDIUM-001: Extract AsyncImage component
17. MEDIUM-002: Create date formatting utilities
18. MEDIUM-003: Add missing strings

## Completed This Iteration
- **CRITICAL-001**: Disabled debug override in AppConfigService.kt - removed `return AppState.PRE_EVENT` bypass, restored proper Remote Config-based app state determination
- **CRITICAL-002**: Fixed DRY violation in insertSections() - now uses existing toDbInsert() helper instead of inline duplication
- **CRITICAL-003**: Added timeout protection to ScheduleRepository.syncFromFirestore() - wrapped entire sync operation (fetch + insert) in withTimeout(5.seconds) to ensure total operation completes within 5 seconds
- **CRITICAL-004**: Split ScheduleView.swift (720 lines → 150 lines) into separate component files in `iosApp/iosApp/components/schedule/`:
  - Created `ScheduleViewModel.swift` - ViewModel and ScheduleState enum
  - Created `SectionListItem.swift` - List item component
  - Created `ScheduleDayTab.swift` - Day tab and DayTabItem components
  - Created `SectionDetailView.swift` - Detail view component
  - Created `ScheduleFilterView.swift` - Filter view and filter row components
  - Fixed ScheduleRepository.kt bug: Changed `XcampDatabase.Section` to correct `cz.krutsche.xcamp.shared.db.Section` import
  - Fixed ScheduleRepository.kt bug: Changed `XcampDatabase` parameter type to `XcampDatabaseQueries` in `toDbInsert()`
  - Fixed ScheduleRepository.kt bug: Removed incorrect `suspend` modifier from `toDbInsert()` function
  - Build successful, app running in iOS simulator
- **CRITICAL-005**: Fixed hardcoded Czech strings in Schedule components:
  - Updated `Strings.kt` to add SECTIONTYPE_*, DAYS_*, and DETAIL_* constants with proper naming
  - Updated `ScheduleView.swift` to use `Strings.ScheduleDays.shared.DAYS_*` for day names
  - Updated `SectionDetailView.swift` to use `Strings.ScheduleDetail.shared.DETAIL_*` for labels
  - Updated `SectionTypeExtensions.swift` to use `Strings.ScheduleSectionType.shared.SECTIONTYPE_*` for type labels
  - All hardcoded strings now use Strings.kt for consistency and easier localization
  - Build successful, app verified running in iOS simulator
- **CRITICAL-006**: Implemented calculateDayIndex() to properly calculate day index based on event start date from Remote Config:
  - Added `remoteConfigService` property to ScheduleViewModel
  - Added `setRemoteConfigService()` method to inject dependency
  - Implemented day calculation using ISO-8601 date parsing with fallback
  - Clamped result to valid range [0, 7] for 8-day event
  - Updated ScheduleView to pass Remote Config service on appear
  - Build verified successful
  - Created `ScheduleViewModel.swift` - ViewModel and ScheduleState enum
  - Created `SectionListItem.swift` - List item component
  - Created `ScheduleDayTab.swift` - Day tab and DayTabItem components
  - Created `SectionDetailView.swift` - Detail view component
  - Created `ScheduleFilterView.swift` - Filter view and filter row components
  - Fixed ScheduleRepository.kt bug: Changed `XcampDatabase.Section` to correct `cz.krutsche.xcamp.shared.db.Section` import
  - Fixed ScheduleRepository.kt bug: Changed `XcampDatabase` parameter type to `XcampDatabaseQueries` in `toDbInsert()`
  - Fixed ScheduleRepository.kt bug: Removed incorrect `suspend` modifier from `toDbInsert()` function
  - Build successful, app running in iOS simulator
- **CRITICAL-005**: Fixed hardcoded Czech strings in Schedule components:
  - Updated `Strings.kt` to add SECTIONTYPE_*, DAYS_*, and DETAIL_* constants with proper naming
  - Updated `ScheduleView.swift` to use `Strings.ScheduleDays.shared.DAYS_*` for day names
  - Updated `SectionDetailView.swift` to use `Strings.ScheduleDetail.shared.DETAIL_*` for labels
  - Updated `SectionTypeExtensions.swift` to use `Strings.ScheduleSectionType.shared.SECTIONTYPE_*` for type labels
  - All hardcoded strings now use Strings.kt for consistency and easier localization
  - Build successful, app verified running in iOS simulator
- **HIGH-006**: Verified LinkTile.swift already uses `.primary.opacity(0.8)` for dark mode compatibility - no changes needed
- **HIGH-007**: Added nil-safe URL wrappers for AsyncImage in Speakers and Places views:
  - Added `imageUrl` computed property in SpeakerListItem (SpeakersView.swift:148-150)
  - Added `imageUrl` computed property in SpeakerDetailView (SpeakersView.swift:195-197)
  - Added `imageUrl` computed property in PlaceListItem (PlacesView.swift:147-149)
  - Added `imageUrl` computed property in PlaceDetailView (PlacesView.swift:215-217)
  - Replaced unsafe `URL(string: imageUrl ?? "")` with nil-safe computed property
  - Build verified successful
- **MEDIUM-001**: Extracted duplicate AsyncImage phase handling into reusable components:
  - Created `iosApp/iosApp/components/common/AsyncImageWithFallback.swift` with two components:
    - `AsyncImageWithFallback` - for thumbnail images (80x80), handles all phases with fallback icon
    - `HeroAsyncImageWithFallback` - for hero/detail view images, includes gradient overlay
  - Updated `SpeakerListItem.speakerImage` to use AsyncImageWithFallback (reduced from 20 to 5 lines)
  - Updated `SpeakerDetailView.speakerHeroImage` to use HeroAsyncImageWithFallback (reduced from 38 to 5 lines)
  - Updated `PlaceListItem.placeImage` to use AsyncImageWithFallback (reduced from 20 to 5 lines)
  - Updated `PlaceDetailView.placeHeroImage` to use HeroAsyncImageWithFallback (reduced from 38 to 5 lines)
  - Total code reduction: ~70 lines of duplicated code eliminated
  - Build successful, app verified running in iOS simulator

## Notes

### Dependencies Between Tasks
- **CRITICAL-005 depends on HIGH-008**: SectionType extensions should be created before fixing hardcoded strings
- **CRITICAL-004 enables HIGH-005**: Splitting files makes adding previews easier
- **MEDIUM-001 requires completion of**: AsyncImage component can be created after fixing nil-safe URLs (HIGH-007)

### Good Patterns Found
- Proper repository pattern with BaseRepository extension
- Good timeout protection via FirestoreService inheritance
- Excellent localization practices (Strings.kt)
- Comprehensive SwiftUI previews in most places
- Clean Result<T> error handling pattern
- Proper @MainActor and async/await usage

### Code Quality Grade: B+ (Good with known issues)
The codebase is well-architected but has accumulated some technical debt during rapid feature development. The critical issues are straightforward fixes that don't require architectural changes.

### Current Status (Mon Jan 19 23:12 CET 2026)
**Progress: 15/20 tasks complete (75%)**

**Completed:**
- All 6 Critical issues (CRITICAL-001 through CRITICAL-006)
- All 8 High priority issues (HIGH-001 through HIGH-008)

**Remaining:**
- 4 Medium priority issues (MEDIUM-002 through MEDIUM-005)
- 1 Low priority issue (LOW-001)

The codebase is now in a much better state with all critical and high-priority issues resolved. The remaining medium/low priority tasks are optional improvements that can be addressed in future iterations.

### Estimated Effort
- Phase 1 (Critical): 2-3 hours
- Phase 2 (Architecture): 4-5 hours
- Phase 3 (Functionality): 2-3 hours
- Phase 4 (Dev Experience): 3-4 hours
- Phase 5 (Code Quality): 4-5 hours

**Total**: ~15-20 hours for complete remediation

### Files Requiring Changes

| File | Issues | Priority |
|------|--------|----------|
| `AppConfigService.kt` | 2 | Critical, Medium |
| `ScheduleRepository.kt` | 2 | Critical |
| `ScheduleView.swift` | 8 | Critical, High, High, High, Medium |
| `SpeakersView.swift` | 3 | High, Medium, High |
| `PlacesView.swift` | 2 | High, Medium |
| `LinkTile.swift` | 1 | High |
| `Strings.kt` | 1 | Medium |
| `SectionType+Extensions.swift` | 1 | High (new file) |
| `AsyncImageWithFallback.swift` | 1 | Medium (new file) |
| `Date+Extensions.swift` | 1 | Medium (new file) |

## Next Steps

1. Review and approve this task list
2. Begin Phase 1 implementation (Critical fixes)
3. Complete each phase in order
4. Test changes after each phase
5. Create single comprehensive commit when all tasks complete
