# expect/actual Catalog

Complete list of expect/actual declarations in XcamP KMP with rationale for why each was abstracted.

## Table of Contents
- [Logging](#logging)
- [Firebase Services](#firebase-services)
- [Database](#database)
- [File I/O](#file-io)
- [Platform Utilities](#platform-utilities)

## Logging

### Log Object

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/util/Log.kt`

**Expect Declaration:**
```kotlin
expect object Log {
    fun d(tag: String, message: String)
    fun e(tag: String, message: String, throwable: Throwable?)
    fun i(tag: String, message: String)
    fun w(tag: String, message: String)
}
```

**Android Actual:**
```kotlin
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
    actual fun w(tag: String, message: String) {
        android.util.Log.w(tag, message)
    }
}
```

**iOS Actual:**
```kotlin
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
    actual fun w(tag: String, message: String) {
        NSLog("[W] $tag: $message")
    }
}
```

**Why Abstracted:** Logging APIs differ completely between platforms (android.util.Log vs NSLog). Shared logging interface enables consistent logging across the codebase.

---

## Firebase Services

### FirebaseApp

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseApp.kt`

**Expect Declaration:**
```kotlin
expect class FirebaseApp {
    suspend fun initialize()
    fun isInitialized(): Boolean
}
```

**Android Actual:**
```kotlin
// shared/src/androidMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseApp.kt
actual class FirebaseApp {
    actual suspend fun initialize() {
        // Firebase Android SDK initialization
        FirebaseApp.checkOrUpdateFirebaseConfig()
    }
    actual fun isInitialized(): Boolean {
        return com.google.firebase.FirebaseApp.getApp() != null
    }
}
```

**iOS Actual:**
```kotlin
// shared/src/iosMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseApp.kt
actual class FirebaseApp {
    actual suspend fun initialize() {
        // Firebase iOS SDK initialization via GitLive
        firebase.app.initialize()
    }
    actual fun isInitialized(): Boolean {
        return firebase.app.isInitialized()
    }
}
```

**Why Abstracted:** Firebase SDKs are platform-specific with different initialization patterns. Abstraction allows shared repository code to work with Firebase without platform dependencies.

### FirebaseFirestore

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseFirestore.kt`

**Expect Declaration:**
```kotlin
expect class FirebaseFirestore {
    suspend fun getCollection(
        path: String,
        orderBy: String? = null,
        limit: Int? = null
    ): Result<List<DocumentSnapshot>>

    suspend fun getDocument(
        path: String
    ): Result<DocumentSnapshot?>

    suspend fun setDocument(
        path: String,
        data: Map<String, Any>
    ): Result<Unit>
}
```

**Why Abstracted:** Firestore APIs differ between Android SDK and iOS SDK (via GitLive). Shared interface enables common repository implementations.

### FirebaseAuth

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseAuth.kt`

**Expect Declaration:**
```kotlin
expect class FirebaseAuth {
    suspend fun signInAnonymously(): Result<String>
    suspend fun getCurrentUserId(): String?
    suspend fun signOut(): Result<Unit>
}
```

**Why Abstracted:** Auth APIs are platform-specific. XcamP uses anonymous auth for all users, but the implementation differs.

### FirebaseStorage

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/data/firebase/FirebaseStorage.kt`

**Expect Declaration:**
```kotlin
expect class FirebaseStorage {
    suspend fun uploadFile(
        path: String,
        data: ByteArray,
        onProgress: (Float) -> Unit
    ): Result<String>

    suspend fun getDownloadUrl(path: String): Result<String>
}
```

**Why Abstracted:** Storage APIs differ significantly. Used for photo uploads in Media feature.

---

## Database

### DatabaseManager

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/data/local/DatabaseManager.kt`

**Expect Declaration:**
```kotlin
expect class DatabaseManager {
    fun createDriver(): SqlDriver
    suspend fun <T> withTransaction(block: () -> T): Result<T>
}
```

**Android Actual:**
```kotlin
// shared/src/androidMain/kotlin/com/krutsche/xcamp/data/local/DatabaseManager.kt
actual class DatabaseManager(private val context: Context) {
    actual fun createDriver(): SqlDriver {
        return AndroidSqliteDriver(
            XcampDatabase.Schema,
            context,
            "xcamp.db"
        )
    }
    actual suspend fun <T> withTransaction(block: () -> T): Result<T> {
        return try {
            Result.success(block())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

**iOS Actual:**
```kotlin
// shared/src/iosMain/kotlin/com/krutsche/xcamp/data/local/DatabaseManager.kt
actual class DatabaseManager {
    actual fun createDriver(): SqlDriver {
        return NativeSqliteDriver(XcampDatabase.Schema, "xcamp.db")
    }
    actual suspend fun <T> withTransaction(block: () -> T): Result<T> {
        return try {
            Result.success(block())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
```

**Why Abstracted:** SQLDelight drivers are platform-specific. Android uses AndroidSqliteDriver, iOS uses NativeSqliteDriver.

---

## File I/O

### FileHandler

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/util/FileHandler.kt`

**Expect Declaration:**
```kotlin
expect class FileHandler {
    suspend fun readText(fileName: String): Result<String>
    suspend fun writeText(fileName: String, content: String): Result<Unit>
    suspend fun delete(fileName: String): Result<Unit>
    suspend fun exists(fileName: String): Boolean
}
```

**Android Actual:**
```kotlin
// shared/src/androidMain/kotlin/com/krutsche/xcamp/util/FileHandler.kt
actual class FileHandler(private val context: Context) {
    private val fileDir get() = context.filesDir

    actual suspend fun readText(fileName: String): Result<String> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(fileDir, fileName)
                Result.success(file.readText())
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }

    actual suspend fun writeText(fileName: String, content: String): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                val file = File(fileDir, fileName)
                file.writeText(content)
                Result.success(Unit)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    // ...
}
```

**iOS Actual:**
```kotlin
// shared/src/iosMain/kotlin/com/krutsche/xcamp/util/FileHandler.kt
actual class FileHandler {
    private val documentsDir: NSString
        get() = NSSearchPathForDirectoriesInDomains(
            NSDocumentDirectory,
            NSUserDomainMask,
            true
        ).first() as NSString

    actual suspend fun readText(fileName: String): Result<String> {
        return withContext(Dispatchers.Main) {
            try {
                val path = documentsDir.stringByAppendingPathComponent(fileName)
                val content = NSString.stringWithContentsOfFile(path) as String?
                if (content != null) Result.success(content)
                else Result.failure(IOException("File not found: $fileName"))
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    // ...
}
```

**Why Abstracted:** File I/O APIs are completely different (java.io.File vs NSFileManager). Used for caching and local data persistence.

---

## Platform Utilities

### PlatformInfo

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/util/PlatformInfo.kt`

**Expect Declaration:**
```kotlin
expect object PlatformInfo {
    val platformName: String
    val appVersion: String
    val buildNumber: String
    val deviceModel: String
}
```

**Android Actual:**
```kotlin
// shared/src/androidMain/kotlin/com/krutsche/xcamp/util/PlatformInfo.kt
actual object PlatformInfo {
    actual val platformName: String = "Android"
    actual val appVersion: String = BuildConfig.VERSION_NAME
    actual val buildNumber: String = BuildConfig.VERSION_CODE.toString()
    actual val deviceModel: String = android.os.Build.MODEL
}
```

**iOS Actual:**
```kotlin
// shared/src/iosMain/kotlin/com/krutsche/xcamp/util/PlatformInfo.kt
actual object PlatformInfo {
    actual val platformName: String = "iOS"
    actual val appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?: "unknown"
    actual val buildNumber: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?: "unknown"
    actual val deviceModel: String = UIDevice.currentDevice.model
}
```

**Why Abstracted:** Accessing app version and device info requires platform-specific APIs. Used for analytics and debugging.

### DateTimeUtils

**Location:** `shared/src/commonMain/kotlin/com/krutsche/xcamp/util/DateTimeUtils.kt`

**Expect Declaration:**
```kotlin
expect object DateTimeUtils {
    fun currentTimeMillis(): Long
    fun formatEventDate(timestamp: Long): String
    fun formatEventTime(timestamp: Long): String
}
```

**Why Abstracted:** Date formatting uses platform-specific locales and formats. Used throughout the app for displaying event times.

---

## Summary Statistics

| Category | Count | Purpose |
|----------|-------|---------|
| Logging | 1 | Unified logging interface |
| Firebase | 4 | Cross-platform Firebase SDK abstraction |
| Database | 1 | SQLDelight driver abstraction |
| File I/O | 1 | Platform file system access |
| Platform Utils | 2 | Device info, date/time |
| **Total** | **9** | **All platform-specific APIs** |

---

## When to Add New expect/actual

Consider adding a new expect/actual when:

1. **Code needs to run on both Android and iOS**
2. **The implementation differs by platform**
3. **The API is complex enough that duplication would be error-prone**
4. **The abstraction doesn't create a leaky interface**

**Example where expect/actual is NOT needed:**
```kotlin
// ❌ BAD - Simple enough to duplicate or use common code
expect fun add(a: Int, b: Int): Int
```

**Example where expect/actual IS needed:**
```kotlin
// ✅ GOOD - Platform APIs differ significantly
expect fun getSecureStorage(): SecureStorage
```

---

## Best Practices

1. **Keep the expect declaration minimal** - Only include methods actually needed
2. **Return platform-agnostic types** - Use Result, List, Map instead of platform types
3. **Document platform differences** - Explain why abstraction is needed
4. **Test both implementations** - Ensure consistent behavior across platforms
5. **Consider kotlinx alternatives** - Check if a KMP library already exists
