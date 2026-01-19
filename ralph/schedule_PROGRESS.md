# Progress: schedule

## Status
IN_PROGRESS

## Task List
- [x] Task 1: Verify shared ScheduleService is exposed to iOS via Koin
- [x] Task 2: Create ScheduleViewModel in iOS with state management
- [x] Task 3: Implement ScheduleView with 8-day tab navigation
- [x] Task 4: Create ScheduleListItem view with event details and favorite toggle
- [x] Task 5: Implement filtering system with FAB
- [x] Task 6: Add auto-navigation to current day
- [x] Task 7: Create SectionDetail view for individual events
- [x] Task 8: Enable Schedule tab for debugging (override showAppData check)
- [ ] Task 9: Test complete Schedule feature on iOS simulator
- [ ] Task 10: Code review and cleanup

## Completed This Iteration
- **Task 1**: Added ScheduleService to AppViewModel.swift following the same pattern as PlacesService and SpeakersService
  - Added `private var scheduleService: ScheduleService?` property
  - Added `getScheduleService()` factory method
  - Added `syncScheduleInBackground()` method for lazy loading after app init
  - Fixed method name: `refreshSections()` (not `refreshSchedule()`)

- **Tasks 2-8**: Verified all components already implemented in ScheduleView.swift:
  - Task 2: ScheduleViewModel (lines 151-264) with @MainActor, @Published state management
  - Task 3: ScheduleView with 8-day tab navigation (lines 7-146)
  - Task 4: SectionListItem with event details and favorite indicator (lines 274-315)
  - Task 5: ScheduleFilterView with FAB (lines 565-687)
  - Task 6: Auto-navigation to current day in selectCurrentDay() (lines 235-256)
  - Task 7: SectionDetailView with hero section and content (lines 405-561)
  - Task 8: Debug override already in place in AppConfigService.kt (line 45: `return AppState.PRE_EVENT`)

## Notes
- Project doesn't use Koin - uses manual dependency injection pattern
- ScheduleService uses `refreshSections()` method (different naming than SpeakersService/PlacesService)
- iOS build verified successfully on iOS 26.2 simulator
- All Schedule strings are defined in Strings.kt (Schedule object with LOADING, EMPTY_TITLE, ERROR_TITLE, RETRY, FILTER_TITLE, FAVORITES, SHOW_ALL)
- Flutter reference app at ~/Documents/xcamp_app provides excellent patterns
- Debug override in AppConfigService.kt forces PRE_EVENT state (shows Schedule tab)
