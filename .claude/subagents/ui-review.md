# UI Code Review Subagent

Specialized guidance for code reviewing UI components (Android Jetpack Compose and iOS SwiftUI) with emphasis on KISS and DRY principles in the XcamP KMP project.

## Trigger Keywords
code review, UI, component, refactor, duplicate, KISS, DRY, SwiftUI, Compose, simplify, consolidate

## Platform Requirements

### iOS
- **Minimum**: iOS 14.1+
- **Language**: Swift 5.0
- **Bundle ID**: `com.krutsche.xcamp`
- **UI Framework**: SwiftUI

### Android
- **Minimum**: API 24 (Android 7.0 Nougat)
- **Language**: Kotlin 2.2.20
- **Bundle ID**: `cz.krutsche.xcamp`
- **UI Framework**: Jetpack Compose

## Code Review Philosophy

### KISS (Keep It Simple, Stupid)
- **Remove unnecessary abstractions** - If a wrapper doesn't add value, delete it
- **Prefer direct usage** - Use `#available` checks inline, not in separate wrapper views
- **Avoid over-engineering** - Don't create generic components for one-off use cases

### DRY (Don't Repeat Yourself)
- **Rule of Three** - When a pattern appears 3+ times, extract it
- **>80% similarity threshold** - If components differ by only ~20%, consolidate them
- **Parameter differences only** - If the only difference is data source, use generics

### When to Abstract vs When to Duplicate

**Consolidate when**:
- Same pattern appears 3+ times
- >80% code similarity between components
- Only parameter/data differences
- Same behavior and interaction patterns

**Keep separate when**:
- Distinct behaviors or interactions
- Different platform requirements (iOS version, API level)
- Significantly different layouts
- Complex conditional logic that would make generic version unclear

## Violation Detection

### Search Commands for Finding Duplicates

```bash
# Find duplicate SwiftUI View structures
grep -r "struct.*Tile: View" iosApp/iosApp/components/
grep -r "struct.*Grid: View" iosApp/iosApp/components/
grep -r "struct.*Card: View" iosApp/iosApp/components/

# Find duplicate Composable functions (Android)
grep -r "@Composable.*fun.*Tile" composeApp/
grep -r "@Composable.*fun.*Card" composeApp/

# Count lines in components (flag files >100 lines)
find iosApp/iosApp/components -name "*.swift" -exec wc -l {} \;
find composeApp -name "*Compose.kt" -exec wc -l {} \;

# Find wrapper patterns (potential anti-pattern)
grep -r "Wrapper: View" iosApp/iosApp/views/
grep -r "Wrapper" iosApp/iosApp/views/ --include="*.swift"

# Find duplicate icon providers
grep -r "IconProvider" iosApp/iosApp/components/
```

### Common Anti-Patterns to Flag

1. **Unnecessary Wrappers** - Views that only check iOS version
   ```swift
   // BAD - Wrapper adds no value
   struct InfoViewWrapper: View {
       var body: some View {
           if #available(iOS 26.0, *) { InfoView() }
           else { InfoViewLegacy() }
       }
   }
   ```

2. **Duplicate Tile/Card Components** - Minor variations of the same pattern
   ```
   ContactTile.swift  (59 lines)
   MediaTile.swift    (47 lines, 90% identical)
   ```

3. **Repetitive Grid Definitions** - Same column layouts repeated
   ```swift
   // ContactGrid.swift
   private let columns = [
       GridItem(.flexible(), spacing: Spacing.md),
       GridItem(.flexible(), spacing: Spacing.md)
   ]
   // MediaGrid.swift - IDENTICAL
   ```

4. **Similar Icon Providers** - Same structure, different cases
   ```
   InfoIconProvider.swift
   MediaIconProvider.swift
   ```

5. **Repeated Styling Code** - Same modifiers applied in multiple places

## Component Consolidation Guidelines

### Generic Component Pattern (iOS)

**Before** - Duplicate components:
```swift
// ContactTile.swift - 59 lines
struct ContactTile: View {
    let icon: String
    let title: String
    let url: String
    @State private var isPressed = false
    var body: some View {
        Button { isPressed.toggle(); UrlOpener.shared.openUrl(url: url) } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: icon)...
                Text(title)...
            }
            .padding(.vertical, Spacing.lg)
            .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

// MediaTile.swift - 47 lines, nearly identical
struct MediaTile: View {
    let link: MediaLink
    // Same body, just accesses link.icon, link.title, link.url
}
```

**After** - Generic component:
```swift
// GenericTile.swift - Single implementation
struct GenericTile<T: TileData>: View {
    let item: T

    @State private var isPressed = false

    var body: some View {
        Button {
            isPressed.toggle()
            UrlOpener.shared.openUrl(url: item.url)
        } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.7))
                    .symbolEffect(.bounce, value: isPressed)

                Text(item.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
            .padding(.horizontal, Spacing.sm)
            .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
    }
}

protocol TileData {
    var icon: String { get }
    var title: String { get }
    var url: String { get }
}

// Extend existing types to conform
extension InfoLink: TileData {
    var icon: String { InfoIconProvider.iconName(for: self) }
}
extension MediaLink: TileData {
    var icon: String { MediaIconProvider.iconName(for: self) }
}
```

### Grid Layout Consolidation

**Before** - Duplicate column definitions:
```swift
// ContactGrid.swift
private let columns = [
    GridItem(.flexible(), spacing: Spacing.md),
    GridItem(.flexible(), spacing: Spacing.md)
]

// MediaGrid.swift - IDENTICAL
private let columns = [
    GridItem(.flexible(), spacing: Spacing.md),
    GridItem(.flexible(), spacing: Spacing.md)
]
```

**After** - Shared utility:
```swift
// utils/GridColumns.swift
enum GridColumns {
    static let twoColumn = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
}

// Usage
struct ContactGrid: View {
    private let columns = GridColumns.twoColumn
    // ...
}
```

### Wrapper Elimination

**Before** - Unnecessary wrapper:
```swift
// InfoView.swift
struct InfoViewWrapper: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            InfoView()
        } else {
            InfoViewLegacy()
        }
    }
}

// ContentView.swift
case .info:
    InfoViewWrapper()  // Wrapper adds no value
```

**After** - Direct version check:
```swift
// ContentView.swift
case .info:
    if #available(iOS 26.0, *) {
        InfoView()
    } else {
        InfoViewLegacy()
    }
```

## iOS SwiftUI Review Checklist

### Component Design
- [ ] Component under 100 lines (preferably under 50)
- [ ] Single responsibility (one clear purpose)
- [ ] Generic type parameters used for similar patterns
- [ ] No unnecessary wrapper views
- [ ] Preview included with `@available(iOS 18, *)` and `traits: .sizeThatFitsLayout`
- [ ] `AppViewModel()` environment object included in preview

### DRY Verification
- [ ] No duplicate tile/card components (consolidate into generic)
- [ ] Grid layouts use shared column configurations
- [ ] Icon providers unified where appropriate
- [ ] Styling code extracted to reusable components
- [ ] Design tokens (Spacing, CornerRadius) used consistently

### KISS Verification
- [ ] No unnecessary abstractions
- [ ] Direct property access preferred over wrapper
- [ ] Platform version checks inline, not in separate wrappers
- [ ] Business logic delegated to Kotlin (AppViewModel)
- [ ] No "God views" that try to do too much

## Android Jetpack Compose Review Checklist

### Component Design
- [ ] Composable functions have single responsibility
- [ ] Preview support with `@Preview` annotation
- [ ] Generic type parameters used for similar patterns
- [ ] State properly hoisted
- [ ] Material 3 components preferred

### DRY Verification
- [ ] No duplicate composable functions with minor variations
- [ ] Common layouts extracted to reusable composables
- [ ] Styling consolidated into theme/UiKit
- [ ] LazyColumn/LazyRow patterns follow common patterns
- [ ] Design tokens defined in `ui/theme/`

### KISS Verification
- [ ] No unnecessary ViewModels for simple UI state
- [ ] Business logic delegated to Kotlin shared module
- [ ] `remember` used appropriately vs `rememberSaveable`
- [ ] No over-abstraction with generic components for one-off use

## Design Token Consistency

### iOS (`utils/Spacing.swift`, `utils/CornerRadius.swift`)

**Spacing**:
```swift
xs: 4,   // Tight spacing
sm: 8,   // Small spacing
md: 16,  // Default spacing
lg: 24,  // Large spacing
xl: 32,  // Extra large spacing
xxl: 48  // Section spacing
```

**CornerRadius**:
```swift
small: 8,       // Small elements
medium: 12,     // Cards, buttons
large: 16,      // Large cards
extraLarge: 24  // Sheets, modals
```

**Usage**:
```swift
.padding(Spacing.md)
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
```

### Android (define equivalent in `ui/theme/`)

Match iOS values for cross-platform consistency:
```kotlin
object Spacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 16.dp
    val lg = 24.dp
    val xl = 32.dp
    val xxl = 48.dp
}

object CornerRadius {
    val small = 8.dp
    val medium = 12.dp
    val large = 16.dp
    val extraLarge = 24.dp
}
```

## File Organization Review

### Recommended iOS Structure
```
iosApp/iosApp/
├── components/
│   ├── common/       # Generic, reusable components (GlassCard, buttons)
│   ├── [feature]/    # Feature-specific ONLY when truly unique
├── views/            # Main views (HomeView, ScheduleView, etc.)
└── utils/            # Design tokens, helpers
```

**Rules**:
- Generic components in `common/`
- Feature-specific in feature folders ONLY if truly unique
- No "tile" folders with 5 nearly identical tiles
- Extract shared patterns upward

### Recommended Android Structure
```
composeApp/src/main/java/cz/krutsche/xcamp/
├── ui/
│   ├── components/   # Reusable composables
│   ├── theme/        # Design tokens, colors, typography
│   └── screens/      # Screen-level composables
└── viewmodel/        # Android-specific ViewModels
```

## Refactoring Workflow

1. **Identify duplicates** using search commands
2. **Analyze similarity** - Is it >80%? Only parameter differences?
3. **Design generic version** using protocols (iOS) or interfaces (Android)
4. **Extend existing types** to conform to new protocol/interface
5. **Update all usages** to use generic component
6. **Delete old duplicate files**
7. **Test thoroughly**:
   - Run SwiftUI previews
   - Build and run on simulator
   - Verify visual consistency
8. **Verify design tokens** - Spacing, CornerRadius applied consistently

## Common Commands for Code Review

```bash
# Find all SwiftUI views with line counts
find iosApp/iosApp -name "*.swift" | while read f; do echo "$(wc -l < "$f") $f"; done | sort -rn

# Find all Compose functions with line counts
find composeApp -name "*.kt" | while read f; do echo "$(wc -l < "$f") $f"; done | sort -rn

# Compare two files for similarity
diff -u iosApp/iosApp/components/info/ContactTile.swift iosApp/iosApp/components/media/MediaTile.swift

# Build and test iOS
open iosApp/iosApp.xcodeproj

# Build and test Android
./gradlew :composeApp:installDebug
```

## Known Violations in This Codebase

### High Priority (Actionable)

1. **ContactTile + MediaTile** ([`components/info/ContactTile.swift`](iosApp/iosApp/components/info/ContactTile.swift), [`components/media/MediaTile.swift`](iosApp/iosApp/components/media/MediaTile.swift))
   - 90% duplicate code
   - Only difference is data source (individual params vs link object)
   - **Action**: Consolidate into `GenericTile<T: TileData>`

2. **InfoViewWrapper + MediaViewWrapper** ([`views/InfoView.swift`](iosApp/iosApp/views/InfoView.swift), [`views/MediaView.swift`](iosApp/iosApp/views/MediaView.swift))
   - Unnecessary wrapper pattern
   - Version check could be inline in ContentView
   - **Action**: Remove wrappers, use `#available` check directly in ContentView

3. **ContactGrid + MediaGrid** ([`components/info/ContactGrid.swift`](iosApp/iosApp/components/info/ContactGrid.swift), [`components/media/MediaGrid.swift`](iosApp/iosApp/components/media/MediaGrid.swift))
   - Identical column definitions
   - **Action**: Create `GridColumns.twoColumn` utility

### Medium Priority (Consider)

4. **InfoIconProvider + MediaIconProvider** ([`components/info/InfoIconProvider.swift`](iosApp/iosApp/components/info/InfoIconProvider.swift), [`components/media/MediaIconProvider.swift`](iosApp/iosApp/components/media/MediaIconProvider.swift))
   - Similar structure, different cases
   - **Action**: Consider unifying if more icon types added

## Good Examples to Reference

### Excellent Generic Component
**[`GlassCard.swift`](iosApp/iosApp/components/common/GlassCard.swift)**:
```swift
struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    // Proper use of generics for true flexibility
}
```

### Well-Designed Design Tokens
**[`Spacing.swift`](iosApp/iosApp/utils/Spacing.swift)**, **[`CornerRadius.swift`](iosApp/iosApp/utils/CornerRadius.swift)**:
- Single source of truth
- Consistent naming
- Used throughout codebase

### Good Component Encapsulation
**[`EmergencyPill.swift`](iosApp/iosApp/components/info/EmergencyPill.swift)**:
- Single responsibility
- Clear purpose
- Reusable

## Post-Review Verification

After code review passes, the implementation agent MUST:

1. **Build the app** via MCP tools (`build_run_sim`)
2. **Screenshot** the feature to verify visual state
3. **Interact** with all UI elements using `tap`, `swipe`, `gesture`
4. **Check logs** for errors via `launch_app_logs_sim`

This is NOT optional - no feature is complete until visually verified in simulator!
