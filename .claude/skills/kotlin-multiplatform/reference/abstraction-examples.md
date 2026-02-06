# Abstraction Examples

Good and bad abstraction examples from XcamP KMP project.

## Table of Contents
- [Good Abstractions](#good-abstractions)
- [Bad Abstractions](#bad-abstractions)
- [Borderline Cases](#borderline-cases)

## Good Abstractions

### Data Models in commonMain

**Why good:** Pure Kotlin, no platform dependencies, used by both platforms.

```kotlin
// shared/src/commonMain/kotlin/com/krutsche/xcamp/domain/model/Section.kt
@Serializable
data class Section(
    val id: String,
    val name: String,
    val day: Int,
    val startTime: String,
    val endTime: String,
    val typeId: String?,
    val placeId: String?,
    val leaderId: String?,
    val description: String?
)
```

### Repository with expect/actual Dependencies

**Why good:** Business logic is shared, platform-specific implementations are abstracted.

```kotlin
// shared/src/commonMain/kotlin/com/krutsche/xcamp/data/repository/SectionRepository.kt
class SectionRepository(
    private val firestore: FirestoreService,  // expect/actual
    private val database: DatabaseManager     // expect/actual
) {
    suspend fun getSections(forceRefresh: Boolean = false): Result<List<Section>> {
        return if (forceRefresh) {
            fetchFromFirestore()
        } else {
            getFromDatabase()
        }
    }

    private suspend fun fetchFromFirestore(): Result<List<Section>> {
        return firestore.getCollection("sections").map { documents ->
            documents.mapNotNull { it.toSection() }
        }
    }
}
```

### Platform Logger via expect/actual

**Why good:** Logging APIs differ by platform, but interface is shared.

```kotlin
// shared/src/commonMain/kotlin/com/krutsche/xcamp/util/Log.kt
expect object Log {
    fun d(tag: String, message: String)
    fun e(tag: String, message: String, throwable: Throwable?)
    fun i(tag: String, message: String)
}

// shared/src/androidMain/kotlin/com/krutsche/xcamp/util/Log.kt
actual object Log {
    actual fun d(tag: String, message: String) {
        android.util.Log.d(tag, message)
    }
    actual fun e(tag: String, message: String, throwable: Throwable?) {
        android.util.Log.e(tag, message, throwable)
    }
    actual fun i(tag: String, message: String) {
        android.util.Log.i(tag, message)
    }
}

// shared/src/iosMain/kotlin/com/krutsche/xcamp/util/Log.kt
actual object Log {
    actual fun d(tag: String, message: String) {
        NSLog("[D] $tag: $message")
    }
    actual fun e(tag: String, message: String, throwable: Throwable?) {
        NSLog("[E] $tag: $message${throwable?.let { ": ${it.message}" } ?: ""}")
    }
    actual fun i(tag: String, message: String) {
        NSLog("[I] $tag: $message")
    }
}
```

## Bad Abstractions

### UI Component in commonMain

**Why bad:** Compose is Android-specific, SwiftUI is iOS-specific. Can't share UI code.

```kotlin
// ❌ BAD - This won't work
@Composable
expect fun SectionCard(section: Section, onClick: () -> Unit)
```

**Correct approach:** Keep UI platform-specific.

```kotlin
// composeApp/src/commonMain/kotlin/com/krutsche/xcamp/ui/SectionCard.kt (Android)
@Composable
fun SectionCard(section: Section, onClick: () -> Unit) {
    // Jetpack Compose implementation
}

// iosApp/iosApp/components/schedule/SectionCard.swift (iOS)
struct SectionCard: View {
    let section: Section
    let onClick: () -> Void
    // SwiftUI implementation
}
```

### Platform-Specific Types in commonMain

**Why bad:** Won't compile on other platforms.

```kotlin
// ❌ BAD - Context is Android-only
// shared/src/commonMain/kotlin/...
fun getFilePath(context: Context): String {
    return context.filesDir.path
}
```

**Correct approach:** Use expect/actual.

```kotlin
// shared/src/commonMain/kotlin/...
expect fun getFilePath(): String

// shared/src/androidMain/kotlin/...
actual fun getFilePath() = context.filesDir.path

// shared/src/iosMain/kotlin/...
actual fun getFilePath() = NSSearchPathForDirectoriesInDomains(...)
```

### Duplicated Business Logic

**Why bad:** Bug fixes must be applied in two places, tests are duplicated.

```kotlin
// ❌ BAD - Same logic in both platforms
// androidMain/.../SectionValidator.kt
fun validateSection(section: Section): Boolean {
    return section.name.isNotBlank() &&
           section.day in 1..8 &&
           section.startTime.matches(Regex("\\d{2}:\\d{2}"))
}

// iosMain/.../SectionValidator.kt
fun validateSection(section: Section): Boolean {
    return section.name.isNotBlank() &&
           section.day in 1..8 &&
           section.startTime.matches(Regex("\\d{2}:\\d{2}"))
}
```

**Correct approach:** Move to commonMain.

```kotlin
// shared/src/commonMain/kotlin/...
fun validateSection(section: Section): Boolean {
    return section.name.isNotBlank() &&
           section.day in 1..8 &&
           section.startTime.matches(Regex("\\d{2}:\\d{2}"))
}
```

## Borderline Cases

### ViewModel in commonMain

**Decision:** Can be shared if using StateFlow/SharedFlow.

**Good:** State and business logic are platform-agnostic.

```kotlin
// shared/src/commonMain/kotlin/com/krutsche/xcamp/viewmodel/ScheduleViewModel.kt
class ScheduleViewModel(
    private val sectionRepository: SectionRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow<ScheduleUiState>(ScheduleUiState.Loading)
    val uiState: StateFlow<ScheduleUiState> = _uiState.asStateFlow()

    fun loadSections(day: Int?) {
        viewModelScope.launch {
            _uiState.value = ScheduleUiState.Loading
            sectionRepository.getSections()
                .onSuccess { sections ->
                    _uiState.value = ScheduleUiState.Success(
                        if (day != null) sections.filter { it.day == day }
                        else sections
                    )
                }
                .onFailure { error ->
                    _uiState.value = ScheduleUiState.Error(error.message)
                }
        }
    }
}
```

**Note:** Requires lifecycle-aware extensions (androidx.lifecycle VM) which are available for both platforms.

### File I/O

**Decision:** Use expect/actual - file APIs differ significantly.

```kotlin
// shared/src/commonMain/kotlin/...
expect class FileHandler {
    suspend fun readText(fileName: String): Result<String>
    suspend fun writeText(fileName: String, content: String): Result<Unit>
    suspend fun delete(fileName: String): Result<Unit>
}

// shared/src/androidMain/kotlin/...
actual class FileHandler(private val context: Context) {
    actual suspend fun readText(fileName: String): Result<String> {
        return try {
            val file = File(context.filesDir, fileName)
            Result.success(file.readText())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    // ...
}

// shared/src/iosMain/kotlin/...
actual class FileHandler {
    actual suspend fun readText(fileName: String): Result<String> {
        return try {
            val path = getDocumentsDirectory().stringByAppendingPathComponent(fileName)
            val content = NSString.stringWithContentsOfFile(path) as String?
            if (content != null) Result.success(content)
            else Result.failure(IOException("File not found"))
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    // ...
}
```
