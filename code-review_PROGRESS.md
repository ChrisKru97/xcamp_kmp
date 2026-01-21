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

- [ ] **TASK-008**: Remove experimental Time API opt-in (HIGH)
  - File: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/ScheduleService.kt`
  - Use stable APIs if available

### Phase 2: Medium Priority Fixes

- [ ] **TASK-009**: Create generic Service base class (MEDIUM)
  - Extract common pattern from PlacesService, SpeakersService, ScheduleService
  - New file: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/config/RepositoryService.kt`

- [ ] **TASK-010**: Add error logging to all background sync methods (MEDIUM)
  - Files: `iosApp/iosApp/AppViewModel.swift`
  - Replace silent error handling with proper logger.error() calls

- [ ] **TASK-011**: Fix HeroAsyncImageWithFallback to use fallbackIconName (MEDIUM)
  - File: `iosApp/iosApp/components/common/AsyncImageWithFallback.swift`
  - Implement parameter usage in CachedAsyncImage

- [ ] **TASK-012**: Extract duplicate imageUrl computed property (MEDIUM)
  - Files: `iosApp/iosApp/views/SpeakersView.swift`, `PlacesView.swift`
  - Create View extension for shared logic

- [ ] **TASK-013**: Move hardcoded strings to Strings.kt (MEDIUM)
  - Files: `iosApp/iosApp/ContentView.swift`, `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt`
  - Add: "More", "More Options", "Cancel"

- [ ] **TASK-014**: Extract color constants for schedule filters (MEDIUM)
  - File: `iosApp/iosApp/utils/SectionTypeExtensions.swift`
  - Create design system colors

- [ ] **TASK-015**: Fix mixed logging in AppViewModel (MEDIUM)
  - File: `iosApp/iosApp/AppViewModel.swift`
  - Replace all print() with logger.debug/error/info

- [ ] **TASK-016**: Add accessibility labels to More tab buttons (MEDIUM)
  - File: `iosApp/iosApp/ContentView.swift`
  - Add .accessibilityLabel() modifiers

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

- **TASK-001**: Verified debug override was already removed (commit 210a290)
- **TASK-002**: Fixed hashCode() negative ID issue - added `kotlin.math.abs()` wrapper in Speaker.kt and Place.kt generateId() methods
- **TASK-003**: Fixed ImageCache memory leak - added thread-safe concurrent queue with barrier flags and cleanupExpiredEntries() method
- **TASK-004**: Fixed toggleFavorite to return Result<Unit> - wrapped repository call in try-catch for proper error feedback
- **TASK-005**: Extracted duplicate image URL fetching logic - created generic populateImageUrls() extension in HasImage.kt
- **TASK-006**: Fixed unsafe URL handling in openInMaps() - replaced `?? ""` fallback with proper guard statements for addingPercentEncoding and URL validation
- **TASK-007**: Fixed tab selection infinite loop risk - removed flag reset from early return, changed to synchronous state assignment, flag resets after state update completes

