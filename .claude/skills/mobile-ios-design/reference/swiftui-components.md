# SwiftUI Components Reference

This reference covers common SwiftUI components and their usage patterns.

## Lists and Collections

### Basic List

```swift
struct BasicListView: View {
    let items = ["Item 1", "Item 2", "Item 3"]

    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}
```

### Sectioned List

```swift
struct SectionedListView: View {
    struct Section: Identifiable {
        let id = UUID()
        let title: String
        let items: [String]
    }

    let sections = [
        Section(title: "A", items: ["Apple", "Apricot"]),
        Section(title: "B", items: ["Banana", "Blueberry"])
    ]

    var body: some View {
        List(sections) { section in
            Section(header: Text(section.title)) {
                ForEach(section.items, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}
```

### Searchable List

```swift
struct SearchableView: View {
    @State private var searchText = ""
    let items = ["Apple", "Banana", "Cherry", "Date", "Elderberry"]

    var filteredItems: [String] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List(filteredItems, id: \.self) { item in
            Text(item)
        }
        .searchable(text: $searchText, prompt: "Search items")
    }
}
```

### LazyVStack/LazyHStack

```swift
struct LazyStackView: View {
    let items = Array(1...100)

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    ItemRow(item: item)
                }
            }
            .padding()
        }
    }
}
```

### LazyVGrid

```swift
struct GridView: View {
    let items = Array(1...20)

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(items, id: \.self) { item in
                    ItemCard(item: item)
                }
            }
            .padding()
        }
    }
}
```

## Forms and Input

### Settings Form

```swift
struct SettingsForm: View {
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    @State private var username = ""

    var body: some View {
        Form {
            Section("User") {
                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
            }

            Section("Preferences") {
                Toggle("Notifications", isOn: $notificationsEnabled)
                Toggle("Dark Mode", isOn: $darkMode)
            }
        }
        .navigationTitle("Settings")
    }
}
```

### Validated Text Field

```swift
struct ValidatedTextField: View {
    @State private var email = ""
    @State private var isValidEmail = true

    var body: some View {
        HStack {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .onChange(of: email) {
                    isValidEmail = email.contains("@") && email.contains(".")
                }

            if !email.isEmpty {
                Image(systemName: isValidEmail ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(isValidEmail ? .green : .red)
            }
        }
    }
}
```

### Secure Text Field

```swift
struct PasswordField: View {
    @State private var password = ""
    @State private var isSecure = true

    var body: some View {
        HStack {
            Group {
                if isSecure {
                    SecureField("Password", text: $password)
                } else {
                    TextField("Password", text: $password)
                }
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
```

## Buttons and Actions

### Button Styles

```swift
struct ButtonStylesView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Filled button (primary)
            Button("Primary") {}
                .buttonStyle(.borderedProminent)

            // Bordered button (secondary)
            Button("Secondary") {}
                .buttonStyle(.bordered)

            // Plain button (minimal)
            Button("Plain") {}
                .buttonStyle(.plain)

            // Destructive button
            Button("Delete", role: .destructive) {}
                .buttonStyle(.borderedProminent)

            // Custom button
            Button("Custom") {}
                .buttonStyle(.bordered)
                .tint(.purple)
        }
    }
}
```

### Menu

```swift
struct MenuView: View {
    var body: some View {
        Menu {
            Button(action: share) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Button(action: duplicate) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            Divider()
            Button(action: delete, role: .destructive) {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}
```

### Context Menu

```swift
struct ContextMenuView: View {
    var body: some View {
        Text("Long press me")
            .contextMenu {
                Button(action: copy) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                Button(action: share) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
    }
}
```

### IconButton

```swift
struct IconButton: View {
    var body: some View {
        Button(action: favorite) {
            Image(systemName: "heart")
                .symbolEffect(.bounce, value: isFavorited)
                .foregroundStyle(isFavorited ? .red : .primary)
        }
        .buttonStyle(.borderless)
    }
}
```

## Sheets and Modals

### Sheet Presentation

```swift
struct SheetPresentation: View {
    @State private var isPresenting = false

    var body: some View {
        Button("Present Sheet") {
            isPresenting = true
        }
        .sheet(isPresented: $isPresenting) {
            SheetContent()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}
```

### Full Screen Cover

```swift
struct FullScreenCoverView: View {
    @State private var isPresenting = false

    var body: some View {
        Button("Full Screen") {
            isPresenting = true
        }
        .fullScreenCover(isPresented: $isPresenting) {
            FullScreenContent()
        }
    }
}
```

### Confirmation Dialog

```swift
struct ConfirmationDialogView: View {
    @State private var isShowingDialog = false

    var body: some View {
        Button("Delete") {
            isShowingDialog = true
        }
        .confirmationDialog(
            "Are you sure?",
            isPresented: $isShowingDialog,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                // Perform deletion
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
```

### Alert

```swift
struct AlertView: View {
    @State private var isShowingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Button("Show Alert") {
            alertMessage = "Something happened!"
            isShowingAlert = true
        }
        .alert("Notification", isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}
```

## Loading and Progress Indicators

### Inline Progress

```swift
struct InlineProgress: View {
    @State private var isLoading = false

    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            }
            Text(isLoading ? "Loading..." : "Content")
        }
    }
}
```

### Full-Screen Loading

```swift
struct FullScreenLoading: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            // Progress indicator
            ProgressView()
                .scaleEffect(1.5)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(12)
        }
    }
}
```

### Progress Bar

```swift
struct ProgressBarView: View {
    @State private var progress: Double = 0.5

    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(.linear)
                .tint(.blue)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

## Async Content Loading

### AsyncImage

```swift
struct AsyncImageView: View {
    let imageURL = URL(string: "https://example.com/image.jpg")

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 100, height: 100)
        .cornerRadius(12)
    }
}
```

### Task-Based Loading

```swift
struct TaskLoadingView: View {
    @State private var items: [Item] = []
    @State private var isLoading = false

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .task {
            await loadItems()
        }
    }

    func loadItems() async {
        isLoading = true
        defer { isLoading = false }

        // Simulate async loading
        try? await Task.sleep(for: .seconds(1))
        items = await fetchItems()
    }

    func fetchItems() async -> [Item] {
        // Fetch from API
        return []
    }
}
```

### Refreshable

```swift
struct RefreshableView: View {
    @State private var items: [Item] = []

    var body: some View {
        List(items) { item in
            Text(item.name)
        }
        .refreshable {
            await refreshItems()
        }
    }

    func refreshItems() async {
        // Pull to refresh logic
    }
}
```

## Animations

### Implicit Animation

```swift
struct ImplicitAnimation: View {
    @State private var isScaled = false

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(isScaled ? 1.5 : 1.0)
            .animation(.bouncy, value: isScaled)
            .onTapGesture {
                isScaled.toggle()
            }
    }
}
```

### Explicit Animation

```swift
struct ExplicitAnimation: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .offset(x: offset)
            .onTapGesture {
                withAnimation(.bouncy) {
                    offset = offset == 0 ? 100 : 0
                }
            }
    }
}
```

### Transition Animation

```swift
struct TransitionAnimation: View {
    @State private var isShowing = false

    var body: some View {
        VStack {
            if isShowing {
                Text("Hello")
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            Button("Toggle") {
                withAnimation(.bouncy) {
                    isShowing.toggle()
                }
            }
        }
    }
}
```

### Phase Animator (iOS 18+)

```swift
struct PhaseAnimatorView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .phaseAnimator([false, true]) { content, phase in
                content
                    .scaleEffect(phase ? 1.2 : 1.0)
                    .rotationEffect(.degrees(phase ? 180 : 0))
            } animation: { _ in
                .bouncy(duration: 0.6)
            }
    }
}
```

## Gestures

### Tap Gesture

```swift
struct TapGestureView: View {
    @State private var tapCount = 0

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .onTapGesture(count: 2) {
                tapCount += 1
            }
    }
}
```

### Drag Gesture

```swift
struct DragGestureView: View {
    @State private var offset: CGSize = .zero

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(.bouncy) {
                            offset = .zero
                        }
                    }
            )
    }
}
```

### Magnification Gesture

```swift
struct MagnificationGestureView: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .scaleEffect(scale)
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = value.magnification
                    }
                    .onEnded { _ in
                        withAnimation(.bouncy) {
                            scale = 1.0
                        }
                    }
            )
    }
}
```

### Simultaneous Gestures

```swift
struct SimultaneousGesturesView: View {
    @State private var offset: CGSize = .zero
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(.blue)
            .frame(width: 100, height: 100)
            .offset(offset)
            .scaleEffect(scale)
            .gesture(
                SimultaneousGesture(
                    DragGesture()
                        .onChanged { offset = $0.translation },
                    MagnifyGesture()
                        .onChanged { scale = $0.magnification }
                )
            )
    }
}
```

### Sequenced Gestures

```swift
struct SequencedGesturesView: View {
    @State private var longPressActive = false

    var body: some View {
        Circle()
            .fill(longPressActive ? .red : .blue)
            .frame(width: 100, height: 100)
            .gesture(
                LongPressGesture(minimumDuration: 1)
                    .onEnded { _ in
                        longPressActive = true
                    }
                    .sequenced(before: DragGesture())
                    .onChanged { value in
                        // Handle drag after long press
                    }
            )
    }
}
```

## Common Patterns

### Empty State

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

            Text("Items will appear here")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
```

### Loading State

```swift
struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)

            Text("Loading...")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
```

### Error State

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

## Best Practices

1. **Use Lazy containers** for large lists and grids
2. **Compose views** from smaller, reusable components
3. **Support keyboard types** for appropriate text fields
4. **Provide loading feedback** for async operations
5. **Use semantic animations** that match user expectations
6. **Test gesture interactions** on different device sizes
7. **Handle edge cases** (empty states, errors, loading)
