# Shared Logic Subagent

Specialized guidance for Kotlin shared module development in the XcamP KMP project.

## Trigger Keywords
shared, repository, SQLDelight, Koin, coroutine

## Module Structure
```
shared/src/
├── commonMain/kotlin/     # Shared business logic
├── androidMain/kotlin/    # Android-specific implementations
└── iosMain/kotlin/        # iOS-specific implementations
```

## Key Packages

### Data Layer (`cz.krutsche.xcamp.shared.data/`)
- `config/` - AppConfigService (Remote Config, app state calculation)
- `firebase/` - Firebase services (Auth, Firestore, Storage, Analytics, Crashlytics)
- `local/` - DatabaseManager, SQLite operations
- `repository/` - Repository implementations for each entity

### Domain Models (`cz.krutsche.xcamp.shared.domain.model/`)
- `Section` - Schedule events with favorites
- `Speaker`, `Song`, `Place`, `News`, `Rating`

## Repository Pattern

**Standard Repository Structure:**
```kotlin
class ExampleRepository(
    private val database: DatabaseManager,
    private val firestore: Firestore
) {
    suspend fun getAll(): Result<List<Example>> = withContext(Dispatchers.Default) {
        try {
            withTimeout(5_000) {
                // Try Firebase first
                val remote = firestore.collection("examples").get().first()
                database.insertExamples(remote)
                Result.success(remote.map { it.toDomain() })
            }
        } catch (e: Exception) {
            // Fallback to local
            val local = database.getAllExamples()
            Result.success(local.map { it.toDomain() })
        }
    }
}
```

**Key Principles:**
- Return `Result<T>` for error handling (no exceptions)
- 5-second timeout on network operations
- Offline-first: local SQLite as fallback
- Use `INSERT OR REPLACE` for data synchronization

## SQLDelight Database

### Schema Location
`shared/src/commonMain/sqldelight/cz/krutsche/xcamp/shared/db/XcampDatabase.sq`

### Common Patterns
```sql
CREATE TABLE Example (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    timestamp INTEGER
);

insertExample:
INSERT OR REPLACE INTO Example (id, name, timestamp) VALUES (?, ?, ?);

getAllExamples:
SELECT * FROM Example;
```

### Generated Code Usage
```kotlin
// Queries are type-safe
database.exampleQueries.getAllExamples().executeAsList()
```

### Data Types
- **Timestamps**: INTEGER (Unix timestamp)
- **JSON Arrays**: TEXT (serialized)
- **IDs**: TEXT (string-based)

## Dependency Injection (Koin 4.0.1)

### Module Definition
```kotlin
val appModule = module {
    single { DatabaseManager(get()) }
    single { FirestoreServiceImpl() }
    single { ExampleRepository(get(), get()) }
}
```

### Usage in Kotlin
```kotlin
val repository: ExampleRepository by inject()
```

### Platform Integration
- **Android**: Start Koin in `onCreate()` of Application class
- **iOS**: Initialize in app startup via Kotlin main function

## Coroutines & Async Patterns

### Dispatchers
- `Dispatchers.Default` - CPU-intensive work
- `Dispatchers.IO` - Database/network operations
- `Dispatchers.Main` - UI updates (use `MainScope()` on iOS)

### Common Patterns
```kotlin
suspend fun fetchData(): Result<Data> = withContext(Dispatchers.IO) {
    try {
        withTimeout(5_000) {
            val data = remoteCall()
            Result.success(data)
        }
    } catch (e: Exception) {
        Result.failure(e)
    }
}
```

## Error Handling

### Result<T> Pattern
```kotlin
// Success
Result.success(data)

// Failure
Result.failure(exception)

// Consumption
when (result) {
    is Result.Success -> handleData(result.value)
    is Result.Failure -> handleError(result.exception)
}
```

## Domain Model Mapping

### Entity to Domain
```kotlin
fun ExampleEntity.toDomain() = Example(
    id = id,
    name = name,
    timestamp = timestamp.toLocalDateTime()
)
```

## Common Utilities

### DateTime Handling
```kotlin
import kotlinx.datetime.*

// Unix timestamp to LocalDateTime
val timestamp.toLocalDateTime() =
    Instant.fromEpochMilliseconds(this)
        .toLocalDateTime(TimeZone.UTC)
```

### JSON Serialization
```kotlin
import kotlinx.serialization.*

@Serializable
data class Example(val id: String, val name: String)

// Encode/Decode
Json.encodeToString(example)
Json.decodeFromString<Example>(jsonString)
```

## Development Guidelines
- All business logic in Kotlin (not Swift/Compose)
- Pure functions where possible
- Avoid platform-specific code in `commonMain`
- Use `expect/actual` for platform differences
