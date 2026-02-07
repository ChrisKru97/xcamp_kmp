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
**Spacing struct** (`utils/Spacing.swift` - includes CornerRadius):
- `xs: 4`, `sm: 8`, `md: 16`, `lg: 24`, `xl: 32`, `xxl: 48`

**CornerRadius struct** (defined in `utils/Spacing.swift`):
- `small: 8`, `medium: 12`, `large: 16`, `extraLarge: 24`

**Additional design tokens**:
- `utils/ColorExtension.swift` - Color extension with app colors
- `utils/Shadow.swift` - Shadow definitions
- `utils/Gradient.swift` - Gradient definitions

Apply consistently:
- `.padding(Spacing.md)` for outer padding
- `spacing: Spacing.md` for VStack/HStack
- `.clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))`

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

### Animation Patterns

**USE INLINE ANIMATIONS** - Do not create animation constant files.

Animations should be defined inline at their point of use. This keeps the animation behavior immediately visible and contextual.

**Preferred:**
```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
    isFavorite.toggle()
}
```

**Avoid:**
```swift
// Do NOT create AnimationConstants.swift with:
struct Animations {
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
}
```

**Common animation presets for reference:**
- Bouncy spring: `.spring(response: 0.4, dampingFraction: 0.6)`
- Standard spring: `.spring(response: 0.3, dampingFraction: 0.7)`
- Quick ease: `.easeInOut(duration: 0.2)`
- Fast fade: `.easeInOut(duration: 0.15)`

## Glass Effect Implementation

Use the backport namespace for iOS version compatibility:

```swift
// Use backport namespace for iOS version compatibility
content.backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
```

Use the reusable `GlassCard<Content: View>` component for consistency.

## SwiftUIBackports Packages

### Package Overview
The project includes shaps80 backport packages for iOS version compatibility:

| Package | Version | Repository |
|---------|---------|------------|
| SwiftUIBackports | 26.0.1 | https://github.com/shaps80/SwiftUIBackports |
| SwiftBackports | 26.0.1 | https://github.com/shaps80/SwiftBackports |

### Usage Pattern
The shaps80 packages use a namespace pattern for discoverability:

**Types (use `@Backport` prefix):**
```swift
@Backport.AppStorage("filter-enabled")
private var filterEnabled: Bool = false
```

**Modifiers (use `.backport` prefix):**
```swift
.sheet(isPresented: $showPrompt) {
    Prompt()
        .backport.presentationDetents([.medium, .large])
}
```

**Environment values:**
```swift
@Environment(\.backportRefresh) private var refreshAction
```

### Key Backports Available

**SwiftUI:**
- `AsyncImage`, `AppStorage`, `ShareLink`, `StateObject`
- `presentationDetents`, `presentationDragIndicator`
- `Refreshable` (pull-to-refresh)
- `onChange`, `task`, `openURL`
- `scrollDisabled`, `scrollIndicators`, `scrollDismissesKeyboard`

**UIKit Extras:**
- `FittingGeometryReader` - Auto-sizing GeometryReader
- `FittingScrollView` - ScrollView that respects Spacers

### Local vs Package Backports

| Source | Location | Namespace | Purpose |
|--------|----------|-----------|---------|
| Local | `utils/SwiftUIBackports.swift` | `.backport` | Custom glass/transition effects (iOS 26+) |
| shaps80 Package | Swift Package | `Backport` / `.backport` | General SwiftUI backports (iOS 13+) |

**Important**: The local `SwiftUIBackports.swift` file (from superwall/iOS-Backports) provides custom glass/transition implementations. The shaps80 packages provide additional general-purpose backports. They can coexist.

## iOS Version Compatibility

**CRITICAL**: Always use the backport namespace pattern for version-specific APIs defined in `utils/SwiftUIBackports.swift`.

```swift
// Backport namespace - use this pattern instead of #available checks
content.backport.glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
```

**Do NOT use inline `#available` checks** in your views - the backport namespace handles version compatibility internally.

### Local Backport Implementation (utils/SwiftUIBackports.swift)

| Backport Method | Modern API | Min iOS | Category |
|----------------|-----------|---------|----------|
| `.backport.contentTransition(_:)` | iOS 17.0 `.contentTransition()` | 14+ | Transitions |
| `.backport.presentationSizeForm()` | iOS 18.0 `.presentationSizing(.form)` | 14+ | Presentation |
| `.backport.zoom(sourceID:in:)` | iOS 18.0 `.navigationTransition(.zoom)` | 14+ | Navigation |
| `.backport.matchedTransitionSource(id:in:)` | iOS 18.0 `.matchedTransitionSource()` | 14+ | Navigation |
| `.backport.imagePlayground(_:completion:)` | iOS 18.1 `.imagePlaygroundSheet()` | 14+ | Image |
| `.backport.glassEffect(_:in:)` | iOS 26.0 `.glassEffect()` | 14+ | Glass |
| `.backport.glassEffectTransition(_:)` | iOS 26.0 `.glassEffectTransition()` | 14+ | Glass |
| `.backport.glassEffectContainer(spacing:)` | iOS 26.0 `GlassEffectContainer` | 14+ | Glass |
| `.backport.glassButtonStyle(fallbackStyle:)` | iOS 26.0 `.buttonStyle(.glass)` | 14+ | Glass |
| `.backport.presentationBackground(in:)` | iOS 26.0 `.presentationBackground()` | 14+ | Presentation |

**Reference**: `iosApp/iosApp/utils/SwiftUIBackports.swift`

## Navigation & Toolbar

### Navigation Backport (Recommended for iOS 15+)

**CRITICAL**: Use `NavigationBackport` for navigation instead of legacy `NavigationView`. The project includes NavigationBackport v0.11.5 which provides modern `NavigationStack` APIs with iOS 15+ compatibility.

**Why**: Modern navigation with value-based linking, deep-linking support, and automatic fallback to native `NavigationStack` on iOS 16+.

**API Mapping**:
| Modern API | Backport API |
|------------|--------------|
| `NavigationStack` | `NBNavigationStack` |
| `NavigationLink(value:)` | `NBNavigationLink(value:)` |
| `NavigationPath` | `NBNavigationPath` |
| `navigationDestination(for:)` | `nbNavigationDestination(for:)` |

**Basic Usage**:
```swift
import NavigationBackport

struct ContentView: View {
    @State var path = NBNavigationPath()

    var body: some View {
        NBNavigationStack(path: $path) {
            HomeView()
                .nbNavigationDestination(for: Screen.self) { screen in
                    screen.destination
                }
        }
    }
}

enum Screen: Hashable {
    case detail(id: String)
    case settings

    @ViewBuilder var destination: some View {
        switch self {
        case .detail(let id): DetailView(id: id)
        case .settings: SettingsView()
        }
    }
}

struct HomeView: View {
    var body: some View {
        NBNavigationLink(value: Screen.detail(id: "123")) {
            Text("Go to Detail")
        }
    }
}
```

**Programmatic Navigation**:
```swift
@EnvironmentObject var navigator: PathNavigator

// Push screen
navigator.push(Screen.detail(id: "123"))
// or: path.append(Screen.detail(id: "123"))

// Pop current screen
navigator.pop()
// or: path.removeLast()

// Pop to root
navigator.popToRoot()
// or: path.removeSubrange(...)

// Pop to specific screen type
navigator.popTo(Screen.self)
```

**Deep-linking** (multiple screens in one update):
```swift
// This works even on iOS 15 - NavigationBackport breaks it into multiple updates
path.append(Screen.schedule)
path.append(Screen.day(1))
path.append(Screen.session(id: "abc"))
```

### Standard Toolbar Patterns
- `.navigationViewStyle(.automatic)` for consistency (when using NavigationView)
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
