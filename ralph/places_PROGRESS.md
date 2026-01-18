# Progress: places

## Status
IN_PROGRESS

## Task List

### Shared Kotlin Layer
- [x] Create DatabaseFactory expect/actual for accessing DatabaseManager
- [x] Create PlacesService for iOS interop (in commonMain/kotlin/data/config)
- [x] Add getPlacesService() getter to iOS AppViewModel
- [ ] Initialize Places sync on app open (lazy background sync)

### iOS UI Layer
- [ ] Implement PlacesView with list display and pull-to-refresh
- [ ] Create PlaceListItem component with glass morphism design
- [ ] Create PlaceDetailView with hero image and description
- [ ] Add Apple Maps integration (open in Maps button)
- [ ] Implement image loading with Firebase Storage
- [ ] Add loading/empty/error states
- [ ] Add navigation between list and detail views

### Tab Integration
- [ ] Enable Places tab in full mode (debug override for now)

## Completed This Iteration

### Shared Kotlin Layer Implementation
- **DatabaseFactory**: Created expect/actual pattern to access DatabaseManager from iOS/Android
  - commonMain: expect object DatabaseFactory with getDatabaseManager()
  - iosMain: actual object using lazy initialization with DatabaseDriverFactory
  - androidMain: actual object with init(context) for Android Context requirement
- **PlacesService**: Created service class in commonMain/kotlin/data/config
  - getAllPlaces(): List<Place>
  - getPlaceById(id: Long): Place?
  - syncFromFirestore(): Result<Unit>
  - refreshPlaces(): Result<List<Place>> (syncs then returns all places)
- **AppViewModel**: Added getPlacesService() getter following existing service pattern
- **Android Integration**: Updated XcampApplication to call DatabaseFactory.init(this)

### Notes

**Note on Koin DI**: The original task mentioned "Register PlacesRepository in Koin DI module", but the app doesn't actually use Koin for service injection. Instead, it uses the factory pattern (DatabaseFactory, service getters in AppViewModel), which is consistent with how other services (LinksService, RemoteConfigService) work.

### Discovery: Shared Layer Status
Most shared Kotlin logic is already complete:
- Place model exists with all fields
- SQLDelight schema is complete
- PlacesRepository implementation exists
- AppTab.PLACES enum configured

### Discovery: Flutter Reference
The Flutter implementation shows:
- Hero image for first place (highest priority)
- List of other places below
- Glass morphism cards with 0.18 opacity
- Pull-to-refresh functionality
- Map integration via maps_launcher
- Staggered entrance animations
- Link support in descriptions

### Design Requirements
- Modern, minimalistic iOS 16+ liquid glass design
- Glass morphism cards with blur effects
- Firebase Storage image loading
- Apple Maps integration for coordinates
