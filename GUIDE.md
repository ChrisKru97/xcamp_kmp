⏺ SwiftUI Development Guide for XcamP KMP

Here's a step-by-step guide to develop the native SwiftUI UI for your KMP project:

Phase 1: Setup and Basic Integration

Step 1: Configure Xcode Project

cd /Users/christiankrutsche/Documents/xcamp_kmp
open iosApp/iosApp.xcodeproj

Step 2: Update iOS Project Settings

1. In Xcode:
   - Select the project root → Target "iosApp"
   - General Tab:
    - Bundle Identifier: com.krutsche.xcamp
    - Deployment Target: iOS 14.0+
      - Build Settings:
        - Add $(SRCROOT)/../shared/build/bin/iosX64/debugFramework to Framework Search Paths
    - Add $(SRCROOT)/../shared/build/bin/iosArm64/debugFramework to Framework Search Paths

Step 3: Build Shared Framework

./gradlew :shared:linkDebugFrameworkIosX64
./gradlew :shared:linkDebugFrameworkIosArm64

Step 4: Add Shared Framework to iOS

1. In Xcode Navigator:
   - Right-click project → "Add Files to iosApp"
   - Navigate to shared/build/bin/iosX64/debugFramework/shared.framework
   - Add it to the project
   - In Build Phases → Link Binary With Libraries: Add shared.framework
   - In Build Phases → Embed Frameworks: Add shared.framework

Phase 2: Create SwiftUI Architecture

Step 5: Create SwiftUI App Structure

Create these SwiftUI files in Xcode:

1. App Entry Point (iosApp/iosApp/XcampApp.swift):
   import SwiftUI
   import shared

@main
struct XcampApp: App {
@StateObject private var appViewModel = AppViewModel()

      init() {
          // Initialize KMP app
          appViewModel.initializeApp()
      }

      var body: some Scene {
          WindowGroup {
              ContentView()
                  .environmentObject(appViewModel)
          }
      }
}

2. App ViewModel (iosApp/iosApp/ViewModels/AppViewModel.swift):
   import SwiftUI
   import shared
   import Combine

@MainActor
class AppViewModel: ObservableObject {
@Published var isInitialized = false
@Published var appState: AppState = .limited
@Published var availableTabs: [AppTab] = []

      private var xcampApp: XcampApp?

      func initializeApp() {
          // Initialize KMP dependencies
          let driverFactory = DatabaseDriverFactory()
          let databaseManager = DatabaseManager(driverFactory: driverFactory)

          // TODO: Initialize other services
          // This will be completed once KMP framework is properly linked
      }

      func refreshConfig() async {
          // TODO: Call xcampApp.refreshConfig()
      }
}

3. Main Content View (iosApp/iosApp/Views/ContentView.swift):
   import SwiftUI
   import shared

struct ContentView: View {
@EnvironmentObject var appViewModel: AppViewModel
@State private var selectedTab = 0

      var body: some View {
          TabView(selection: $selectedTab) {
              HomeView()
                  .tabItem {
                      Image(systemName: "house.fill")
                      Text("Domů")
                  }
                  .tag(0)

              if appViewModel.availableTabs.contains(.schedule) {
                  ScheduleView()
                      .tabItem {
                          Image(systemName: "calendar")
                          Text("Program")
                      }
                      .tag(1)
              }

              if appViewModel.availableTabs.contains(.speakers) {
                  SpeakersView()
                      .tabItem {
                          Image(systemName: "person.3.fill")
                          Text("Řečníci")
                      }
                      .tag(2)
              }

              if appViewModel.availableTabs.contains(.places) {
                  PlacesView()
                      .tabItem {
                          Image(systemName: "map.fill")
                          Text("Místa")
                      }
                      .tag(3)
              }

              MediaView()
                  .tabItem {
                      Image(systemName: "photo.fill")
                      Text("Média")
                  }
                  .tag(4)

              InfoView()
                  .tabItem {
                      Image(systemName: "info.circle.fill")
                      Text("Info")
                  }
                  .tag(5)
          }
      }
}

Phase 3: Create Individual Views

Step 6: Create View Structure

Create folders in Xcode:
- Views/
    - Home/
    - Schedule/
    - Speakers/
    - Places/
    - Media/
    - Info/
- ViewModels/
- Components/

Step 7: Implement Core Views

Home View (iosApp/iosApp/Views/Home/HomeView.swift):
import SwiftUI
import shared

struct HomeView: View {
@StateObject private var viewModel = HomeViewModel()

      var body: some View {
          NavigationView {
              ScrollView {
                  VStack(spacing: 20) {
                      // Countdown Widget
                      if viewModel.shouldShowCountdown {
                          CountdownView(targetDate: viewModel.eventStartDate)
                      }

                      // QR Code Button (if event is active)
                      if viewModel.shouldShowQRButton {
                          QRCodeButton()
                      }

                      // News Section
                      NewsSection(news: viewModel.news)

                      // Current/Upcoming Schedule
                      if viewModel.shouldShowSchedulePreview {
                          UpcomingScheduleSection(sections: viewModel.upcomingSections)
                      }
                  }
                  .padding()
              }
              .navigationTitle("XcamP")
              .refreshable {
                  await viewModel.refresh()
              }
          }
      }
}

@MainActor
class HomeViewModel: ObservableObject {
@Published var news: [NewsItem] = []
@Published var upcomingSections: [Section] = []
@Published var shouldShowCountdown = true
@Published var shouldShowQRButton = false
@Published var shouldShowSchedulePreview = true
@Published var eventStartDate = Date()

      func refresh() async {
          // TODO: Load data from KMP repositories
      }
}

Schedule View (iosApp/iosApp/Views/Schedule/ScheduleView.swift):
import SwiftUI
import shared

struct ScheduleView: View {
@StateObject private var viewModel = ScheduleViewModel()
@State private var selectedDay = 0

      var body: some View {
          NavigationView {
              VStack {
                  // Day Selector
                  ScrollView(.horizontal, showsIndicators: false) {
                      HStack(spacing: 12) {
                          ForEach(0..<8, id: \.self) { dayIndex in
                              DayTab(
                                  day: viewModel.dayNames[dayIndex],
                                  isSelected: selectedDay == dayIndex
                              )
                              .onTapGesture {
                                  selectedDay = dayIndex
                              }
                          }
                      }
                      .padding(.horizontal)
                  }

                  // Schedule List
                  List {
                      ForEach(viewModel.sectionsForDay(selectedDay), id: \.uid) { section in
                          SectionRowView(section: section)
                              .onTapGesture {
                                  // Navigate to section detail
                              }
                      }
                  }
                  .listStyle(PlainListStyle())
              }
              .navigationTitle("Program")
              .toolbar {
                  ToolbarItem(placement: .navigationBarTrailing) {
                      FilterButton()
                  }
              }
          }
      }
}

@MainActor
class ScheduleViewModel: ObservableObject {
@Published var sections: [Section] = []
@Published var currentFilter: SectionType? = nil

      let dayNames = ["Sobota", "Neděle", "Pondělí", "Úterý", "Středa", "Čtvrtek", "Pátek", "Sobota"]

      func sectionsForDay(_ dayIndex: Int) -> [Section] {
          // TODO: Filter sections by day and current filter
          return sections
      }

      func loadSections() async {
          // TODO: Load from KMP ScheduleRepository
      }
}

Phase 4: Create Reusable Components

Step 8: Build Component Library

Section Row Component (iosApp/iosApp/Components/SectionRowView.swift):
import SwiftUI
import shared

struct SectionRowView: View {
let section: Section
@State private var isFavorite: Bool

      init(section: Section) {
          self.section = section
          self._isFavorite = State(initialValue: section.favorite)
      }

      var body: some View {
          HStack {
              VStack(alignment: .leading, spacing: 4) {
                  HStack {
                      Text(timeFormatter.string(from: section.startTime))
                          .font(.caption)
                          .foregroundColor(.secondary)

                      Spacer()

                      SectionTypeBadge(type: section.type)
                  }

                  Text(section.name)
                      .font(.headline)
                      .lineLimit(2)

                  if let description = section.description {
                      Text(description)
                          .font(.body)
                          .foregroundColor(.secondary)
                          .lineLimit(3)
                  }

                  if let leader = section.leader {
                      Text("Vedoucí: \(leader)")
                          .font(.caption)
                          .foregroundColor(.secondary)
                  }
              }

              Spacer()

              FavoriteButton(isFavorite: $isFavorite) {
                  // TODO: Toggle favorite in KMP repository
              }
          }
          .padding(.vertical, 8)
      }

      private let timeFormatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.timeStyle = .short
          return formatter
      }()
}

Favorite Button (iosApp/iosApp/Components/FavoriteButton.swift):
import SwiftUI

struct FavoriteButton: View {
@Binding var isFavorite: Bool
let action: () -> Void

      var body: some View {
          Button(action: {
              withAnimation(.easeInOut(duration: 0.2)) {
                  isFavorite.toggle()
                  action()
              }
          }) {
              Image(systemName: isFavorite ? "star.fill" : "star")
                  .foregroundColor(isFavorite ? .yellow : .gray)
                  .font(.title3)
          }
      }
}

Phase 5: Integrate with KMP

Step 9: Connect SwiftUI to KMP Business Logic

Update HomeViewModel to use KMP:
@MainActor
class HomeViewModel: ObservableObject {
@Published var news: [NewsItem] = []
private let newsRepository: NewsRepository
private let scheduleRepository: ScheduleRepository

      init() {
          // TODO: Get repositories from KMP dependency injection
          // This will be completed once framework integration is working
      }

      func refresh() async {
          do {
              // Load news from KMP repository
              // let newsResult = try await newsRepository.getAllNews()
              // self.news = newsResult
          } catch {
              print("Error loading news: \(error)")
          }
      }
}

Phase 6: Testing and Refinement

Step 10: Test Framework Integration

1. Build the shared framework:
   ./gradlew :shared:linkDebugFrameworkIosX64
2. Test in iOS Simulator:
   - Build and run the iOS app in Xcode
   - Verify that KMP classes are accessible
   - Test basic functionality

Step 11: Implement Remaining Views

Following the same pattern, create:
- SpeakersView and SpeakersViewModel
- PlacesView and PlacesViewModel
- MediaView and MediaViewModel
- InfoView and InfoViewModel
- SongsView and SongsViewModel (for songbook)

Phase 7: Advanced Features

Step 12: Add Advanced Features

- QR Code Scanner: Using CodeScanner SwiftUI library
- Photo Upload: Using PhotosPicker SwiftUI component
- Maps Integration: Using MapKit for places
- Search: Real-time search for songs
- Navigation: Between detail views

Next Steps

1. Start with Step 1-4 to set up the basic project structure
2. Test framework integration by accessing simple KMP classes
3. Implement HomeView first as it's the simplest
4. Add one view at a time following the pattern above
5. Integrate KMP repositories gradually as you build each view

The key is to build incrementally - start with the UI structure using mock data, then gradually integrate with your KMP business logic layer.

Would you like me to help you with any specific step or create more detailed implementations for particular views?