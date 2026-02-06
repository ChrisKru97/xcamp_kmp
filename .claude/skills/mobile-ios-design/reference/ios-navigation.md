# iOS Navigation Patterns Reference

This reference covers navigation patterns for iOS apps using SwiftUI's modern navigation APIs.

## NavigationStack (iOS 16+)

NavigationStack is the modern, type-safe replacement for NavigationView.

### Basic NavigationStack

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

### Path-Based Navigation

Programmatically control the navigation path:

```swift
struct RootView: View {
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            ListView(items: items)
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .list:
                        ListView(items: items)
                    case .detail(let item):
                        DetailView(item: item)
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .onAppear {
            // Deep link example
            path = [.list, .detail(items.first!)]
        }
    }
}

enum Screen: Hashable {
    case list
    case detail(Item)
    case settings
}
```

### Multiple Destination Types

```swift
NavigationStack(path: $path) {
    List {
        Section("Items") {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
        }

        Section("Settings") {
            NavigationLink(value: Screen.settings) {
                Label("Settings", systemImage: "gear")
            }
        }
    }
    .navigationDestination(for: Item.self) { item in
        ItemDetailView(item: item)
    }
    .navigationDestination(for: Screen.self) { screen in
        switch screen {
        case .settings:
            SettingsView()
        default:
            EmptyView()
        }
    }
}
```

## NavigationSplitView (iOS 16+)

NavigationSplitView provides sidebar and column navigation for iPad and larger devices.

### Two-Column Layout

```swift
struct TwoColumnView: View {
    @State private var selectedItem: Item?

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(items, selection: $selectedItem) { item in
                NavigationLink(value: item) {
                    ItemRow(item: item)
                }
            }
            .navigationTitle("Items")
        } detail: {
            // Detail
            if let selectedItem {
                ItemDetailView(item: selectedItem)
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

### Three-Column Layout

```swift
struct ThreeColumnView: View {
    @State private var selectedCategory: Category?
    @State private var selectedItem: Item?

    var body: some View {
        NavigationSplitView {
            // Sidebar - Categories
            List(categories, selection: $selectedCategory) { category in
                NavigationLink(value: category) {
                    CategoryRow(category: category)
                }
            }
            .navigationTitle("Categories")
        } content: {
            // Content - Items in selected category
            if let selectedCategory {
                List(items(for: selectedCategory), selection: $selectedItem) { item in
                    NavigationLink(value: item) {
                        ItemRow(item: item)
                    }
                }
                .navigationTitle(selectedCategory.name)
            } else {
                Text("Select a category")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            // Detail - Selected item details
            if let selectedItem {
                ItemDetailView(item: selectedItem)
            } else {
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

### Column Visibility Control

```swift
struct SplitViewWithControls: View {
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar
        } detail: {
            // Detail
        }
    }
}
```

## Sheet Presentation

Sheets are used for modal presentation of focused tasks.

### Basic Sheet

```swift
struct ContentView: View {
    @State private var isPresenting = false

    var body: some View {
        Button("Present Sheet") {
            isPresenting = true
        }
        .sheet(isPresented: $isPresenting) {
            SheetContent()
        }
    }
}
```

### Sheet with Item

```swift
struct ContentView: View {
    @State private var selectedItem: Item?

    var body: some View {
        List(items) { item in
            Button(item.name) {
                selectedItem = item
            }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailSheet(item: item)
        }
    }
}
```

### Presentation Detents

```swift
.sheet(isPresented: $isPresenting) {
    SheetContent()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}
```

**Available detents:**
- `.medium` - Half screen
- `.large` - Full screen
- `.fraction(0.7)` - Custom fraction of screen height
- `.height(400)` - Fixed height in points
- `.compact` - Minimal height (bottom sheet style)

### Presentation Background

```swift
.sheet(isPresented: $isPresenting) {
    SheetContent()
        .presentationBackground(
            .ultraThinMaterial
        )
}
```

### Custom Sheet Interactions

```swift
.sheet(isPresented: $isPresenting) {
    SheetContent()
        .interactiveDismissDisabled {
            // Condition to prevent dismiss
            hasUnsavedChanges
        }
        .presentationContentInteraction(
            .dragIndicatesOnly  // Or .automatic, .disabled
        )
}
```

## Tab Navigation

TabView provides bottom tab navigation for top-level app sections.

### Basic TabView

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

### Tab Bar Appearance

```swift
TabView {
    // Tab content
}
.tint(.blue)  // Active tab color
.onAppear {
    // Custom appearance (use UITabBarAppearance for more control)
}
```

### Programmatic Tab Switching

```swift
struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab views...
        }
        .onChange(of: someTrigger) { _, _ in
            selectedTab = .search  // Switch to search tab
        }
    }
}
```

## Toolbar Actions

Toolbar provides action buttons that relate to the current view.

### Toolbar Items

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

### Multiple Toolbar Items

```swift
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) {
        Button(action: dismiss) {
            Label("Back", systemImage: "chevron.left")
        }
    }

    ToolbarItem(placement: .principal) {
        Text("Custom Title")
    }

    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            Button(action: share) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Button(action: delete) {
                Label("Delete", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
```

### Toolbar Placement Options

- `.navigationBarLeading` - Left side of navigation bar
- `.principal` - Center of navigation bar
- `.navigationBarTrailing` - Right side of navigation bar
- `.bottomBar` - Bottom toolbar area
- `.primaryAction` - Prominent position (varies by context)

## Deep Linking

Handle deep links and Universal Links to navigate to specific content.

### URL-Based Navigation

```swift
struct DeepLinkHandler: View {
    @State private var path: [Screen] = []

    var body: some View {
        NavigationStack(path: $path) {
            // App content
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return
        }

        switch host {
        case "item":
            if let idString = components.queryItems?.first(where: { $0.name == "id" })?.value,
               let id = UUID(idString) {
                path = [.list, .detail(Item(id: id))]
            }
        default:
            break
        }
    }
}
```

### Universal Links

Universal links are standard URLs that open your app when tapped:

1. **Configure Associated Domains** in Xcode (Signing & Capabilities)
2. **Upload apple-app-site-association file** to your web server
3. **Handle incoming links** in your app:

```swift
.onOpenURL { url in
    // Handle universal link
    handleDeepLink(url)
}
```

### Custom URL Schemes

```swift
// In Info.plist, define:
// URL Schemes: xcamp

// Handle in app:
.onOpenURL { url in
    if url.scheme == "xcamp" {
        // Parse path: xcamp://item/123
        handleCustomScheme(url)
    }
}
```

## Navigation Coordinator Pattern

For complex navigation flows, use a coordinator pattern:

```swift
@Observable
class NavigationCoordinator {
    var path: [Screen] = []
    var presentedSheet: Sheet?
    var tabBarSelection: Tab = .home

    func push(_ screen: Screen) {
        path.append(screen)
    }

    func pop() {
        _ = path.popLast()
    }

    func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }

    func switchTab(to tab: Tab) {
        tabBarSelection = tab
    }
}

enum Screen: Hashable {
    case list
    case detail(Item)
    case settings
}

enum Sheet: Identifiable {
    case add
    case edit(Item)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit: return "edit"
        }
    }
}
```

Usage:

```swift
@State private var coordinator = NavigationCoordinator()

var body: some View {
    TabView(selection: $coordinator.tabBarSelection) {
        NavigationStack(path: $coordinator.path) {
            // Content
                .navigationDestination(for: Screen.self) { screen in
                    // Destination views
                }
        }
        .tabItem { /* ... */ }
    }
    .sheet(item: $coordinator.presentedSheet) { sheet in
        // Sheet content
    }
}
```

## Navigation Transitions (iOS 18+)

Custom navigation transitions for unique navigation experiences.

```swift
.navigationTransition(.slide.combined(with: .opacity))
```

Available transitions:
- `.automatic` - Default platform transition
- `.slide` - Slide from side
- `.opacity` - Fade in/out
- `.zoom` - Scale transition
- Combined using `.combined(with:)`

## Best Practices

1. **Use NavigationStack** for new iOS 16+ code
2. **Keep navigation paths simple** - Avoid deeply nested navigation
3. **Provide clear back navigation** - Users should always know how to go back
4. **Handle state restoration** - Save navigation state for app relaunch
5. **Use sheets for focused tasks** - Modal presentation should be self-contained
6. **Support deep links** - Allow direct access to any screen
7. **Test on different screen sizes** - iPad navigation differs from iPhone
