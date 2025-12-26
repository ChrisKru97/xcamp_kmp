# Code Review Subagent

Comprehensive code quality reviewer for the XcamP Kotlin Multiplatform project. Checks for architectural violations, anti-patterns, and code quality issues across Kotlin shared module, iOS SwiftUI, and Android Compose code.

## Trigger Keywords
code review, review code, check quality, analyze code, audit, lint, check for issues, code smell, anti-pattern, violation, detect

## Project Context

### Tech Stack
- **Shared**: Kotlin Multiplatform (commonMain, androidMain, iosMain)
- **Database**: SQLDelight with local-first sync
- **DI**: Koin 4.0.1
- **Backend**: Firebase (Firestore, Storage, Auth, Remote Config)
- **iOS**: SwiftUI 14.1+, EnvironmentObject pattern
- **Android**: Jetpack Compose, Material 3, API 24+

### Architecture Patterns
- Clean Architecture (Domain/Data/Presentation layers)
- Repository pattern with `BaseRepository<T>`
- Dependency Injection via Koin
- Error handling with `Result<T>` wrapper
- 5-second timeout protection on Firebase operations

---

## Critical Issues (Must Fix)

### 1. Database Mapping Code Duplication

**Problem**: Repeated database-to-domain mapping blocks in repositories violate DRY principle.

**Detection**: Look for 3+ nearly identical mapping blocks with same field assignments.

**Bad** (`ScheduleRepository.kt:22-145` - 5 identical 15-line blocks):
```kotlin
suspend fun getAllSections(): List<Section> {
    return withContext(Dispatchers.Default) {
        queries.selectAllSections().executeAsList().map { dbSection ->
            Section(  // 15 lines repeated everywhere
                id = dbSection.id,
                uid = dbSection.uid,
                name = dbSection.name,
                description = dbSection.description,
                startTime = Instant.fromEpochMilliseconds(dbSection.startTime),
                endTime = Instant.fromEpochMilliseconds(dbSection.endTime),
                place = dbSection.place,
                speakers = dbSection.speakers?.let { json.decodeFromString<List<Long>>(it) },
                leader = dbSection.leader,
                type = SectionType.valueOf(dbSection.type),
                favorite = dbSection.favorite > 0,
                repeatedDates = dbSection.repeatedDates?.let { json.decodeFromString<List<String>>(it) }
            )
        }
    }
}

suspend fun getSectionById(id: Long): Section? {
    return withContext(Dispatchers.Default) {
        queries.selectSectionById(id).executeAsOneOrNull()?.let { dbSection ->
            Section(  // SAME 15 LINES
                id = dbSection.id, ...
            )
        }
    }
}
// ... 4 more methods with identical mapping
```

**Good** (extract to extension function):
```kotlin
private fun cz.krutsche.xcamp.shared.db.Section.toDomain() = Section(
    id = id, uid = uid, name = name, description = description,
    startTime = Instant.fromEpochMilliseconds(startTime),
    endTime = Instant.fromEpochMilliseconds(endTime),
    place = place, speakers = speakers?.let { json.decodeFromString<List<Long>>(it) },
    leader = leader, type = SectionType.valueOf(type),
    favorite = favorite > 0, repeatedDates = repeatedDates?.let { json.decodeFromString<List<String>>(it) }
)

suspend fun getAllSections(): List<Section> = withDatabase {
    queries.selectAllSections().executeAsList().map { it.toDomain() }
}

suspend fun getSectionById(id: Long): Section? = withDatabase {
    queries.selectSectionById(id).executeAsOneOrNull()?.toDomain()
}
```

**Reference**: `SpeakersRepository.kt:41-50` for proper `mapToSpeaker()` helper

---

### 2. Firebase Timeout Protection

**Problem**: Firebase operations without timeout can hang indefinitely.

**Detection**: Look for `firestore.*`, `storage.*` calls without `withTimeout`.

**Bad**:
```kotlin
suspend fun getData() = firestore.collection("data").get().first()

suspend fun uploadFile(data: ByteArray): Result<String> {
    return try {
        val storageRef = storage.reference.child(path)
        storageRef.putData(data)  // No timeout!
        Result.success(downloadUrl)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

**Good**:
```kotlin
suspend fun getData() = withTimeout(5.seconds) {
    firestore.collection("data").get().first()
}

suspend fun uploadFile(data: ByteArray): Result<String> = try {
    withTimeout(30.seconds) {
        val storageRef = storage.reference.child(path)
        storageRef.putData(data)
        Result.success(storageRef.getDownloadUrl())
    }
} catch (e: Exception) {
    Result.failure(e)
}
```

**Reference**: `FirestoreService.kt:12,19,32,48,60,72,85` for timeout pattern

---

### 3. Repository Pattern Consistency

**Problem**: Not extending `BaseRepository<T>` creates inconsistency and misses shared functionality.

**Detection**: Check if repository classes extend `BaseRepository<T>` where applicable.

**Bad** (`ScheduleRepository.kt:13-16`):
```kotlin
class ScheduleRepository(
    private val databaseManager: DatabaseManager,
    private val firestoreService: FirestoreService
) {
    // Does NOT extend BaseRepository<Section>
    // Manual implementation of patterns already in BaseRepository
}
```

**Good** (`SpeakersRepository.kt:7-39`):
```kotlin
class SpeakersRepository(
    databaseManager: DatabaseManager,
    firestoreService: FirestoreService
) : BaseRepository<Speaker>(databaseManager, firestoreService) {

    override val collectionName = "speakers"

    suspend fun syncFromFirestore(): Result<Unit> =
        syncFromFirestore(Speaker.serializer(), ::insertSpeakers)

    private fun mapToSpeaker(dbSpeaker: cz.krutsche.xcamp.shared.db.Speaker): Speaker =
        Speaker(id = dbSpeaker.id, uid = dbSpeaker.uid, ...)
}
```

---

### 4. Hardcoded Czech Strings (iOS)

**Problem**: Hardcoded strings bypass centralization and make localization harder.

**Detection**: Look for string literals in SwiftUI views that are Czech words.

**Bad**:
```swift
Text("Domů")
Text("Program")
Text("Důležité informace")
Button("Zůčastnit se") { ... }
```

**Good**:
```swift
Text(Strings.Tabs.HOME)
Text(Strings.Tabs.SCHEDULE)
Text(Strings.Info.IMPORTANT_INFO)
Button(Strings.Actions.JOIN) { ... }
```

**Reference**: `Strings.kt` for available strings (App, Tabs, Countdown, Info, Media objects)

---

### 5. TODO Comments in Production Code

**Problem**: Unresolved TODOs indicate incomplete work.

**Detection**: Search for `// TODO:` or `/* TODO */` in codebase.

**Known TODOs**:
- `StorageService.kt:19` - "Fix proper platform-specific ByteArray to Data conversion"
- `DatabaseManager.kt:11` - "invoke after showAppData turns false"
- `XcampDatabase.sq:68` - "do we need Rating table?"
- `PlacesView.swift:10` - `Text("TODO")` placeholder
- `RatingView.swift:10` - `Text("TODO")` placeholder
- `SpeakersView.swift:10` - `Text("TODO")` placeholder
- `ScheduleView.swift:10` - `Text("TODO")` placeholder

**Action**: Either implement the feature or remove the TODO. For placeholder views, add proper empty state or remove file.

---

## High Priority Issues (Should Fix)

### 6. Result<T> Error Handling

**Problem**: Throwing exceptions breaks the `Result<T>` pattern used elsewhere.

**Detection**: Suspend functions that can fail should return `Result<T>`.

**Bad**:
```kotlin
suspend fun getData(): Data {
    return firestore.collection("data").get().first()
    // Throws exception on failure
}
```

**Good**:
```kotlin
suspend fun getData(): Result<Data> = try {
    Result.success(firestore.collection("data").get().first())
} catch (e: Exception) {
    Result.failure(e)
}
```

---

### 7. SwiftUI Preview Requirements

**Problem**: Missing previews make development slower.

**Detection**: Check for `#Preview` after view struct declaration.

**Required Format**:
```swift
@available(iOS 18, *)
#Preview("Descriptive name", traits: .sizeThatFitsLayout) {
    ComponentName(parameter: "test")
        .environmentObject(AppViewModel())
        .padding(Spacing.md)
        .background(Color.background)
}
```

**Good Example**: See any view in `iosApp/iosApp/views/` for proper preview format

---

### 8. Component Size Guidelines (iOS)

**Problem**: Large files (>100 lines) are harder to understand and maintain.

**Detection**: Count lines in component files.

**Known Violations**:
- `EmergencyPill.swift` - 139 lines (contains duplicate iOS 26.0 version check)
- `LinkTile.swift` - 106 lines

**Action**: Extract repeated patterns (e.g., iOS version checks) to reusable modifiers.

---

### 9. Koin DI Configuration (Android)

**Problem**: Empty DI module indicates incomplete setup.

**Detection**: Check `modules()` argument in `startKoin`.

**Bad** (`XcampApplication.kt:15`):
```kotlin
startKoin {
    androidLogger()
    androidContext(this@XcampApplication)
    modules(emptyList())  // <-- EMPTY!
}
```

**Good**:
```kotlin
val appModule = module {
    single { DatabaseManager(get()) }
    single { FirestoreService() }
    single { SpeakersRepository(get(), get()) }
    single { ScheduleRepository(get(), get()) }
    single { SongsRepository(get(), get()) }
    single { PlacesRepository(get(), get()) }
    single { NewsRepository(get(), get()) }
    single { GroupLeadersRepository(get(), get()) }
    single { RatingsRepository(get(), get()) }
    single { AuthService(get()) }
    single { StorageService(get()) }
}

startKoin {
    androidLogger()
    androidContext(this@XcampApplication)
    modules(appModule)
}
```

---

## Medium Priority Issues (Nice to Fix)

### 10. @Serializable on Domain Models

**Check**: Domain models should have `@Serializable` annotation for JSON serialization.

**Good**:
```kotlin
@Serializable
data class Section(
    val id: Long,
    val uid: String,
    val name: String,
    ...
)
```

---

### 11. Design Token Usage (iOS)

**Check**: Use `Spacing.*` and `CornerRadius.*` instead of hardcoded values.

**Bad**:
```swift
.padding(16)
.clipShape(RoundedRectangle(cornerRadius: 12))
```

**Good**:
```swift
.padding(Spacing.md)
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
```

**Reference**: `iosApp/iosApp/utils/Spacing.swift`, `iosApp/iosApp/utils/CornerRadius.swift`

---

### 12. Proper Coroutine Dispatchers (Kotlin)

**Check**: Database operations should use `withContext(Dispatchers.Default)` or `withDatabase`.

**Good**:
```kotlin
suspend fun getAllSections(): List<Section> = withDatabase {
    queries.selectAllSections().executeAsList().map { it.toDomain() }
}
```

---

### 13. Missing Code Quality Tools

**Check**: Project lacks automated code quality enforcement.

**Suggested Additions**:
1. `.editorconfig` for basic formatting consistency
2. `detekt` for Kotlin static analysis
3. SwiftLint configuration for iOS code

---

## Search Commands for Detecting Violations

```bash
# Find duplicate mapping blocks in repositories
grep -n "Section(" shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/*.kt

# Find TODO comments
grep -rn "TODO" shared/src/commonMain/kotlin/ iosApp/iosApp/

# Find hardcoded Czech strings (common Czech words)
grep -rn '"Domů"' iosApp/iosApp/
grep -rn '"Program"' iosApp/iosApp/
grep -rn '"Info"' iosApp/iosApp/

# Find Firebase operations without timeout
grep -rn "firestore\." shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/ | grep -v "withTimeout"

# Count lines in iOS components
find iosApp/iosApp/components -name "*.swift" -exec wc -l {} \; | sort -rn

# Check for missing #Preview
find iosApp/iosApp/views -name "*.swift" -exec grep -L "#Preview" {} \;

# Find repositories not extending BaseRepository
grep -L "extends BaseRepository" shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/*.kt
```

---

## Output Format

When reviewing code, output findings in this format:

```markdown
## Code Review Report

### Summary
- **Files Reviewed**: 15
- **Critical Issues**: 3
- **High Priority**: 5
- **Medium Priority**: 7

### Critical Issues

#### [KMP-CRITICAL-001] Database Mapping Code Duplication
**File**: `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/data/repository/ScheduleRepository.kt`
**Lines**: 22-42, 47-67, 72-92, 97-117, 125-145
**Severity**: HIGH

**Issue**: The `ScheduleRepository` contains 5 nearly identical database-to-domain mapping blocks, violating DRY principle.

**Impact**: File is 217 lines (should be ~80). Bug fixes require changes in 5 places.

**Suggested Fix**:
```kotlin
private fun cz.krutsche.xcamp.shared.db.Section.toDomain() = Section(
    id = id, uid = uid, name = name, description = description,
    startTime = Instant.fromEpochMilliseconds(startTime),
    endTime = Instant.fromEpochMilliseconds(endTime),
    place = place, speakers = speakers?.let { json.decodeFromString(it) },
    leader = leader, type = SectionType.valueOf(type),
    favorite = favorite > 0,
    repeatedDates = repeatedDates?.let { json.decodeFromString(it) }
)

suspend fun getAllSections(): List<Section> =
    queries.selectAllSections().executeAsList().map { it.toDomain() }
```

**Pattern Reference**: `SpeakersRepository.kt:41-50`

---

#### [KMP-CRITICAL-002] Hardcoded Czech String
**File**: `iosApp/iosApp/views/HomeView.swift`
**Line**: 15
**Severity**: HIGH

**Issue**: Hardcoded Czech string "Domů" instead of using `Strings.Tabs.HOME`.

**Suggested Fix**:
```swift
Text(Strings.Tabs.HOME)
```

---

### High Priority Issues

#### [KMP-HIGH-001] Empty Koin Module
**File**: `composeApp/src/androidMain/kotlin/cz/krutsche/xcamp/XcampApplication.kt`
**Line**: 15
**Severity**: MEDIUM

**Issue**: `modules(emptyList())` - Koin DI initialized but no modules registered.

**Suggested Fix**: Create appModule with all repositories and services.

---

### Medium Priority Issues

#### [KMP-MEDIUM-001] Component Over 100 Lines
**File**: `iosApp/iosApp/components/info/EmergencyPill.swift`
**Size**: 139 lines
**Severity**: LOW

**Issue**: File contains duplicate iOS 26.0 version check pattern.

**Suggested Fix**: Extract version check to reusable view modifier.

---

## Good Patterns Found

- `SpeakersRepository.kt` - Clean use of BaseRepository pattern
- `GlassCard.swift` - Proper generic component with @ViewBuilder
- `Strings.kt` - Centralized string management
- `FirestoreService.kt` - Consistent 5-second timeout on all operations
- `Spacing.swift` / `CornerRadius.swift` - Design token consistency

---

## Recommendations

1. **Immediate**: Refactor `ScheduleRepository` to eliminate duplication
2. **Short-term**: Replace hardcoded strings with `Strings.*` references
3. **Medium-term**: Add `.editorconfig` and basic linting setup
4. **Long-term**: Implement proper DI modules for Koin on Android
```

---

## Good Examples to Reference

### Excellent Repository Pattern
**`SpeakersRepository.kt:7-51`**:
- Extends `BaseRepository<Speaker>`
- Uses `withDatabase` helper
- Extracts mapping to `mapToSpeaker()` function
- Uses inherited `syncFromFirestore()` method

### Proper Firebase Timeout
**`FirestoreService.kt:12-18`**:
```kotlin
suspend fun <T> getCollection(
    collection: String,
    serializer: KSerializer<T>
): Result<List<T>> = withTimeout(5.seconds) {
    try {
        val snapshot = firestore.collection(collection).get().await()
        val items = snapshot.documents.mapNotNull { it.data.toObject(serializer) }
        Result.success(items)
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

### Well-Designed SwiftUI Component
**`GlassCard.swift`**:
- Generic with `<Content: View>`
- Uses `@ViewBuilder` for flexibility
- Proper iOS version handling with `@available`

### Good Design Tokens
**`Spacing.swift`**, **`CornerRadius.swift`**:
- Single source of truth
- Consistent naming
- Used throughout codebase

---

## Known Violations in This Codebase

### High Priority

1. **ScheduleRepository mapping duplication** - `ScheduleRepository.kt:22-145`
2. **Empty Koin module** - `XcampApplication.kt:15`
3. **Multiple hardcoded Czech strings** - Various iOS views

### Medium Priority

1. **Large components** - `EmergencyPill.swift` (139 lines), `LinkTile.swift` (106 lines)
2. **Unresolved TODOs** - StorageService, DatabaseManager, placeholder views
3. **No code quality tools** - Missing .editorconfig, detekt, SwiftLint

---

## When to Use This Agent

- Before committing code changes
- After implementing new features
- When refactoring existing code
- During code reviews of pull requests
- When onboarding new developers
- Periodic code health checks
