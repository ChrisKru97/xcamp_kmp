# iOS Component Generator Subagent

Expert guidance for creating new SwiftUI components in the XcamP KMP project following strict architecture patterns.

## Trigger Keywords
create ios component, swiftui view, new ios component, ios view, make component, add view, create swiftui component

## Platform Requirements
- **Minimum**: iOS 14.1+
- **Language**: Swift 5.0
- **Bundle ID**: `com.krutsche.xcamp`
- **UI Framework**: SwiftUI
- **IDE**: Xcode (open with `open iosApp/iosApp.xcodeproj`)

## Component Creation Workflow

### Step 1: Duplicate Detection (CRITICAL)

Before creating any component, ALWAYS search for existing similar components:

```bash
# Find all existing components by type
grep -r "struct.*Tile: View" iosApp/iosApp/components/
grep -r "struct.*Card: View" iosApp/iosApp/components/
grep -r "struct.*Grid: View" iosApp/iosApp/components/
grep -r "struct.*Button: View" iosApp/iosApp/components/

# List all components with line counts
find iosApp/iosApp/components -name "*.swift" -exec wc -l {} \; | sort -rn

# Search for specific patterns
grep -r "LinkTile" iosApp/iosApp/components/
grep -r "GlassCard" iosApp/iosApp/components/
```

**Warning Triggers** - Stop and ask user if:
- Component type already exists (e.g., user wants "ContactTile" but `LinkTile` exists)
- Description matches existing component (>80% similar)
- Component would be used < 3 times (suggest inline instead)

**Consolidation Guidance**:
- If >80% similar to existing → use existing or consolidate into generic
- If only data source differs → use generics/protocols
- If 3+ similar components → extract common pattern

### Step 2: Determine Component Type

Ask clarifying questions:
1. **Location**: Should this go in `common/` (reusable) or `components/{feature}/` (feature-specific)?
2. **Reusability**: Will this be used in multiple places or just once?
3. **Generic vs Specific**: Should this work with different data types (generic) or is it feature-specific?
4. **Data source**: Where does data come from? (AppViewModel, local state, or passed parameters)

### Step 3: Choose Component Category

| Category | Description | Location | Example |
|----------|-------------|----------|---------|
| **Common/Generic** | Reusable across features, uses generics/protocols | `components/common/` | `GlassCard`, `LinkTile` |
| **Feature-Specific** | Single feature use, tight coupling to feature logic | `components/{feature}/` | `CountdownView`, `EmergencyPill` |
| **Screen/View** | Full-screen composition, navigation target | `views/` | `HomeView`, `ScheduleView` |
| **Utility** | Helper functions, design tokens, extensions | `utils/` | `Spacing`, `GridColumns` |

### Step 4: Design Guidelines

#### Generic Component Pattern (Recommended for Reusability)

Use when: Same UI pattern appears 3+ times with >80% code similarity

```swift
// Protocol-based generic component
struct GenericTile<T: TileData>: View {
    let item: T

    var body: some View {
        Button { action(item) } label: {
            VStack(spacing: Spacing.sm) {
                Image(systemName: item.icon)
                Text(item.title)
            }
        }
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

#### Feature-Specific Component Pattern

Use when: Unique behavior, complex interactions, feature-specific state

```swift
struct EmergencyPill: View {
    let title: String
    let description: String
    @State private var isExpanded = false

    var body: some View {
        Button { isExpanded.toggle() } label: {
            VStack(spacing: Spacing.sm) {
                HStack {
                    Text(title)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                if isExpanded {
                    Text(description)
                }
            }
        }
    }
}
```

## iOS Component Templates

### Template 1: Generic Data Component (Reusable)

**File**: `iosApp/iosApp/components/common/GenericTile.swift`

```swift
import SwiftUI
import shared

struct GenericTile<T: TileData>: View {
    let item: T
    let action: (T) -> Void

    @State private var isPressed = false

    init(item: T, action: @escaping (T) -> Void = { _ in }) {
        self.item = item
        self.action = action
    }

    var body: some View {
        Button {
            isPressed.toggle()
            action(item)
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

// MARK: - Protocol
protocol TileData {
    var icon: String { get }
    var title: String { get }
    var url: String { get }
}

// MARK: - Preview
@available(iOS 18, *)
#Preview("Default", traits: .sizeThatFitsLayout) {
    GenericTile(item: ExampleTileData(
        icon: "star.fill",
        title: "Example Title",
        url: "https://example.com"
    ))
    .padding(Spacing.md)
    .background(Color("background"))
}

// MARK: - Preview Data
struct ExampleTileData: TileData {
    let icon: String
    let title: String
    let url: String
}
```

### Template 2: Feature-Specific Component with AppViewModel

**File**: `iosApp/iosApp/components/{feature}/FeatureView.swift`

```swift
import SwiftUI
import shared

struct FeatureView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        GlassCard {
            VStack(spacing: Spacing.sm) {
                Text(Strings.Feature.shared.TITLE)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(appViewModel.getSomeService().getData())
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        // Access shared logic via AppViewModel
        // All business logic is in Kotlin
    }
}

// MARK: - Preview
@available(iOS 18, *)
#Preview("Default", traits: .sizeThatFitsLayout) {
    FeatureView()
        .environmentObject(AppViewModel())
        .padding(Spacing.md)
        .background(Color("background"))
}
```

### Template 3: Expandable/Collapsible Component

**File**: `iosApp/iosApp/components/common/ExpandableCard.swift`

```swift
import SwiftUI

struct ExpandableCard: View {
    let title: String
    let content: String
    let icon: String

    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: isExpanded ? Spacing.sm : 0) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)

                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }

                if isExpanded {
                    Text(content)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, Spacing.lg + Spacing.md)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.medium))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isExpanded)
    }
}

// MARK: - Preview
@available(iOS 18, *)
#Preview("Expanded", traits: .sizeThatFitsLayout) {
    ExpandableCard(
        title: "Example Title",
        content: "This is the expandable content that appears when you tap the card.",
        icon: "info.circle.fill"
    )
    .padding(Spacing.md)
    .background(Color("background"))
}
```

### Template 4: Simple Display Component (Pure UI)

**File**: `iosApp/iosApp/components/common/SimpleBadge.swift`

```swift
import SwiftUI

struct SimpleBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Preview
@available(iOS 18, *)
#Preview("Variants", traits: .sizeThatFitsLayout) {
    HStack(spacing: Spacing.sm) {
        SimpleBadge(text: "New", color: .blue)
        SimpleBadge(text: "Updated", color: .green)
        SimpleBadge(text: "Important", color: .red)
    }
    .padding(Spacing.md)
    .background(Color("background"))
}
```

## Design Token Usage

**ALWAYS use design tokens from `utils/` - never hardcode values:**

```swift
// Spacing
.padding(Spacing.xs)           // 4
.padding(Spacing.sm)           // 8
.padding(Spacing.md)           // 16
.padding(Spacing.lg)           // 24
.padding(Spacing.xl)           // 32
.padding(Spacing.xxl)          // 48

.spacing(Spacing.sm)           // For VStack/HStack

// CornerRadius
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))       // 8
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))      // 12
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.large))       // 16
.clipShape(RoundedRectangle(cornerRadius: CornerRadius.extraLarge))  // 24

// Glass effect
.glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.medium))

// Colors
.foregroundStyle(.primary)
.foregroundStyle(.secondary)
.foregroundStyle(.tertiary)
.background(Color("background"))
.background(Color("primary"))
```

**Reference**: `iosApp/iosApp/utils/Spacing.swift`, `iosApp/iosApp/utils/CornerRadius.swift`

## String Management (CRITICAL)

**ALL user-facing strings MUST be in `Strings.kt` (shared module)**

### Adding New Strings

1. Open `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt`
2. Add nested object for feature:

```kotlin
object Strings {
    object FeatureName {
        const val TITLE = "Název funkce"
        const val DESCRIPTION = "Popis funkce"
        const val BUTTON_TEXT = "Tlačítko"
        const val ERROR_MESSAGE = "Chyba při načítání"
    }
}
```

3. Use in Swift:

```swift
// GOOD - Use Strings.kt
Text(Strings.FeatureName.shared.TITLE)
Button(Strings.FeatureName.shared.BUTTON_TEXT) { }

// BAD - Hardcoded strings
Text("Feature Title")
Button("Click me") { }
```

**See `.claude/subagents/strings-management.md` for complete patterns.**

## iOS Version Compatibility

Use the backport namespace pattern for version-specific APIs:

```swift
// Use the backport namespace for version-specific APIs
content.backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
iconView.backport.bounceSymbol(trigger: isPressed)
buttonView.backport.impactFeedback(trigger: isPressed)
```

**Do NOT use inline `#available` checks** in your views - the backport namespace handles version compatibility internally.

### Available Backports

| Backport Method | Modern API | Fallback | Min iOS |
|----------------|-----------|----------|---------|
| `.backport.glassEffect(in:)` | iOS 26.0 `.glassEffect(.clear, in:)` | `.background(.ultraThinMaterial, in:)` | 15.0+ |
| `.backport.bounceSymbol(trigger:)` | iOS 17.0 `.symbolEffect(.bounce, value:)` | No-op | 15.0+ |
| `.backport.impactFeedback(trigger:)` | iOS 17.0 `.sensoryFeedback(.impact(flexibility: .soft), trigger:)` | No-op | 15.0+ |

**Reference**: `iosApp/iosApp/utils/BackportModifiers.swift`

## KISS/DRY Decision Guidelines

### When to Create Generic Components

**Create generic when**:
- Same pattern appears 3+ times
- >80% code similarity between components
- Only data source differs
- Need multiple variants with same behavior

**Example**: `LinkTile<T: LinkData>` for InfoLink and MediaLink

### When to Keep Feature-Specific Components

**Keep separate when**:
- Unique interactions or animations
- Complex conditional logic
- Platform-specific behavior (iOS version requirements)
- Significantly different layouts

**Example**: `EmergencyPill` (expandable state, specific animation)

### Avoid Over-Abstraction

**Don't create generic components for**:
- One-off UI elements
- Components used < 3 times
- Things that might change differently per feature

## Component Checklist

### Before Creating Component
- [ ] Searched existing components for duplicates?
- [ ] Verified no similar component exists in `components/common/`?
- [ ] Confirmed strings exist in `Strings.kt` or added them?
- [ ] Chose correct location (`common/`, `feature/`, or `views/`)?

### For iOS Components
- [ ] Component under 100 lines (preferably under 50)?
- [ ] Single responsibility (one clear purpose)?
- [ ] No business logic (all in Kotlin shared)?
- [ ] Uses design tokens (Spacing, CornerRadius)?
- [ ] Preview with `@available(iOS 18, *)` and `traits: .sizeThatFitsLayout`?
- [ ] `AppViewModel()` environment object in preview if needed?
- [ ] No hardcoded strings (all from Strings.kt)?
- [ ] Proper iOS version handling if needed?

### For Generic Components
- [ ] Protocol defined for data type?
- [ ] Existing types extended to conform?
- [ ] Type parameter name descriptive (e.g., `T: TileData`)?
- [ ] Preview includes example data?

## Component Naming Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Views/Screen-level | PascalCase + "View" suffix | `HomeView`, `ScheduleView` |
| Components | PascalCase descriptive name | `CountdownView`, `EmergencyPill`, `LinkTile` |
| Generic components | Include type parameter | `LinkTile<T: LinkData>`, `GlassCard<Content: View>` |
| Protocols | PascalCase describing capability | `TileData`, `LinkData` |
| Utilities | PascalCase for types | `Spacing`, `GridColumns`, `IconProvider` |

## File Organization

```
iosApp/iosApp/
├── components/
│   ├── common/       # Generic, reusable components
│   │   ├── GlassCard.swift
│   │   ├── LinkTile.swift
│   │   └── IconProvider.swift
│   ├── home/         # Home-specific components
│   ├── media/        # Media-specific components
│   └── [feature]/    # Feature-specific ONLY when truly unique
├── views/            # Main views (HomeView, ScheduleView, etc.)
└── utils/            # Design tokens, helpers
```

**Rules**:
- Generic components in `common/`
- Feature-specific in feature folders ONLY if truly unique
- No "tile" folders with 5 nearly identical tiles
- Extract shared patterns upward

## Common Pitfalls to Avoid

1. **Hardcoded strings**: Always use `Strings.kt` - see `strings-management.md`
2. **Business logic in UI**: Move calculations to Kotlin shared module
3. **Duplicate components**: Check `components/common/` before creating new
4. **Over-genericization**: Don't make generic components for 1-2 use cases
5. **Wrapper views**: Use inline `#available` checks instead
6. **Missing previews**: Always include SwiftUI previews
7. **Inconsistent spacing**: Always use `Spacing` tokens
8. **Ignoring design tokens**: Match existing component patterns
9. **Large files**: Keep components under 100 lines (preferably under 50)
10. **Embedded components**: Never define components inside other views

## Common Commands

```bash
# Open Xcode
open iosApp/iosApp.xcodeproj

# List existing components by feature
ls -la iosApp/iosApp/components/common/
ls -la iosApp/iosApp/components/home/
ls -la iosApp/iosApp/components/media/
ls -la iosApp/iosApp/components/info/

# Find similar components (check for duplicates)
grep -r "struct.*Tile: View" iosApp/iosApp/components/
grep -r "struct.*Card: View" iosApp/iosApp/components/

# Count lines in components (avoid large files)
find iosApp/iosApp/components -name "*.swift" -exec wc -l {} \; | sort -rn

# Build for simulator
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -sdk iphonesimulator

# Clean build
xcodebuild clean -project iosApp/iosApp.xcodeproj
```

## Example Creation Flow

**User Request**: "Create a tile component for displaying contact links"

1. **Duplicate Detection**:
   ```bash
   grep -r "struct.*Tile: View" iosApp/iosApp/components/
   # Found: LinkTile.swift in common/
   ```

2. **Analysis**: `LinkTile<T: LinkData>` already exists and is generic!

3. **Decision**: Reuse existing component by extending `InfoLink` to conform to `LinkData` protocol

4. **Result**: No new component needed - use existing generic component

**User Request**: "Create an expandable emergency contact card"

1. **Duplicate Detection**:
   ```bash
   grep -r "expandable\|collapsible" iosApp/iosApp/components/
   # No matches
   ```

2. **Analysis**: New unique component with specific behavior

3. **Decision**: Create `EmergencyPill.swift` in `components/info/`

4. **Implementation**: Use Expandable Card template, add strings to `Strings.kt`

## Related Documentation

- **iOS Development**: `.claude/subagents/ios-dev.md` - SwiftUI patterns, preview requirements, NO logic in Swift
- **UI Code Review**: `.claude/subagents/ui-review.md` - KISS/DRY principles, duplicate detection, consolidation guidelines
- **Strings Management**: `.claude/subagents/strings-management.md` - ALL UI text in Strings.kt, localization patterns
- **Shared Logic**: `.claude/subagents/shared-logic.md` - Repository pattern, SQLDelight, Koin DI

## Good Examples to Reference

- **`LinkTile.swift`** - Excellent generic component with protocol-based design
- **`GlassCard.swift`** - Proper use of generics with `@ViewBuilder`
- **`EmergencyPill.swift`** - Well-designed feature-specific component with state
- **`Spacing.swift`** - Design token pattern to follow
- **`CountdownView.swift`** - Simple, focused component with clear purpose
