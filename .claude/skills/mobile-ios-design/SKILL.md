---
name: mobile-ios-design
description: Master iOS Human Interface Guidelines and SwiftUI patterns for building native iOS apps. Use when designing iOS interfaces, implementing SwiftUI views, or ensuring apps follow Apple's design principles.
---

# iOS Design with Human Interface Guidelines & SwiftUI

This skill provides comprehensive guidance on designing and implementing native iOS applications following Apple's Human Interface Guidelines (HIG) and leveraging SwiftUI effectively.

## Core Principles

### iOS Design Philosophy
Apple's design philosophy centers on three key principles:

1. **Clarity**: Text is legible at every size, icons are precise, and adornments are subtle. Use negative space to make content feel breathable and important elements stand out.

2. **Deference**: The UI is fluid and helps users understand and interact with content without competing with it. Motion, depth, and blurring convey hierarchy and vitality.

3. **Depth**: Visual layers and realistic motion convey hierarchy and vitality. Transitions provide continuity and help users understand relationships between content.

### SwiftUI Principles
- **Declarative syntax**: Describe what the UI should do, not how to do it
- **Compose views**: Build complex views by combining simple ones
- **Single source of truth**: State drives the view, view updates state
- **Animations are easy**: Most animations require just a few lines of code

## Layout and Spacing

### Standard Margins and Spacing
Apple uses a consistent spacing system across iOS:

- **16pt** (standard margin): Default horizontal padding for most content
- **20pt** (large margin): Used in landscape and larger containers
- **8pt** (tight spacing): Between related elements
- **12pt** (relaxed spacing): Between groups of related content
- **44pt** (touch target): Minimum tappable area for interactive elements

```swift
// Standard spacing pattern
VStack(alignment: .leading, spacing: 8) {
    Text("Title")
        .font(.headline)
    Text("Description")
        .font(.body)
        .foregroundStyle(.secondary)
}
.padding(.horizontal, 16)  // Standard horizontal margin
```

### Safe Areas
Always respect safe areas to avoid notch, home indicator, and other system UI:

```swift
VStack {
    Text("Content")
}
.padding(.horizontal, 16)  // Horizontal padding only
// Safe area insets handled automatically by VStack when placed in NavigationView
```

### Adaptive Layouts
Design for different screen sizes using size classes and adaptive containers:

```swift
@Environment(\.horizontalSizeClass) var horizontalSizeClass

var body: some View {
    if horizontalSizeClass == .compact {
        // iPhone portrait - vertical layout
        VStack { /* ... */ }
    } else {
        // iPad or landscape - horizontal layout
        HStack { /* ... */ }
    }
}
```

### Lazy Containers
For performance with large datasets:

```swift
// LazyVStack - creates views only when needed
LazyVStack(spacing: 12) {
    ForEach(items) { item in
        ItemRow(item: item)
    }
}

// LazyVGrid - grid layouts
LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

## Typography

### System Font Styles
SwiftUI provides semantic font styles that adapt to user's font size preferences:

```swift
Text("Large Title").font(.largeTitle)      // 34pt bold
Text("Title").font(.title)                  // 28pt bold
Text("Title 2").font(.title2)               // 22pt bold
Text("Title 3").font(.title3)               // 20pt semibold
Text("Headline").font(.headline)            // 17pt semibold (body bold)
Text("Body").font(.body)                    // 17pt regular
Text("Callout").font(.callout)              // 16pt regular
Text("Subheadline").font(.subheadline)      // 15pt regular
Text("Footnote").font(.footnote)            // 13pt regular
Text("Caption").font(.caption)              // 12pt regular
Text("Caption 2").font(.caption2)           // 11pt regular
```

### Supporting Dynamic Type
Use relative styles and support text scaling:

```swift
// Semantic font styles automatically support Dynamic Type
Text("Content")
    .font(.body)

// Test with different sizes in Preview
#Preview {
    VStack {
        Text("Dynamic Type Support")
            .font(.headline)
        Text("This text scales with user's font size preference")
            .font(.body)
    }
    .environment(\.sizeCategory, .accessibilityExtraLarge)
}
```

### Font Weight and Design
```swift
// Available weights: ultraLight, thin, light, regular, medium, semibold, bold, heavy, black
Text("Bold Text").fontWeight(.bold)

// Custom font
Text("Custom Font").font(.custom("SF Pro Display", size: 17, relativeTo: .body))
```

### Text Line Limits and Truncation
```swift
// Limited lines with truncation
Text("Long text that might need truncation")
    .lineLimit(2)
    .truncationMode(.tail)

// Preserve layout with minimum scale factor
Text("Important text")
    .lineLimit(1)
    .minimumScaleFactor(0.75)  // Scale down to fit instead of truncating
```

## Color System

### Semantic Colors
Use semantic colors for automatic dark mode support and consistency:

```swift
// Hierarchical colors for text
.foregroundStyle(.primary)      // Main content
.foregroundStyle(.secondary)    // Secondary content
.foregroundStyle(.tertiary)     // Disabled/emphasis reduced

// Background colors
.background(.regularMaterial)   // Standard background
.background(.thinMaterial)      // Lighter background
.background(.thickMaterial)     // Heavier background
.background(.ultraThinMaterial)
.background(.ultraThickMaterial)
```

### Custom Colors with Asset Catalogs
Define colors in Asset Catalog for light/dark mode variants:

```swift
// Color defined in Asset Catalog
extension ShapeStyle where Self == Color {
    static var brandPrimary: Color { "BrandPrimary" }
    static var brandSecondary: Color { "BrandSecondary" }
}

// Usage
Text("Brand Text")
    .foregroundStyle(.brandPrimary)
```

### Gradient Overlays
```swift
// Linear gradient
ZStack {
    // Content
    VStack { /* ... */ }
}
.background(
    LinearGradient(
        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
)
```

## Navigation Patterns

### NavigationStack (iOS 16+)
The modern, type-safe navigation API:

```swift
struct ContentView: View {
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    Text(item.name)
                }
            }
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
        }
    }
}
```

### Tab Navigation
Primary navigation for top-level app sections:

```swift
TabView(selection: $selectedTab) {
    HomeView()
        .tabItem {
            Label("Home", systemImage: "house.fill")
        }
        .tag(Tab.home)

    SearchView()
        .tabItem {
            Label("Search", systemImage: "magnifyingglass")
        }
        .tag(Tab.search)
}
```

### Sheet Presentation
Modal presentation for focused tasks:

```swift
struct ContentView: View {
    @State private var presentingSheet = false

    var body: some View {
        Button("Present Sheet") {
            presentingSheet = true
        }
        .sheet(isPresented: $presentingSheet) {
            SheetContent()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
```

### Navigation Split View
For iPad and landscape layouts:

```swift
NavigationSplitView {
    // Sidebar
    List(sidebarItems, selection: $selectedItem) { /* ... */ }
} detail: {
    // Detail view
    DetailView(item: selectedItem)
}
```

## Feedback Patterns

### Haptic Feedback
Provide tactile confirmation for important actions:

```swift
// Button with haptic feedback
Button("Submit") {
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
    // Perform action
}

// Selection feedback
Toggle("Setting", isOn: $setting)
    .onChange(of: setting) {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }

// Notification feedback
func showSuccess() {
    let notification = UINotificationFeedbackGenerator()
    notification.notificationOccurred(.success)
}
```

### Visual Feedback
Use animations and state changes to confirm actions:

```swift
@State private var isLiked = false

Button {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
        isLiked.toggle()
    }
    // Add haptic feedback here
} label: {
    Image(systemName: isLiked ? "heart.fill" : "heart")
        .foregroundStyle(isLiked ? .red : .primary)
        .scaleEffect(isLiked ? 1.2 : 1.0)
}
```

### Progress Indicators
Keep users informed during long operations:

```swift
// Determinate progress
ProgressView(value: progress, total: 100)
    .progressViewStyle(.linear)

// Indeterminate loading
ProgressView()
    .progressViewStyle(.circular)
```

## Best Practices

### View Composition
Break complex views into smaller, reusable components:

```swift
// Composable view
struct ProfileHeader: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.title2)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

### State Management
Keep state at the appropriate level:

```swift
// Local state for view-specific data
@State private var isEditing = false

// Shared state with @Observable (iOS 17+)
@Observable
class ViewModel {
    var items: [Item] = []
    var isLoading = false
}
```

### Performance Optimization
- Use `LazyVStack`/`LazyHStack` for large lists
- Avoid expensive calculations in view body
- Use `@State` sparingly
- Extract reusable views to prevent unnecessary re-renders

### Accessibility Notes
This project has explicitly opted out of accessibility requirements. When designing for this project, focus on visual design and standard iOS patterns without implementing accessibility-specific features.

## Common Issues and Solutions

### "Cannot convert value of type 'SomeView.Type' to closure result type"
**Issue**: Missing view builder or incorrect type annotation
**Solution**: Ensure view properties return computed values, not types

```swift
// ❌ Wrong
var body: some View {
    Text // Type, not view
}

// ✅ Correct
var body: some View {
    Text("Hello") // View instance
}
```

### "Modifier may only be used on a type conforming to View"
**Issue**: Missing `Group` wrapper when branches return different types
**Solution**: Use `Group` to provide type erasure

```swift
// ✅ Correct
Group {
    if condition {
        Button("Action") { }
    } else {
        Text("Alternative")
    }
}
.frame(maxWidth: .infinity)
```

## Resources

### Apple Documentation
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)

### Reference Files
- `reference/hig-patterns.md` - Detailed HIG patterns and guidelines
- `reference/ios-navigation.md` - Navigation patterns and implementation
- `reference/swiftui-components.md` - Common SwiftUI components and patterns
