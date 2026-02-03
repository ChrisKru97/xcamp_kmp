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

### View Body Patterns

**AVOID** - Redundant wrapper in body:
```swift
var body: some View {
    contentView  // Bad: body only returns one thing
}

private var contentView: some View {
    ScrollView { ... }
}
```

**ACCEPTABLE** - Wrapper with conditional logic in body:
```swift
var body: some View {
    if isLoading {
        LoadingView()
    } else {
        mainContentView  // Good: body has conditional logic
    }
}
```

**ACCEPTABLE** - Wrapper to avoid code duplication:
```swift
@ViewBuilder
private var imageView: some View {
    if shape == .circle {
        baseImage.clipShape(Circle())
    } else {
        baseImage.clipShape(RoundedRectangle(...))
    }
}

private var baseImage: some View { ... }  // Good: avoids duplication
```

**ACCEPTABLE** - Button labels as properties:
```swift
var body: some View {
    Button { ... } label: {
        tileContent  // Good: separates label from action
    }
}
```

**Guidelines**:
- Inline content directly when body only returns one thing
- Use wrapper properties when body has conditional logic
- Use wrapper properties to avoid duplicating complex view code
- Button labels extracted to properties are acceptable
- Toolbar items with their own logic are acceptable

### Styling
- **Colors**: Use named colors from Assets.xcassets
- **Typography**: `.font(.title)`, `.font(.title3)`, `.fontWeight(.semibold)`
- **Images**: SF Symbols with `Image(systemName: "info.circle")`

## Glass Effect Implementation

Use the backport namespace for iOS version compatibility:

```swift
// Use backport namespace for iOS version compatibility
content.backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
```

Use the reusable `GlassCard<Content: View>` component for consistency.

## iOS Version Compatibility

Use the backport namespace pattern for version-specific APIs:

```swift
// Available backports (defined in utils/BackportModifiers.swift)
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

## Post-Development Testing (MCP)

After implementing any iOS feature, use these MCP tools to verify:

### Build & Launch
- `build_run_sim` - Build and run in simulator
- `build_sim` - Build only (for quick compilation check)

### Visual Verification
- `screenshot` - Capture current screen state
- `describe_ui` - Get full UI element hierarchy with coordinates

### Interaction Testing
- `tap(x, y)` or `tap(label: "Button")` - Tap elements
- `swipe(x1, y1, x2, y2)` - Test scroll/swipe
- `gesture(preset: "scroll-down")` - Preset gestures
- `type_text("...")` - Test text input

### Log Monitoring
- `launch_app_logs_sim(bundleId)` - Launch with log capture
- `start_sim_log_cap(bundleId)` - Start log capture
- `stop_sim_log_cap(sessionId)` - Get captured logs

### Testing Checklist
- [ ] Feature renders correctly (screenshot)
- [ ] All buttons/links are tappable (describe_ui + tap)
- [ ] Navigation flows work (tap through screens)
- [ ] No runtime errors in logs
- [ ] Edge cases handled (empty states, errors)
