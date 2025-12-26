# Strings Management Subagent

Specialized guidance for managing localization strings in the XcamP KMP project.

## Trigger Keywords
strings, localization, hardcoded, Czech text, string constant

## String Centralization Policy

**CRITICAL**: ALL user-facing strings must be defined in `Strings.kt` in the shared module.

**Allowed hardcoding:**
- Technical identifiers (URLs, keys, IDs)
- Debug-only strings (preview test data, developer messages)
- System log messages (not user-visible)

**Forbidden hardcoding:**
- UI text labels
- Button text
- User messages
- Error messages shown to users
- Navigation titles

## Strings.kt Structure

```
shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt
```

**Organization principles:**
- Group strings by feature/screen (e.g., `App`, `Tabs`, `Info`, `Media`)
- Use nested objects for logical grouping
- Use SCREAMING_SNAKE_CASE for constant names
- For dynamic strings, use `%s` format specifiers with `String.format()`

**Example structure:**
```kotlin
object Strings {
    object FeatureName {
        const val SIMPLE_TEXT = "Text"
        const val DYNAMIC_TEXT = "Text with %s placeholder"
        const val MULTI_PARAM = "%s and %s"
    }
}
```

## Usage Patterns

### Kotlin (Shared Module)
```kotlin
import cz.krutsche.xcamp.shared.localization.Strings

// Simple string
val text = Strings.Feature.SIMPLE_TEXT

// Dynamic string
val formatted = String.format(Strings.Feature.DYNAMIC_TEXT, "value")
```

### iOS (Swift)
```swift
import shared

// Simple string
let text = Strings.Feature.shared.SIMPLE_TEXT

// Dynamic string (use NSString format)
let formatted = String(format: Strings.Feature.shared.DYNAMIC_TEXT, "value")
```

### Android (Kotlin)
```kotlin
import cz.krutsche.xcamp.shared.localization.Strings

// Same as shared module
val text = Strings.Feature.SIMPLE_TEXT
```

## Finding Hardcoded Strings

### Search Commands

**iOS (Swift files):**
```bash
# Find hardcoded Czech strings in views
grep -rn '"[A-Z][a-záčďéěíňóřšťúůýž]*' iosApp/iosApp/views/*.swift

# Find hardcoded strings in components
grep -rn '"[A-Z][a-záčďéěíňóřšťúůýž]*' iosApp/iosApp/components/*.swift
```

**Android (Kotlin files):**
```bash
# Find hardcoded strings in Compose code
grep -rn '"[A-Z][a-záčďéěíňóřšťúůýž]*' composeApp/src/main/kotlin/
```

**Shared Module:**
```bash
# Find hardcoded strings outside Strings.kt
grep -rn '"[A-Z][a-záčďéěíňóřšťúůýž]*' shared/src/commonMain/kotlin/ \
  --exclude-dir=localization
```

### Manual Audit Checklist

When adding new UI features:
1. [ ] All user-facing text added to Strings.kt
2. [ ] iOS views use `Strings.Object.shared.CONSTANT` pattern
3. [ ] Android code uses `Strings.Object.CONSTANT` pattern
4. [ ] No hardcoded Czech text in Swift/Kotlin files
5. [ ] Dynamic strings use format specifiers

## Common Patterns

### Navigation Titles
```kotlin
// Strings.kt
object Navigation {
    const val TITLE = "Název obrazovky"
}

// Usage (iOS)
.navigationTitle(Strings.Navigation.shared.TITLE)
```

### Button Text
```kotlin
// Strings.kt
object Buttons {
    const val SUBMIT = "Odeslat"
    const val CANCEL = "Zrušit"
}
```

### Error Messages
```kotlin
// Strings.kt
object Errors {
    const val NETWORK_ERROR = "Chyba sítě"
    const val NOT_FOUND = "Polžka nenalezena: %s"
}
```

### Validation Messages
```kotlin
// Strings.kt
object Validation {
    const val REQUIRED_FIELD = "Toto pole je povinné"
    const val INVALID_EMAIL = "Neplatný e-mail"
}
```

## String Naming Conventions

- Use descriptive names that indicate context
- Prefix with feature/area: `Tabs.HOME`, `Info.MEDICAL_HELP_TITLE`
- Use specific suffixes: `_TITLE`, `_TEXT`, `_LABEL`, `_BUTTON`, `_MESSAGE`
- For variants: `_SHORT`, `_LONG`, `_ERROR`, `_SUCCESS`

**Examples:**
```kotlin
object Schedule {
    const val TAB_TITLE = "Program"           // Tab label
    const val EMPTY_STATE = "Žádné programy"  // Status message
    const val FAVORITE_ADD = "Přidat do oblíbených"
    const val FAVORITE_REMOVE = "Odebrat z oblíbených"
}

object Speakers {
    const val TAB_TITLE = "Řečníci"
    const val EMPTY_LIST = "Řečníci zatím nebyli zadáni"
    const val DETAILS_TITLE = "O řečníkovi"
}
```

## Migration Process

When finding existing hardcoded strings:

1. **Identify the string context** - Which feature/screen?
2. **Add to Strings.kt** - Create appropriate object and constant
3. **Update all usages** - Replace hardcoded strings across platforms
4. **Test thoroughly** - Verify display on both platforms
5. **Remove duplicates** - Ensure no redundant constants exist

## Advanced Patterns

### Pluralization (Future)
```kotlin
object Plurals {
    const val ONE = "den"
    const val FEW = "dny"
    const val MANY = "dní"

    fun getDays(count: Int): String {
        return when (count) {
            1 -> ONE
            in 2..4 -> FEW
            else -> MANY
        }
    }
}
```

### Platform-Specific Strings (if needed)
```kotlin
// In Strings.kt
expect object PlatformStrings {
    const val SPECIFIC_FEATURE: String
}

// In androidMain/kotlin/
actual object PlatformStrings {
    const val SPECIFIC_FEATURE = "Android specifické"
}

// In iosMain/kotlin/
actual object PlatformStrings {
    const val SPECIFIC_FEATURE = "iOS specifické"
}
```

## Quality Assurance

**Before committing:**
1. Search for any remaining hardcoded Czech strings
2. Verify all new strings use the correct pattern
3. Check for inconsistent naming
4. Ensure no duplicate constants
5. Test on both platforms

**Search command for final verification:**
```bash
# Should return only Strings.kt results
grep -r '"[A-Z][a-záčďéěíňóřšťúůýž]' \
  --include="*.kt" --include="*.swift" \
  shared/src/commonMain/kotlin/ iosApp/ composeApp/ | \
  grep -v "Strings.kt" | \
  grep -v "// " | \
  grep -v "Preview"
```
