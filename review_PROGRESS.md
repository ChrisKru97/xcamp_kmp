# Progress: review

Started: Mon Feb 16 23:37:13 CET 2026

## Status

IN_PROGRESS

## Analysis

### Scope

The review covers:
1. **Kotlin shared module**: commonMain (49 files), androidMain (10 files), iosMain (10 files)
2. **iOS app**: 53 Swift files
3. **Android app**: 2 Kotlin source files

**Total**: 124 files to review

### Review Strategy

Per plan requirements:
- Review just and only ONE file at a time (no parallel reviews)
- DONT TAKE MORE THEN ONE FILE FOR THE REVIEW!!!
- For each file: Review → Apply fixes → Move to next file
- Use skills for specialized reviews (kotlin-multiplatform-reviewer, ios-reviewer)
- Check for: problems, leaks, modern API usage, simplicity, DRY principle

### File Inventory

#### Kotlin Shared Module - commonMain (49 files)

**Root**:
1. Platform.kt

**cz.krutsche.xcamp.shared.db**:
2. DatabaseDriverFactory.kt

**cz.krutsche.xcamp.shared.domain.model**:
3. News.kt
4. Place.kt
5. Rating.kt
6. Speaker.kt
7. Section.kt
8. Song.kt

**cz.krutsche.xcamp.shared.utils**:
9. CountdownUtils.kt
10. LinkUtils.kt
11. MapOpener.kt
12. UrlOpener.kt
13. VersionUtils.kt

**cz.krutsche.xcamp.shared.consts**:
14. InfoLinkData.kt
15. MediaLinkData.kt
16. StoragePaths.kt

**cz.krutsche.xcamp.shared.data.config**:
17. AppConfigService.kt
18. AppInitializer.kt
19. AppPreferences.kt
20. LinksService.kt
21. NotificationPreferences.kt
22. RemoteConfigCache.kt
23. RepositoryService.kt
24. ScheduleFilter.kt
25. ScheduleService.kt
26. SongsService.kt
27. PlacesService.kt
28. SpeakersService.kt

**cz.krutsche.xcamp.shared.data.local**:
29. DatabaseManager.kt
30. EntityType.kt
31. SchemaMigrations.kt

**cz.krutsche.xcamp.shared.data.repository**:
32. AppError.kt
33. BaseRepository.kt
34. PlacesRepository.kt
35. ScheduleRepository.kt
36. SongsRepository.kt
37. SpeakersRepository.kt
38. UsersRepository.kt

**cz.krutsche.xcamp.shared.data.network**:
39. ConnectivityObserver.kt

**cz.krutsche.xcamp.shared.data.notification**:
40. NotificationPermissionStatus.kt
41. NotificationService.kt

**cz.krutsche.xcamp.shared.data.firebase**:
42. Analytics.kt
43. AnalyticsEvents.kt
44. AuthService.kt
45. CrashlyticsService.kt
46. FirestoreService.kt
47. RemoteConfigService.kt
48. StorageService.kt

**cz.krutsche.xcamp.shared.data.service**:
49. ServiceFactory.kt
50. DatabaseFactory.kt
51. CacheConstants.kt

**cz.krutsche.xcamp.shared.localization**:
52. Strings.kt

#### Kotlin Shared Module - androidMain (10 files)

53. DatabaseFactory_android.kt
54. Platform.android.kt
55. DatabaseDriverFactory.android.kt
56. ConnectivityObserver.android.kt
57. MapOpener.android.kt
58. UrlOpener.android.kt
59. NotificationService.android.kt
60. CrashlyticsService.android.kt
61. AppPreferences.android.kt
62. ServiceFactory_android.kt

#### Kotlin Shared Module - iosMain (10 files)

63. DatabaseFactory_ios.kt
64. Platform.ios.kt
65. DatabaseDriverFactory.ios.kt
66. ConnectivityObserver.ios.kt
67. MapOpener.ios.kt
68. UrlOpener.ios.kt
69. NotificationService.ios.kt
70. CrashlyticsService.ios.kt
71. AppPreferences.ios.kt
72. ServiceFactory_ios.kt

#### Android App (2 files)

73. MainActivity.kt
74. XcampApplication.kt

#### iOS App - Utils (19 files)

75. AppRouter.swift
76. EntityExtensions.swift
77. NotificationDelegate.swift
78. AppError.swift
79. MeshGradientBackground.swift
80. State.swift
81. TaskUtils.swift
82. SFSymbolCompat.swift
83. AppTab+Extensions.swift
84. DateFormatter+Shared.swift
85. LinkDataExtensions.swift
86. SectionTypeExtensions.swift
87. Button.swift
88. StateViews.swift
89. SwiftUIBackports.swift
90. Spacing.swift
91. PresentationDetentsBackport.swift
92. CrashlyticsHelper.swift
93. ColorExtension.swift
94. NavigationContainer.swift

#### iOS App - Components (30 files)

95. SplashView.swift
96. HomeHeaderView.swift
97. CountdownView.swift
98. MainInfoCard.swift
99. ScheduleFilterView.swift
100. SectionTypeBadge.swift
101. SectionListItem.swift
102. SectionDetailCards.swift
103. SectionSpeakersCard.swift
104. SectionLeaderCard.swift
105. SectionPlaceCard.swift
106. SectionDetailView.swift
107. CardUnavailableView.swift
108. SpeakerListItem.swift
109. SpeakerDetailView.swift
110. SpeakersViewModel.swift
111. PlaceListItem.swift
112. FullscreenImageView.swift
113. ArealHeroSection.swift
114. PlaceDetailView.swift
115. PlacesViewModel.swift
116. MediaGrid.swift
117. AppStatePicker.swift
118. ContactGrid.swift
119. EmergencyPill.swift
120. NotificationSettingsView.swift
121. KingfisherImageComponents.swift
122. IconProvider.swift
123. EntityDetailView.swift
124. ImageNameCard.swift
125. LinkTile.swift

#### iOS App - Views (8 files)

126. HomeView.swift
127. ScheduleView.swift
128. SpeakersContentView.swift
129. PlacesContentView.swift
130. SpeakersAndPlacesView.swift
131. MediaView.swift
132. RatingView.swift
133. InfoView.swift

#### iOS App - Root (3 files)

134. ContentView.swift
135. AppViewModel.swift
136. XcampApp.swift

## Task List

### Phase 1: Kotlin Shared - commonMain (52 files)

- [x] 1. Review & fix: Platform.kt
- [ ] 2. Review & fix: DatabaseDriverFactory.kt
- [ ] 3. Review & fix: News.kt
- [ ] 4. Review & fix: Place.kt
- [ ] 5. Review & fix: Rating.kt
- [ ] 6. Review & fix: Speaker.kt
- [ ] 7. Review & fix: Section.kt
- [ ] 8. Review & fix: Song.kt
- [ ] 9. Review & fix: CountdownUtils.kt
- [ ] 10. Review & fix: LinkUtils.kt
- [ ] 11. Review & fix: MapOpener.kt
- [ ] 12. Review & fix: UrlOpener.kt
- [ ] 13. Review & fix: VersionUtils.kt
- [ ] 14. Review & fix: InfoLinkData.kt
- [ ] 15. Review & fix: MediaLinkData.kt
- [ ] 16. Review & fix: StoragePaths.kt
- [ ] 17. Review & fix: AppConfigService.kt
- [ ] 18. Review & fix: AppInitializer.kt
- [ ] 19. Review & fix: AppPreferences.kt
- [ ] 20. Review & fix: LinksService.kt
- [ ] 21. Review & fix: NotificationPreferences.kt
- [ ] 22. Review & fix: RemoteConfigCache.kt
- [ ] 23. Review & fix: RepositoryService.kt
- [ ] 24. Review & fix: ScheduleFilter.kt
- [ ] 25. Review & fix: ScheduleService.kt
- [ ] 26. Review & fix: SongsService.kt
- [ ] 27. Review & fix: PlacesService.kt
- [ ] 28. Review & fix: SpeakersService.kt
- [ ] 29. Review & fix: DatabaseManager.kt
- [ ] 30. Review & fix: EntityType.kt
- [ ] 31. Review & fix: SchemaMigrations.kt
- [ ] 32. Review & fix: AppError.kt
- [ ] 33. Review & fix: BaseRepository.kt
- [ ] 34. Review & fix: PlacesRepository.kt
- [ ] 35. Review & fix: ScheduleRepository.kt
- [ ] 36. Review & fix: SongsRepository.kt
- [ ] 37. Review & fix: SpeakersRepository.kt
- [ ] 38. Review & fix: UsersRepository.kt
- [ ] 39. Review & fix: ConnectivityObserver.kt
- [ ] 40. Review & fix: NotificationPermissionStatus.kt
- [ ] 41. Review & fix: NotificationService.kt (expect)
- [ ] 42. Review & fix: Analytics.kt
- [ ] 43. Review & fix: AnalyticsEvents.kt
- [ ] 44. Review & fix: AuthService.kt
- [ ] 45. Review & fix: CrashlyticsService.kt (expect)
- [ ] 46. Review & fix: FirestoreService.kt
- [ ] 47. Review & fix: RemoteConfigService.kt
- [ ] 48. Review & fix: StorageService.kt
- [ ] 49. Review & fix: ServiceFactory.kt
- [ ] 50. Review & fix: DatabaseFactory.kt (expect)
- [ ] 51. Review & fix: CacheConstants.kt
- [ ] 52. Review & fix: Strings.kt

### Phase 2: Kotlin Shared - androidMain (10 files)

- [ ] 53. Review & fix: DatabaseFactory_android.kt
- [ ] 54. Review & fix: Platform.android.kt
- [ ] 55. Review & fix: DatabaseDriverFactory.android.kt
- [ ] 56. Review & fix: ConnectivityObserver.android.kt
- [ ] 57. Review & fix: MapOpener.android.kt
- [ ] 58. Review & fix: UrlOpener.android.kt
- [ ] 59. Review & fix: NotificationService.android.kt
- [ ] 60. Review & fix: CrashlyticsService.android.kt
- [ ] 61. Review & fix: AppPreferences.android.kt
- [ ] 62. Review & fix: ServiceFactory_android.kt

### Phase 3: Kotlin Shared - iosMain (10 files)

- [ ] 63. Review & fix: DatabaseFactory_ios.kt
- [ ] 64. Review & fix: Platform.ios.kt
- [ ] 65. Review & fix: DatabaseDriverFactory.ios.kt
- [ ] 66. Review & fix: ConnectivityObserver.ios.kt
- [ ] 67. Review & fix: MapOpener.ios.kt
- [ ] 68. Review & fix: UrlOpener.ios.kt
- [ ] 69. Review & fix: NotificationService.ios.kt
- [ ] 70. Review & fix: CrashlyticsService.ios.kt
- [ ] 71. Review & fix: AppPreferences.ios.kt
- [ ] 72. Review & fix: ServiceFactory_ios.kt

### Phase 4: Android App (2 files)

- [ ] 73. Review & fix: MainActivity.kt
- [ ] 74. Review & fix: XcampApplication.kt

### Phase 5: iOS App - Utils (19 files)

- [ ] 75. Review & fix: AppRouter.swift
- [ ] 76. Review & fix: EntityExtensions.swift
- [ ] 77. Review & fix: NotificationDelegate.swift
- [ ] 78. Review & fix: AppError.swift
- [ ] 79. Review & fix: MeshGradientBackground.swift
- [ ] 80. Review & fix: State.swift
- [ ] 81. Review & fix: TaskUtils.swift
- [ ] 82. Review & fix: SFSymbolCompat.swift
- [ ] 83. Review & fix: AppTab+Extensions.swift
- [ ] 84. Review & fix: DateFormatter+Shared.swift
- [ ] 85. Review & fix: LinkDataExtensions.swift
- [ ] 86. Review & fix: SectionTypeExtensions.swift
- [ ] 87. Review & fix: Button.swift
- [ ] 88. Review & fix: StateViews.swift
- [ ] 89. Review & fix: SwiftUIBackports.swift
- [ ] 90. Review & fix: Spacing.swift
- [ ] 91. Review & fix: PresentationDetentsBackport.swift
- [ ] 92. Review & fix: CrashlyticsHelper.swift
- [ ] 93. Review & fix: ColorExtension.swift
- [ ] 94. Review & fix: NavigationContainer.swift

### Phase 6: iOS App - Components (30 files)

- [ ] 95. Review & fix: SplashView.swift
- [ ] 96. Review & fix: HomeHeaderView.swift
- [ ] 97. Review & fix: CountdownView.swift
- [ ] 98. Review & fix: MainInfoCard.swift
- [ ] 99. Review & fix: ScheduleFilterView.swift
- [ ] 100. Review & fix: SectionTypeBadge.swift
- [ ] 101. Review & fix: SectionListItem.swift
- [ ] 102. Review & fix: SectionDetailCards.swift
- [ ] 103. Review & fix: SectionSpeakersCard.swift
- [ ] 104. Review & fix: SectionLeaderCard.swift
- [ ] 105. Review & fix: SectionPlaceCard.swift
- [ ] 106. Review & fix: SectionDetailView.swift
- [ ] 107. Review & fix: CardUnavailableView.swift
- [ ] 108. Review & fix: SpeakerListItem.swift
- [ ] 109. Review & fix: SpeakerDetailView.swift
- [ ] 110. Review & fix: SpeakersViewModel.swift
- [ ] 111. Review & fix: PlaceListItem.swift
- [ ] 112. Review & fix: FullscreenImageView.swift
- [ ] 113. Review & fix: ArealHeroSection.swift
- [ ] 114. Review & fix: PlaceDetailView.swift
- [ ] 115. Review & fix: PlacesViewModel.swift
- [ ] 116. Review & fix: MediaGrid.swift
- [ ] 117. Review & fix: AppStatePicker.swift
- [ ] 118. Review & fix: ContactGrid.swift
- [ ] 119. Review & fix: EmergencyPill.swift
- [ ] 120. Review & fix: NotificationSettingsView.swift
- [ ] 121. Review & fix: KingfisherImageComponents.swift
- [ ] 122. Review & fix: IconProvider.swift
- [ ] 123. Review & fix: EntityDetailView.swift
- [ ] 124. Review & fix: ImageNameCard.swift
- [ ] 125. Review & fix: LinkTile.swift

### Phase 7: iOS App - Views (8 files)

- [ ] 126. Review & fix: HomeView.swift
- [ ] 127. Review & fix: ScheduleView.swift
- [ ] 128. Review & fix: SpeakersContentView.swift
- [ ] 129. Review & fix: PlacesContentView.swift
- [ ] 130. Review & fix: SpeakersAndPlacesView.swift
- [ ] 131. Review & fix: MediaView.swift
- [ ] 132. Review & fix: RatingView.swift
- [ ] 133. Review & fix: InfoView.swift

### Phase 8: iOS App - Root (3 files)

- [ ] 134. Review & fix: ContentView.swift
- [ ] 135. Review & fix: AppViewModel.swift
- [ ] 136. Review & fix: XcampApp.swift

## Completed This Iteration

- Task 1 (Platform.kt expect/actual): Fixed hardcoded values, deprecated APIs, and TODO comments

## Notes

- Review order follows dependencies: models → utils → services → repositories → views
- Platform-specific implementations (androidMain/iosMain) reviewed after commonMain
- Skills to use per language: kotlin-multiplatform-reviewer, ios-reviewer
- Each task is: read file → review → apply fixes → check off

### Platform.kt Review Fixes (Task 1)

**Android (Platform.android.kt)**:
- Changed `Build.VERSION.BASE_OS` to `Build.VERSION.RELEASE_OR_CODENAME` (more reliable API)
- Replaced hardcoded `appVersion`/`buildNumber` with dynamic values from `PackageInfo` via `AppPreferences.context`
- Replaced hardcoded `buildType: "release"` with runtime debug flag detection using `ApplicationInfo.FLAG_DEBUGGABLE`
- Fixed deprecated `configuration.locales[0]` API - added version check for API 24+ (`Configuration.locales`)
- Updated `systemName` to include Android version: `"Android ${Build.VERSION.RELEASE}"`
- Removed TODO comments

**iOS (Platform.ios.kt)**:
- Replaced hardcoded `locale: "en_US"` with `NSLocale.currentLocale.toString()`
- Improved `buildType` detection to check both device name AND `DTPlatformName` from Info.plist
- Made properties consistent (using `get()` for all computed properties)
- Removed TODO comments

**Common (Platform.kt)**:
- No changes needed - clean expect/actual declaration
