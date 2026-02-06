# iOS Human Interface Guidelines - Patterns Reference

This reference provides detailed patterns from Apple's Human Interface Guidelines (HIG) for implementing consistent iOS interfaces.

## Layout and Spacing Patterns

### Standard Margins

Apple's standard spacing system ensures consistent spacing across all interfaces:

| Spacing | Use Case | Value |
|---------|----------|-------|
| Standard horizontal margin | Content padding | 16pt |
| Large horizontal margin | Landscape, larger containers | 20pt |
| Tight spacing | Between related elements | 8pt |
| Relaxed spacing | Between element groups | 12pt |
| Touch target | Minimum tappable area | 44pt |

```swift
// Standard content padding
VStack(alignment: .leading, spacing: 8) {
    Text("Title")
    Text("Body text")
}
.padding(16)

// Touch target compliance
Button(action: {}) {
    Label("Action", systemImage: "chevron.right")
    .frame(minWidth: 44, minHeight: 44)  // Ensures touch target
}
```

### Safe Areas

Safe areas protect content from system UI elements (notch, home indicator):

```swift
struct ContentView: View {
    var body: some View {
        VStack {
            Text("Content")
        }
        .padding(.horizontal, 16)  // Horizontal only
        // Safe area insets for top/bottom handled by container
    }
}
```

**Guidelines:**
- Full-screen content should extend to edges (images, videos)
- Text and controls stay within safe areas
- Use `.ignoresSafeArea()` for immersive content (images, video)

### Adaptive Layouts

Design for different screen sizes using size classes:

```swift
struct AdaptiveView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        if horizontalSizeClass == .compact {
            // iPhone portrait - single column
            CompactLayout()
        } else {
            // iPad, iPhone landscape - multiple columns
            RegularLayout()
        }
    }
}
```

**Size Class Combinations:**
- iPhone portrait: Compact × Compact
- iPhone landscape: Compact × Regular (iOS 15+) or Regular × Compact (iOS 14)
- iPad portrait: Regular × Regular
- iPad landscape: Regular × Regular

### Layout Containers

**Grid layouts:**
```swift
// Two-column grid
LazyVGrid(
    columns: [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ],
    spacing: 16
) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

**Responsive columns:**
```swift
// Adaptive number of columns based on available width
LazyVGrid(
    columns: [GridItem(.adaptive(minimum: 150, maximum: 200))],
    spacing: 16
) {
    ForEach(items) { item in
        ItemCard(item: item)
    }
}
```

## Typography Hierarchy

### System Font Styles

SF Pro is iOS's system font, designed for screen readability:

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `.largeTitle` | 34pt | Bold | Page headers, prominent content |
| `.title` | 28pt | Bold | Section headers |
| `.title2` | 22pt | Bold | Subsection headers |
| `.title3` | 20pt | Semibold | Form headers |
| `.headline` | 17pt | Semibold | Emphasized body text |
| `.body` | 17pt | Regular | Primary body text |
| `.callout` | 16pt | Regular | Secondary body |
| `.subheadline` | 15pt | Regular | Labels, metadata |
| `.footnote` | 13pt | Regular | Captions, fine print |
| `.caption` | 12pt | Regular | Image captions |
| `.caption2` | 11pt | Regular | Small labels |

```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Large Title")
        .font(.largeTitle)

    Text("Headline")
        .font(.headline)

    Text("Body text with supporting information")
        .font(.body)

    Text("Additional context")
        .font(.footnote)
        .foregroundStyle(.secondary)
}
```

### Supporting Dynamic Type

Semantic font styles automatically support Dynamic Type:

```swift
Text("Scalable text")
    .font(.body)  // Scales with user's preference

// Test in preview
#Preview("Dynamic Type") {
    VStack {
        Text("Large")
            .font(.title)
        Text("Medium")
            .font(.body)
        Text("Small")
            .font(.caption)
    }
    .environment(\.sizeCategory, .accessibilityExtraLarge)
}
```

**Important:** Always test with larger text sizes to ensure layouts don't break.

### Text Styling Patterns

**Line limits and truncation:**
```swift
// Single line with tail truncation
Text("Long text that exceeds available width")
    .lineLimit(1)
    .truncationMode(.tail)

// Multiple lines
Text("Multi-line content that truncates after 3 lines")
    .lineLimit(3)
    .lineSpacing(4)
```

**Text alignment:**
```swift
// Responsive text alignment based on size class
@Environment(\.layoutDirection) var layoutDirection

var body: some View {
    Text("Content")
        .multilineTextAlignment(
            horizontalSizeClass == .compact ? .center : .leading
        )
}
```

## Color System

### Semantic Colors

Semantic colors adapt to light/dark mode automatically:

```swift
// Text colors
.foregroundStyle(.primary)      // Default text color
.foregroundStyle(.secondary)    // 60-70% opacity
.foregroundStyle(.tertiary)     // 30% opacity (disabled)

// Background materials
.background(.regularMaterial)    // Standard blur
.background(.thinMaterial)       // Lighter blur
.background(.thickMaterial)      // Heavier blur
.background(.ultraThinMaterial)
.background(.ultraThickMaterial)
```

### Custom Colors in Asset Catalog

Define colors in Xcode Asset Catalog for automatic dark mode support:

```
Asset Catalog:
- BrandPrimary
  - Light: #007AFF
  - Dark: #0A84FF
- BrandSecondary
  - Any Appearance: #5856D6
```

```swift
// Color extension for type-safe access
extension ShapeStyle where Self == Color {
    static var brandPrimary: Color { "BrandPrimary" }
    static var brandSecondary: Color { "BrandSecondary" }
}

// Usage
Text("Brand text")
    .foregroundStyle(.brandPrimary)
```

### Color Meanings

Use colors consistently with established meanings:

| Color | Standard Usage |
|-------|----------------|
| Blue | Interactive elements, links |
| Red | Destructive actions, errors |
| Orange/Yellow | Warnings |
| Green | Success, confirmations |
| Gray | Disabled, secondary content |

## Navigation Patterns

### Hierarchical Navigation

The NavigationStack pattern (iOS 16+) for drill-down interfaces:

```swift
struct ContentView: View {
    @State private var path: [Item] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
            .navigationDestination(for: Item.self) { item in
                ItemDetailView(item: item)
            }
        }
    }
}
```

### Tab-Based Navigation

Primary navigation for top-level app sections:

```swift
enum Tab: String, CaseIterable {
    case home, search, profile
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
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

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
    }
}
```

**Tab Bar Guidelines:**
- Use 3-5 tabs maximum
- Tab icons should be from SF Symbols
- Labels are required (show by default)
- Current tab is visually emphasized

### Modal Presentation

Sheet presentation for focused tasks:

```swift
struct ContentView: View {
    @State private var isPresenting = false

    var body: some View {
        Button("Add Item") {
            isPresenting = true
        }
        .sheet(isPresented: $isPresenting) {
            AddItemView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
```

**Presentation Detents:**
- `.medium` - Half screen (iPhone 15+), 40% (older)
- `.large` - Full screen
- `.fraction(0.7)` - Custom fraction
- `.height(400)` - Fixed height

### Toolbar Actions

Use toolbar for actions that relate to the current view:

```swift
struct DetailView: View {
    var body: some View {
        VStack {
            // Content
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: edit) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
    }
}
```

## Feedback Patterns

### Haptic Feedback

Provide tactile confirmation for important interactions:

```swift
// Impact feedback - physical impact
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Selection feedback - selection change
let selection = UISelectionFeedbackGenerator()
selection.selectionChanged()

// Notification feedback - success, warning, failure
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)  // or .warning, .error
```

**Impact Styles:**
- `.light` - Subtle feedback
- `.medium` - Standard tap
- `.heavy` - Dramatic feedback
- `.soft` - For softer, larger buttons
- `.rigid` - For mechanical buttons

### Visual Feedback

**Loading states:**
```swift
// Inline loading
struct LoadingRow: View {
    var body: some View {
        HStack {
            Text("Loading")
            ProgressView()
                .scaleEffect(0.8)
        }
    }
}

// Full-screen loading
struct LoadingView: View {
    var body: some View {
        ZStack {
            // Background content (dimmed)
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)
        }
    }
}
```

**Success/error feedback:**
```swift
struct SubmitButton: View {
    @State private var isSubmitting = false
    @State private var showError = false

    var body: some View {
        Button(action: submit) {
            if isSubmitting {
                ProgressView()
            } else {
                Text("Submit")
            }
        }
        .disabled(isSubmitting)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again")
        }
    }
}
```

### Progress Indicators

**Determinate progress:**
```swift
struct DownloadProgress: View {
    @State private var progress = 0.5

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.linear)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Indeterminate progress:**
```swift
// Circular progress
ProgressView()
    .progressViewStyle(.circular)
    .scaleEffect(1.5)

// Linear progress
ProgressView()
    .progressViewStyle(.linear)
```

## Accessibility Patterns

This project has explicitly opted out of accessibility requirements. However, for reference:

### Supporting Dynamic Type

All text should scale with user's font size preference:

```swift
Text("Content")
    .font(.body)  // Automatically supports Dynamic Type
```

### Minimum Touch Targets

All interactive elements must meet 44pt minimum:

```swift
Button(action: {}) {
    Image(systemName: "heart")
}
.frame(minWidth: 44, minHeight: 44)  // Ensures touch target
```

## Error Handling and Empty States

### Empty States

Provide guidance when content is unavailable:

```swift
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Items")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Items you add will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Add Item") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Error States

Clear error messaging with recovery actions:

```swift
struct ErrorStateView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                retry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
```

### Inline Validation

Provide immediate feedback for user input:

```swift
struct ValidatedTextField: View {
    @State private var text = ""
    @State private var isValid = true

    var body: some View {
        HStack {
            TextField("Email", text: $text)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .onChange(of: text) {
                    isValid = text.contains("@")
                }

            if !text.isEmpty {
                Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isValid ? .green : .red)
            }
        }
    }
}
```

## Best Practices Summary

1. **Use semantic spacing** - Apple's 8/12/16/20pt system
2. **Respect safe areas** - Keep content away from system UI
3. **Support Dynamic Type** - Use semantic font styles
4. **Use semantic colors** - Automatic light/dark mode support
5. **Provide feedback** - Haptic, visual, and progress indicators
6. **Handle empty states** - Guide users when content is unavailable
7. **Clear error messaging** - Explain what went wrong and how to fix it
