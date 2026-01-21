# Progress: code-review

Started: Tue Jan 20 18:44:50 CET 2026

## Status

IN_PROGRESS

## Analysis

Reviewed **60 commits** from `7ed9af7` (swiftui restricted mode refactor) to `5cfc2bc` (current HEAD).

### Codebase Overview

The XcamP KMP project follows clean architecture with:
- **Shared Module**: Kotlin business logic (data/, domain/, localization/)
- **Android Module**: Jetpack Compose UI
- **iOS Module**: SwiftUI views and components

Key patterns:
- Repository pattern with BaseRepository for Firestore sync
- Service pattern (PlacesService, SpeakersService, ScheduleService)
- MVVM with ObservableObject ViewModels (iOS)
- SQLDelight for local caching
- Result<T> error handling

### Issues Summary by Severity

| Severity | Count | Category |
|----------|-------|----------|
| CRITICAL | 2 | Debug overrides, experimental APIs |
| HIGH | 8 | Memory leaks, DRY violations, unsafe unwraps |
| MEDIUM | 25 | Hardcoded strings, silent errors, code duplication |
| LOW | 18 | Missing documentation, minor inconsistencies |

### Cross-Cutting Issues Identified

#### 1. Service Pattern Duplication (DRY Violation)
**Affected Commits:** e19e8f7, ebbc0bc, e801d9a, 3edefb6, c841508

PlacesService, SpeakersService, and ScheduleService all follow identical pattern:
```kotlin
class SomeService {
    private val databaseManager: DatabaseManager by lazy { DatabaseFactory.getDatabaseManager() }
    private val repository: SomeRepository by lazy { ... }
    // identical structure
}
```

#### 2. Silent Error Handling in Background Sync
**Affected Commits:** ee8505c, 2ddbd99, 3edefb6, d84cddf

All background sync methods silently swallow errors without logging:
```swift
do {
    _ = try await service.refresh()
} catch {
    // Silently handle errors
}
```

#### 3. Hardcoded Strings Not in Strings.kt
**Affected Commits:** d84cddf (fixed later), b1202a6, 755d797, 7647522

- "More", "More Options", "Cancel" in ContentView
- Czech strings in various views (later fixed)
- Schedule filter colors use magic RGB values

#### 4. Image URL Fetching Duplication
**Affected Commits:** d081694, fb4e42c, 210c5a9

Same pattern duplicated in SpeakersRepository and PlacesRepository:
```kotlin
val withUrls = entities.map { entity ->
    if (entity.image != null) {
        val urlResult = storageService.getDownloadUrl(entity.image)
        entity.copy(imageUrl = urlResult.getOrNull())
    } else {
        entity
    }
}
```

#### 5. Memory Leak Risk in ImageCache
**Affected Commit:** a0dd98d

`storageTimes` dictionary grows unbounded, no cleanup of expired entries.

#### 6. hashCode() Negative ID Issue
**Affected Commits:** 2f1eef2, 305f444

Speaker and Place use `hashCode()` for ID generation, can return negative values.

#### 7. Duplicate ViewModels
**Affected Commit:** 2ddbd99

PlacesViewModel and SpeakersViewModel are identical except for naming.

#### 8. DRY Violation in Frame Modifiers
**Affected Commits:** 22118ca, 20b2ef9

Duplicate `.frame(maxWidth: .infinity)` modifiers throughout Schedule components.

#### 9. Mixed Logging Approaches
**Affected Commits:** a8a4c42

AppViewModel uses both `print()` and `Logger` inconsistently.

#### 10. toggleFavorite Returns Unit
**Affected Commit:** e801d9a

No error feedback for favorite toggle operations.

#### 11. HeroAsyncImageWithFallback Ignores Parameter
**Affected Commit:** 99231aa

`fallbackIconName` parameter accepted but never used.

#### 12. Unsafe URL Force Unwrap
**Affected Commit:** d84cddf

URL creation with `?? ""` could create invalid URLs.

#### 13. Tab Selection Infinite Loop Risk
**Affected Commit:** 7647522

`DispatchQueue.main.async` modifying selectedTabIndex could trigger onChange again.

#### 14. Debug Override in Production
**Affected Commit:** 2ddbd99

Active debug code forcing PRE_EVENT mode.

#### 15. Experimental Time API
**Affected Commit:** e801d9a

Using `kotlin.time.ExperimentalTime` in production.

---

## Task List

### Phase 1: Critical & High Priority Fixes

- [x] **TASK-001**: Remove debug override from AppConfigService (CRITICAL)
  - Already completed in commit 210a290

- [x] **TASK-002**: Fix hashCode() negative ID issue in Speaker and Place (HIGH)
  - Fixed using `kotlin.math.abs(uid.hashCode()).toLong()`

- [x] **TASK-003**: Fix ImageCache memory leak (HIGH)
  - Added thread-safe concurrent queue with barrier flags for storageTimes access
  - Added cleanupExpiredEntries() method to remove expired/orphaned entries
  - Added cleanup call in XcampApp.init() on app launch

- [x] **TASK-004**: Fix toggleFavorite to return Result<Unit> (HIGH)
  - Wrapped repository call in try-catch returning Result<Unit>
  - Swift callers continue to work with existing error handling patterns

- [x] **TASK-005**: Extract duplicate image URL fetching logic (HIGH)
  - Created HasImage.kt with generic populateImageUrls() extension function
  - Updated SpeakersRepository and PlacesRepository to use the shared extension
  - Eliminated ~30 lines of duplicate code

- [x] **TASK-006**: Fix unsafe URL force unwrap in PlacesView (HIGH)
  - Replaced `?? ""` fallback in openInMaps() with proper guard statements
  - Now uses guard for both addingPercentEncoding and URL validation

- [x] **TASK-007**: Fix tab selection infinite loop risk (HIGH)
  - File: `iosApp/iosApp/ContentView.swift`
  - Removed flag reset from early return to prevent race condition
  - Changed async dispatch to synchronous state assignment
  - Flag now resets after state update completes

- [x] **TASK-008**: Remove experimental Time API opt-in (HIGH) - NOT APPLICABLE
  - Finding: `kotlin.time.Instant` is STILL EXPERIMENTAL in Kotlin 2.2.20
  - The opt-in annotation is REQUIRED and cannot be removed
  - Alternative: Could migrate to `kotlinx.datetime.Instant` (stable) but this is a larger refactoring
  - Affected files: ScheduleService.kt, ScheduleRepository.kt, Section.kt, Rating.kt, News.kt, CountdownUtils.kt, AppConfigService.kt
  - Decision: Keep current implementation as it works correctly; the experimental API is stable in practice

### Phase 2: Medium Priority Fixes

- [x] **TASK-009**: Create generic Service base class (MEDIUM)
  - Created `RepositoryService.kt` base class with lazy initialization pattern
  - Refactored PlacesService, SpeakersService, ScheduleService to extend RepositoryService
  - Reduced code duplication by ~40 lines across three service files

- [ ] **TASK-010**: Add error logging to all background sync methods (MEDIUM) - BLOCKED
  - Files: `iosApp/iosApp/AppViewModel.swift`
  - Issue: Swift 6 concurrency compiler limitation prevents replacing `print()` with `logger` in `Task(priority:)` closures
  - Error: "type of expression is ambiguous without a type annotation" when accessing Logger
  - Current code uses `print()` which works correctly; migrating to Logger requires further investigation
  - Note: This is a low-priority improvement since errors are still being logged to console

- [x] **TASK-011**: Fix HeroAsyncImageWithFallback to use fallbackIconName (MEDIUM)
  - File: `iosApp/iosApp/components/common/AsyncImageWithFallback.swift`
  - Added `fallbackIconName` parameter to `CachedAsyncImage` with default value "photo"
  - Updated `AsyncImageWithFallback` and `HeroAsyncImageWithFallback` to pass `fallbackIconName` to `CachedAsyncImage`
  - The fallback icon is now properly used when image fails to load or is nil

- [x] **TASK-012**: Extract duplicate imageUrl computed property (MEDIUM)
  - Created `EntityExtensions.swift` with `HasImageUrl` protocol
  - Added `imageUrlURL` computed property extension for Speaker and Place
  - Updated `SpeakersView.swift`: Removed duplicate `imageUrl` properties from `SpeakerListItem` and `SpeakerDetailView`
  - Updated `PlacesView.swift`: Removed duplicate `imageUrl` properties from `PlaceListItem` and `PlaceDetailView`
  - Eliminated ~12 lines of duplicate code

- [x] **TASK-013**: Move hardcoded strings to Strings.kt (MEDIUM)
  - Files: `iosApp/iosApp/ContentView.swift`, `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt`
  - Added: Strings.Tabs.MORE ("Více"), Strings.Common.MORE_OPTIONS ("Další možnosti"), Strings.Common.CANCEL ("Zrušit")
  - Updated ContentView.swift to use the new strings

- [x] **TASK-014**: Extract color constants for schedule filters (MEDIUM)
  - File: `iosApp/iosApp/utils/ColorExtension.swift`
  - Created `Color.Section` struct with color constants for main, internal, gospel, food, other
  - Updated SectionTypeExtensions.swift to use the new color constants
  - Used backtick escaping for `internal` keyword (Swift reserved word)

- [ ] **TASK-015**: Fix mixed logging in AppViewModel (MEDIUM) - BLOCKED (same issue as TASK-010)
  - File: `iosApp/iosApp/AppViewModel.swift`
  - Issue: Swift 6 concurrency compiler limitation prevents replacing `print()` with `logger` in `Task(priority:)` closures
  - Same issue as TASK-010 - see notes section for details
  - The file already uses `logger` consistently where possible

- [x] **TASK-016**: Add accessibility labels to More tab buttons (MEDIUM)
  - File: `iosApp/iosApp/ContentView.swift`
  - Added .accessibilityLabel() modifiers to Media, Info, and Cancel buttons
  - Buttons now properly accessible with VoiceOver using localized strings

- [ ] **TASK-017**: Add validation to fromFirestoreData factory methods (MEDIUM)
  - Files: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/domain/model/Speaker.kt`, `Place.kt`
  - Validate required fields

### Phase 3: Low Priority & Documentation

- [ ] **TASK-018**: Refactor duplicate frame modifiers (LOW)
  - Files: `iosApp/iosApp/components/schedule/ScheduleDayTab.swift`, `SectionListItem.swift`, `ScheduleView.swift`
  - Extract to shared view modifier

- [ ] **TASK-019**: Add KDoc to all public service methods (LOW)
  - Files: All service classes
  - Document parameters and return types

- [ ] **TASK-020**: Add SwiftUI preview for CachedAsyncImage (LOW)
  - File: `iosApp/iosApp/components/common/AsyncImageWithFallback.swift`

- [ ] **TASK-021**: Document KMP property naming conflicts (LOW)
  - Files: `iosApp/iosApp/views/PlacesView.swift`, `SpeakersView.swift`
  - Add comment explaining description_ usage

- [ ] **TASK-022**: Consider generic ViewModel for list views (LOW)
  - Create `ListViewModel<T>` protocol to eliminate duplication

- [ ] **TASK-023**: Standardize error handling patterns (LOW)
  - Review and standardize Result vs exception usage

---

## Notes

### Architecture Observations

**Positive:**
- Clean separation of concerns between shared and platform code
- Good use of Result<T> types for error handling
- Comprehensive offline-first architecture with SQLite caching
- Good SwiftUI preview coverage (after fixes)
- Consistent repository pattern implementation

**Needs Improvement:**
- Heavy code duplication in service layer
- Silent error handling throughout background sync
- Inconsistent logging (print vs Logger)
- Some hardcoded strings not centralized
- Memory management in ImageCache needs attention

### Testing Recommendations

After fixes are implemented:
1. Run iOS app with Instruments to verify memory leak fix
2. Test favorite toggle with network errors to verify error handling
3. Test tab switching to verify no infinite loop
4. Test with negative hashCode values to verify ID generation fix
5. Test background sync failures to verify error logging

---

## Next Steps

1. Implement Phase 1 fixes (CRITICAL and HIGH priority)
2. Build and test after each fix
3. Implement Phase 2 fixes (MEDIUM priority)
4. Implement Phase 3 fixes (LOW priority)
5. Final build and comprehensive testing
6. Single consolidated commit with all fixes

---

## Completed This Iteration

- **TASK-016**: Add accessibility labels to More tab buttons - added `.accessibilityLabel()` modifiers to Media, Info, and Cancel buttons in MorePopoverContentView (ContentView.swift)
- **TASK-015**: Marked as blocked (same Swift 6 concurrency issue as TASK-010)

## Notes

### TASK-010 Blocked - Swift 6 Concurrency Issue
Attempting to replace `print()` with `logger.error()` in AppViewModel's background sync methods (syncPlacesInBackground, syncSpeakersInBackground, syncScheduleInBackground) fails with Swift 6 concurrency compiler error: "type of expression is ambiguous without a type annotation".

This occurs when accessing `Logger` from within `Task(priority:)` closures with `[weak self]` capture in an `@MainActor` class. Multiple approaches were attempted:
- Using `self.logger` - fails with type ambiguity
- Capturing logger in capture list `[weak self, logger]` - fails with type ambiguity
- Creating local Logger instance inside Task - fails with type ambiguity
- Using `@MainActor` annotation on closure - fails with type ambiguity
- Using explicit `Task<Void, Never>` type annotation - fails with type ambiguity

Current code uses `print()` which works correctly. This is a low-priority improvement since errors are still being logged to console.

### TASK-015 Also Blocked - Same Issue as TASK-010
TASK-015 "Fix mixed logging in AppViewModel" is the same issue as TASK-010. The file already uses `logger` consistently in all places where it's possible (outside of `Task(priority:)` closures). The remaining `print()` statements in background sync methods cannot be replaced with `logger` due to the Swift 6 concurrency compiler limitation described above.

### TASK-015 Status Update
TASK-015 is now marked as blocked (same as TASK-010) due to Swift 6 concurrency compiler limitations. The current implementation uses `print()` inside `Task(priority:)` closures, which is a reasonable workaround given the compiler constraints.

## Notes

### TASK-010 Blocked - Swift 6 Concurrency Issue
Attempting to replace `print()` with `logger.error()` in AppViewModel's background sync methods (syncPlacesInBackground, syncSpeakersInBackground, syncScheduleInBackground) fails with Swift 6 concurrency compiler error: "type of expression is ambiguous without a type annotation".

This occurs when accessing `Logger` from within `Task(priority:)` closures with `[weak self]` capture in an `@MainActor` class. Multiple approaches were attempted:
- Using `self.logger` - fails with type ambiguity
- Capturing logger in capture list `[weak self, logger]` - fails with type ambiguity
- Creating local Logger instance inside Task - fails with type ambiguity
- Using `@MainActor` annotation on closure - fails with type ambiguity
- Using explicit `Task<Void, Never>` type annotation - fails with type ambiguity

Current code uses `print()` which works correctly. This is a low-priority improvement since errors are still being logged to console.
- **TASK-002**: Fixed hashCode() negative ID issue - added `kotlin.math.abs()` wrapper in Speaker.kt and Place.kt generateId() methods
- **TASK-003**: Fixed ImageCache memory leak - added thread-safe concurrent queue with barrier flags and cleanupExpiredEntries() method
- **TASK-004**: Fixed toggleFavorite to return Result<Unit> - wrapped repository call in try-catch for proper error feedback
- **TASK-005**: Extracted duplicate image URL fetching logic - created generic populateImageUrls() extension in HasImage.kt
- **TASK-006**: Fixed unsafe URL handling in openInMaps() - replaced `?? ""` fallback with proper guard statements for addingPercentEncoding and URL validation
- **TASK-007**: Fixed tab selection infinite loop risk - removed flag reset from early return, changed to synchronous state assignment, flag resets after state update completes
- **TASK-008**: Researched experimental Time API removal - NOT APPLICABLE as `kotlin.time.Instant` is still experimental in Kotlin 2.2.20; the opt-in is required and correct

