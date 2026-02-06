# Source Set Hierarchy

Visual representation of XcamP KMP source set dependencies.

## Hierarchy Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     commonMain                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Pure Kotlin - Shared Business Logic                 │  │
│  │  • Data models (Section, Speaker, Place, etc.)       │  │
│  │  • Repository interfaces                            │  │
│  │  • ViewModels (StateFlow/SharedFlow)                │  │
│  │  • Use cases / Business logic                       │  │
│  │  • Utilities (date, validation, formatting)         │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────────┐    ┌───────────────────┐
│   androidMain     │    │     iosMain       │
│ ───────────────── │    │ ───────────────── │
│ Android-specific  │    │   iOS-specific    │
│ implementations   │    │  implementations  │
│                   │    │                   │
│ • Firebase SDK    │    │ • Firebase SDK    │
│   (Android)       │    │   (iOS)           │
│ • SQLite driver   │    │ • SQLite driver   │
│   (Android)       │    │   (iOS)           │
│ • Context access  │    │ • iOS frameworks  │
│ • Android Logger  │    │ • iOS Logger      │
│ • File I/O        │    │ • File I/O        │
└───────────────────┘    └───────────────────┘
```

## Directory Structure

```
shared/src/
├── commonMain/
│   └── kotlin/com/krutsche/xcamp/
│       ├── domain/
│       │   └── model/              # Data models
│       │       ├── Section.kt
│       │       ├── Speaker.kt
│       │       ├── Place.kt
│       │       ├── Song.kt
│       │       ├── News.kt
│       │       └── ...
│       ├── data/
│       │   ├── repository/         # Repository interfaces & impl
│       │   │   ├── SectionRepository.kt
│       │   │   ├── SpeakerRepository.kt
│       │   │   └── ...
│       │   ├── firebase/           # expect declarations
│       │   │   ├── FirebaseApp.kt
│       │   │   ├── FirebaseFirestore.kt
│       │   │   └── ...
│       │   ├── local/              # expect declarations
│       │   │   └── DatabaseManager.kt
│       │   └── config/
│       │       └── AppConfigService.kt
│       ├── viewmodel/              # Shared ViewModels
│       │   ├── ScheduleViewModel.kt
│       │   ├── SpeakersViewModel.kt
│       │   └── ...
│       └── util/                   # Common utilities
│           ├── DateUtils.kt
│           ├── ValidationUtils.kt
│           └── Log.kt (expect)
│
├── androidMain/
│   └── kotlin/com/krutsche/xcamp/
│       ├── data/
│       │   ├── firebase/           # actual implementations
│       │   │   ├── FirebaseApp.kt
│       │   │   ├── FirebaseFirestore.kt
│       │   │   └── ...
│       │   └── local/
│       │       └── DatabaseManager.kt
│       └── util/
│           └── Log.kt (actual)
│
└── iosMain/
    └── kotlin/com/krutsche/xcamp/
        ├── data/
        │   ├── firebase/           # actual implementations
        │   │   ├── FirebaseApp.kt
        │   │   ├── FirebaseFirestore.kt
        │   │   └── ...
        │   └── local/
        │       └── DatabaseManager.kt
        └── util/
            └── Log.kt (actual)
```

## Dependency Flow Examples

### Example 1: Data Fetching

```
┌─────────────────────────────────────────────────────────┐
│ Platform UI (Compose/SwiftUI)                          │
└────────────────────┬────────────────────────────────────┘
                     │ observes
                     ▼
┌─────────────────────────────────────────────────────────┐
│ commonMain: ScheduleViewModel                          │
│ • StateFlow<UiState>                                   │
│ • loadSections()                                       │
└────────────────────┬────────────────────────────────────┘
                     │ calls
                     ▼
┌─────────────────────────────────────────────────────────┐
│ commonMain: SectionRepository                          │
│ • getSections(): Result<List<Section>>                 │
└────────────────────┬────────────────────────────────────┘
                     │ uses (expect/actual)
                     ├──────────────────┬──────────────────┐
                     ▼                  ▼                  ▼
         ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
         │ androidMain:     │  │ iosMain:         │  │ commonMain:      │
         │ FirestoreService │  │ FirestoreService │  │ DatabaseManager  │
         └──────────────────┘  └──────────────────┘  └──────────────────┘
```

### Example 2: expect/actual Pattern

```
┌─────────────────────────────────────────────────────────┐
│ commonMain: Log (expect declaration)                   │
│                                                         │
│ expect object Log {                                    │
│     fun d(tag: String, message: String)               │
│     fun e(tag: String, message: String, t: Throwable?)│
│ }                                                      │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────────┐    ┌───────────────────┐
│ androidMain:      │    │ iosMain:          │
│ Log (actual)      │    │ Log (actual)      │
│                   │    │                   │
│ actual object Log {│    │ actual object Log {│
│   actual fun d() {│    │   actual fun d() {│
│     android.util. │    │     NSLog(...)    │
│       Log.d(...)  │    │   }               │
│   }               │    │ }                 │
│ }                 │    │                   │
└───────────────────┘    └───────────────────┘
```

## Build Configuration

### shared/build.gradle.kts

```kotlin
kotlin {
    // Primary targets
    androidTarget()
    iosX64()
    iosArm64()
    iosSimulatorArm64()

    // Source sets
    sourceSets {
        val commonMain by getting {
            dependencies {
                // Coroutines
                implementation(libs.kotlinx.coroutines.core)
                // Serialization
                implementation(libs.kotlinx.serialization.json)
                // SQLDelight
                implementation(libs.sqldelight.runtime)
                // Koin
                implementation(libs.koin.core)
            }
        }

        val androidMain by getting {
            dependencies {
                // Firebase GitLive Android
                implementation(libs.firebase.android)
                // SQLDelight Android driver
                implementation(libs.sqldelight.android.driver)
            }
        }

        val iosMain by creating {
            dependsOn(commonMain)
            dependencies {
                // Firebase GitLive iOS
                implementation(libs.firebase.ios)
                // SQLDelight iOS driver
                implementation(libs.sqldelight.ios.driver)
            }
        }

        // iOS-specific targets
        val iosX64Main by getting { dependsOn(iosMain) }
        val iosArm64Main by getting { dependsOn(iosMain) }
        val iosSimulatorArm64Main by getting { dependsOn(iosMain) }
    }
}
```

## Key Patterns

### 1. Depends-On Chain

Each platform-specific source set must depend on `commonMain`:

```kotlin
val iosMain by creating {
    dependsOn(commonMain)  // Required!
}
```

### 2. Intermediate Source Sets

For shared iOS code:

```kotlin
val iosMain by creating {
    dependsOn(commonMain)
    // iOS-common code goes here
}

val iosX64Main by getting {
    dependsOn(iosMain)  // Inherits from iosMain
}

val iosArm64Main by getting {
    dependsOn(iosMain)  // Inherits from iosMain
}
```

### 3. Platform-Specific Dependencies

Android gets Android libraries, iOS gets iOS libraries:

```kotlin
val androidMain by getting {
    dependencies {
        implementation("androidx.lifecycle:lifecycle-viewmodel:2.7.0")
    }
}

val iosMain by creating {
    dependencies {
        // iOS-specific dependencies
    }
}
```

## Common Pitfalls

### 1. Circular Dependencies

```kotlin
// ❌ BAD
val commonMain by getting {
    dependsOn(androidMain)  // Creates cycle!
}
```

**Fix:** Only platform source sets should depend on commonMain, never the reverse.

### 2. Missing Depends-On

```kotlin
// ❌ BAD - iosMain doesn't depend on commonMain
val iosMain by creating {
    // Won't see commonMain code!
}
```

**Fix:** Always add `dependsOn(commonMain)`.

### 3. Platform Code in commonMain

```kotlin
// ❌ BAD - Won't compile on iOS
// commonMain/...
import android.os.Bundle
fun navigate(bundle: Bundle) { ... }
```

**Fix:** Use expect/actual or keep platform-specific.
