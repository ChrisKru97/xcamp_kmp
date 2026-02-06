# Kotlin Multiplatform: Platform Abstraction Decisions

Expert guidance for KMP architecture in XcamP - deciding what to share vs keep platform-specific.

## When to Use This Skill

Making platform abstraction decisions:
- "Should I create expect/actual or keep Android-only?"
- "Can I share this ViewModel logic?"
- "Where does this Firebase/JSON/network implementation belong?"
- "This uses Android Context - can it be abstracted?"
- "Is this code in the wrong module?"
- Preparing for iOS targets
- Detecting incorrect placements

## Abstraction Decision Tree

**Central question:** "Should this code be reused across platforms?"

Follow this decision path (< 1 minute):

```
Q: Is it used by 2+ platforms?
├─ NO  → Keep platform-specific
│         Example: Android-only permission handling
│
└─ YES → Continue ↓

Q: Is it pure Kotlin (no platform APIs)?
├─ YES → commonMain
│         Example: Data models, business rules, repositories
│
└─ NO  → Continue ↓

Q: Does it vary by platform or by JVM vs non-JVM?
├─ By platform (Android ≠ iOS)
│  → expect/actual
│  Example: Platform-specific file I/O, logging
│
├─ By JVM (Android ≠ iOS)
│  → androidMain only (no JVM desktop target)
│  Example: Android-specific Firebase implementations
│
└─ Complex/UI-related
   → Keep platform-specific
   Example: UI components (Compose vs SwiftUI)

Final check:
Q: Maintenance cost of abstraction < duplication cost?
├─ YES → Proceed with abstraction
└─ NO  → Duplicate (simpler)
```

### Real Examples from XcamP Codebase

**Firebase → expect/actual:**
```kotlin
// commonMain - expect declaration
expect class FirebaseAnalytics {
    fun logEvent(name: String, params: Map<String, Any>?)
}

// androidMain - uses Firebase Android SDK
// iosMain - uses Firebase iOS SDK via interop
```
**Why:** Firebase SDKs are platform-specific but share common interfaces.

**Repository Pattern → commonMain:**
```kotlin
// commonMain - pure Kotlin with expect/actual dependencies
class SectionRepository(
    private val firestore: FirestoreService,
    private val database: DatabaseManager
) {
    suspend fun getSections(): Result<List<Section>>
}
```
**Why:** Business logic is pure Kotlin, dependencies are injected via expect/actual.

## Mental Model: Source Sets as Dependency Graph

Think of source sets as a dependency graph, not folders.

```
┌─────────────────────────────────────────────┐
│ commonMain = Contract (pure Kotlin)         │
│ - Business logic, protocol, data models     │
│ - No platform APIs                          │
└────────────┬────────────────────────────────┘
             │
             ├──────────────────────┬────────────────────
             │                      │
             ▼                      ▼
   ┌───────────────────┐  ┌──────────────────┐
   │ androidMain       │  │ iosMain          │
   │ Android-specific  │  │ iOS-specific     │
   │ - Firebase SDK    │  │ - Firebase SDK   │
   │ - Android Context │  │ - iOS frameworks │
   │ - SQLite driver   │  │ - SQLite driver  │
   └───────────────────┘  └──────────────────┘
```

## What to Abstract vs Keep Platform-Specific

Quick decision guidelines based on XcamP patterns:

### Always Abstract
- **Data models** (Section, Speaker, Song, Place, News, etc.)
- **Repository interfaces and implementations** (when pure Kotlin)
- **Business logic** (data transformation, validation, state management)
- **Why:** Needed everywhere, platform-agnostic

### Often Abstract
- **I/O operations** (file reading, caching) - via expect/actual
- **Logging** (platform logging systems differ) - via expect/actual
- **Firebase services** (Auth, Firestore, Storage) - via expect/actual
- **Why:** Commonly reused, platform implementations available

### Sometimes Abstract
- **ViewModels:** YES - state + business logic shareable (StateFlow/SharedFlow)
- **Use cases:** YES - pure Kotlin business logic
- **UI components:** NO - platform-native (Compose vs SwiftUI)
- **Why:** ViewModels contain platform-agnostic state; UI renders differently per platform

### Never Abstract
- **Platform UI components** (Compose vs SwiftUI)
- **Navigation** (Jetpack Navigation vs iOS Navigation)
- **Platform-specific UX patterns**
- **Why:** Too platform-specific, abstraction creates leaky APIs

## expect/actual Mechanics

**When to use:** Code needed by 2+ platforms, varies by platform.

### Pattern Categories from XcamP

**Objects (singletons):**
```kotlin
expect object Log {
    fun d(tag: String, message: String)
    fun e(tag: String, message: String, throwable: Throwable?)
}
```

**Classes (instantiable):**
```kotlin
expect class Firebase_firestore() {
    suspend fun getCollection(path: String): Result<List<DocumentSnapshot>>
}
```

**Functions (utilities):**
```kotlin
expect fun platformPath(): String
expect fun currentTimeMillis(): Long
```

## Target-Specific Guidance

### Android, iOS - Current Primary Targets

**Status:** Mature patterns, stable APIs

**Android (androidMain):**
- Uses Android framework (Context, Application, etc.)
- Firebase GitLive SDK for Android
- Jetpack Compose for UI
- AndroidX libraries

**iOS (iosMain):**
- Uses iOS frameworks (Foundation, UIKit, etc.)
- Firebase GitLive SDK for iOS
- SwiftUI for UI (in iosApp module)
- Platform APIs via platform.* libraries

### Best Practices for XcamP

**Use kotlinx.coroutines for async:**
```kotlin
// commonMain - works everywhere
suspend fun fetchData(): Result<Data> = withContext(Dispatchers.Default) {
    // Pure Kotlin logic
}
```

**Use kotlinx.serialization for JSON:**
```kotlin
// commonMain - cross-platform JSON
@Serializable
data class SectionDto(
    val id: String,
    val name: String
)
```

**Prefer expect/actual for platform APIs:**
```kotlin
// commonMain
expect fun getDatabasePath(): String

// androidMain
actual fun getDatabasePath() = context.databasePath

// iosMain
actual fun getDatabasePath() = NSSearchPathForDirectoriesInDomains(...)
```

## Common Pitfalls

### 1. Over-Abstraction
**Problem:** Creating expect/actual for UI components
```kotlin
// ❌ BAD
expect fun NavigationComponent(...)
```
**Why:** UI paradigms too different (Compose vs SwiftUI)
**Fix:** Keep platform-specific, accept duplication

### 2. Under-Sharing
**Problem:** Duplicating business logic across platforms
```kotlin
// ❌ BAD - duplicated in androidMain and iosMain
fun parseSection(data: Map<String, Any>): Section { ... }
```
**Why:** Bug fixes need to be applied twice, tests duplicated
**Fix:** Move to commonMain (pure Kotlin) or create expect/actual

### 3. Leaky Abstractions
**Problem:** Platform code in commonMain
```kotlin
// commonMain - ❌ BAD
import android.content.Context  // Won't compile on iOS!
```
**Fix:** Use expect/actual or dependency injection

### 4. Wrong Source Set
**Problem:** Android-specific code in commonMain
```kotlin
// commonMain - ❌ BAD
import androidx.compose.runtime.*
```
**Why:** Compose is Android-only (for now)
**Fix:** Move to androidMain or use Compose Multiplatform

## Quick Reference

| Code Type | Recommended Location | Reason |
|-----------|---------------------|--------|
| Pure Kotlin business logic | commonMain | Works everywhere |
| Data models | commonMain | Shared entities |
| Repository interfaces | commonMain | Contract definition |
| Repository implementations | commonMain (with expect/actual deps) | Pure Kotlin logic |
| Firebase services | expect/actual | Platform SDKs |
| I/O, logging | expect/actual | Platform implementations differ |
| State (business logic) | commonMain | Reusable StateFlow patterns |
| **ViewModels** | **commonMain** | **StateFlow/SharedFlow + logic shareable** |
| UI components | Platform-specific | Compose vs SwiftUI |
| Navigation | Platform-specific | Too different |
| Platform UX | Platform-specific | Native feel required |

## XcamP-Specific Patterns

### Firebase Integration

```kotlin
// commonMain - expect declaration
expect class FirebaseApp {
    suspend fun initialize()
}

expect class FirebaseFirestore {
    suspend fun getCollection(path: String): Result<List<Document>>
}

// androidMain - Firebase Android SDK
actual class FirebaseApp {
    actual suspend fun initialize() {
        // Firebase Android initialization
    }
}

// iosMain - Firebase iOS SDK
actual class FirebaseApp {
    actual suspend fun initialize() {
        // Firebase iOS initialization
    }
}
```

### SQLDelight Database

```kotlin
// commonMain - schema and queries
// shared/src/commonMain/sqldelight/com/krutsche/xcamp/database/XcampDatabase.sq

// commonMain - expect declaration for driver
expect fun createDatabaseDriver(): SqlDriver

// androidMain
actual fun createDatabaseDriver() = AndroidSqliteDriver(...)

// iosMain
actual fun createDatabaseDriver() = NativeSqliteDriver(...)
```

### Dependency Injection with Koin

```kotlin
// commonMain - module definition
val databaseModule = module {
    single { createDatabaseDriver() }
    single { XcampDatabase(get()) }
}

val repositoryModule = module {
    single { SectionRepository(get(), get()) }
}
```

## See Also

- [references/abstraction-examples.md](references/abstraction-examples.md) - Good/bad abstraction examples with rationale
- [references/source-set-hierarchy.md](references/source-set-hierarchy.md) - Visual hierarchy with XcamP examples
- [references/expect-actual-catalog.md](references/expect-actual-catalog.md) - All expect/actual pairs with "why abstracted"

## Development Workflow

When adding new features to XcamP:

1. **Start in commonMain** - Define data models and interfaces
2. **Identify platform dependencies** - What needs expect/actual?
3. **Implement platform-specific** - Add actual implementations
4. **Test on both platforms** - Verify shared and platform-specific code
5. **Refactor as needed** - Move code between source sets based on usage

## Key Dependencies

- **Kotlin Coroutines:** 1.10.2 (async/await across platforms)
- **SQLDelight:** 2.1.0 (type-safe database queries)
- **Firebase GitLive:** 2.4.0 (cross-platform Firebase SDK)
- **Kotlinx Serialization:** JSON serialization
- **Koin:** Dependency injection
