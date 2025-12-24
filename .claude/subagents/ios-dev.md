# iOS Development Subagent

Specialized guidance for iOS SwiftUI development in the XcamP KMP project.

## Trigger Keywords
SwiftUI, iOS, Swift, preview, Xcode, glass effect

## Platform Requirements
- **Minimum**: iOS 14.1+
- **Language**: Swift 5.0
- **Bundle ID**: `com.krutsche.xcamp`
- **IDE**: Xcode (open with `open iosApp/iosApp.xcodeproj`)

## SwiftUI Development Guidelines

### View Splitting Principles
- **Single Responsibility**: Each view component has one clear purpose
- **Reusable Components**: Extract common UI patterns into separate view files
- **Component Size**: Keep individual view files under 50 lines when possible, max 100 lines
- **Clear Naming**: Use descriptive names (e.g., `CountdownView`, `MainInfoCard`)
- **Separate Files**: Always keep views and components in separate files - no embedded components

### No Logic in Swift Files
**CRITICAL**: All business logic must be in Kotlin shared code.

**Swift files should ONLY contain**:
- Views, layouts, styling, animations
- Calls to Kotlin methods (via AppViewModel)
- Display of data returned from Kotlin

**Move to Kotlin**:
- Data processing, calculations
- State management and decision logic
- Conditional logic, switch cases
- Data transformations

### iOS Design Principles
- **Native iOS Aesthetics**: Prefer standard iOS design patterns
- **System Colors**: Use semantic colors from Assets.xcassets (`Color("background")`, `Color("primary")`)
- **Standard Controls**: NavigationLink, Button, List, etc.
- **Minimal Custom Styling**: Avoid excessive gradients, shadows

## SwiftUI Preview Requirements

**Mandatory for all views and components**:

```swift
@available(iOS 18, *)
#Preview("Descriptive name", traits: .sizeThatFitsLayout) {
    ComponentName(parameter: "test")
        .environmentObject(AppViewModel())
        .padding(Spacing.md)
        .background(Color("background"))
}
```

**Requirements**:
- Use `@available(iOS 18, *)` with `traits: .sizeThatFitsLayout`
- Provide descriptive names (e.g., "Upcoming event", "Ongoing event")
- Include `AppViewModel()` environment object
- Use `Color("background")` for preview background
- Include appropriate padding (`Spacing.md`)

## Coding Style Patterns

### Component Design
- **Generic Components**: Use `@ViewBuilder` for flexible content
- **Environment Objects**: Access via `@EnvironmentObject var appViewModel: AppViewModel`
- **Component Grouping**: Place in subdirectories (`components/home/`, `components/common/`)

### Layout & Spacing
**Spacing struct** (`utils/Spacing.swift`):
- `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `xxl: 48`

**CornerRadius struct** (`utils/CornerRadius.swift`):
- `small: 8`, `medium: 12`, `large: 16`, `extraLarge: 24`

Apply consistently:
- `.padding(Spacing.md)` for outer padding
- `spacing: Spacing.md` for VStack/HStack

### Styling
- **Colors**: Use named colors from Assets.xcassets
- **Typography**: `.font(.title)`, `.font(.title3)`, `.fontWeight(.semibold)`
- **Images**: SF Symbols with `Image(systemName: "info.circle")`

## Glass Effect Implementation

```swift
if #available(iOS 26.0, *) {
    // Native glass effect
} else {
    // Gradient-based fallback
}
```

Use the reusable `GlassCard<Content: View>` component for consistency.

## Navigation & Toolbar
- `.navigationViewStyle(.automatic)` for consistency
- Toolbar items: `.toolbar { ToolbarItem(placement: .principal) { ... } }`
- Extract toolbar content into separate view components

## File Organization
```
iosApp/iosApp/
├── components/
│   ├── common/       # Reusable components (GlassCard, buttons)
│   ├── home/         # Home-specific components
│   ├── media/        # Media-specific components
│   └── [feature]/    # Feature-specific components as needed
├── views/            # Main views (HomeView, ScheduleView, etc.)
└── utils/            # Spacing, CornerRadius, helpers
```

**Component Organization Patterns**:
- **Feature-based**: Group components by feature (e.g., `media/`, `home/`)
- **Generic vs Specific**: Common reusable items in `common/`, feature-specific in feature folders
- **Helper Utilities**: Extract presentation logic (e.g., icon mapping) into utility files
- **No Embedded Components**: Never define components inside view files - always separate

## Common Xcode Commands
```bash
# Open project
open iosApp/iosApp.xcodeproj

# Build for simulator
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -sdk iphonesimulator

# Clean build
xcodebuild clean -project iosApp/iosApp.xcodeproj
```
