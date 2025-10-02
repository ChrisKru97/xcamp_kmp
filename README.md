# XcamP Kotlin Multiplatform

A complete Kotlin Multiplatform implementation of the XcamP app with shared business logic and native UI capabilities.

## Project Structure

```
xcamp_kmp/
├── shared/                          # Shared business logic
│   ├── src/
│   │   ├── commonMain/kotlin/       # Common Kotlin code
│   │   │   ├── cz/krutsche/xcamp/shared/
│   │   │   │   ├── data/            # Data layer
│   │   │   │   │   ├── config/      # App configuration
│   │   │   │   │   ├── firebase/    # Firebase services
│   │   │   │   │   ├── local/       # Local storage & database
│   │   │   │   │   └── repository/  # Data repositories
│   │   │   │   ├── domain/model/    # Data models
│   │   │   │   └── db/              # Database driver
│   │   │   └── sqldelight/          # SQLDelight database schema
│   │   ├── androidMain/kotlin/      # Android-specific code
│   │   └── iosMain/kotlin/          # iOS-specific code
│   └── build.gradle.kts             # Shared module build config
├── composeApp/                      # Android app module
│   ├── src/androidMain/kotlin/      # Android UI code
│   ├── google-services.json         # Firebase Android config
│   └── build.gradle.kts             # Android app build config
├── iosApp/                          # iOS app module
│   └── iosApp.xcodeproj/            # Xcode project
├── gradle/                          # Gradle configuration
│   ├── libs.versions.toml           # Version catalog with latest dependencies
│   └── wrapper/
└── build.gradle.kts                 # Root project build config
```

## Key Features Implemented

### 🔥 Firebase Integration
- **Authentication**: Anonymous authentication with Firebase Auth
- **Firestore**: Complete database operations with timeout protection
- **Storage**: File upload/download with Firebase Storage
- **Remote Config**: Feature flags for dynamic app behavior
- **Analytics**: Event tracking and user analytics
- **Crashlytics**: Error reporting and crash analytics

### 💾 Database Layer
- **SQLDelight**: Type-safe SQL database with async operations
- **Models**: Complete data models for all entities:
  - Section (Schedule events with favorites, filtering)
  - Speaker (Speaker profiles with images)
  - Song (Songbook with search functionality)
  - Place (Locations with GPS coordinates)
  - News (Event announcements)
  - GroupLeader (Camp group leaders)
  - Rating (Post-event feedback system)

### 📱 App State Management
- **Dynamic Navigation**: Tab configuration based on event state
  - Limited Mode: Home → Media → Info
  - Active Event: Home → Schedule → Speakers → Places → Media → Info
  - Post-Event: Home → Schedule → Rating → Media → Info
- **Feature Flags**: Remote-controlled app behavior

### 🛠 Architecture Patterns
- **Repository Pattern**: Clean separation of data sources
- **Offline-First**: Local database with Firebase sync
- **Error Handling**: Comprehensive error handling with graceful degradation
- **Timeout Protection**: All network operations with 5-second timeouts

## Bundle IDs
- **Android**: `cz.krutsche.xcamp`
- **iOS**: `com.krutsche.xcamp`

## Dependencies (Latest Versions)
- **Kotlin**: 2.0.21
- **Gradle**: 8.10
- **SQLDelight**: 2.0.2
- **Firebase KMP SDK**: 2.3.0 (GitLive)
- **Coroutines**: 1.9.0
- **Serialization**: 1.7.3
- **DateTime**: 0.6.1
- **Multiplatform Settings**: 1.2.0
- **Koin**: 4.0.1

## Core Functionality Matches Flutter App

✅ **Complete Feature Parity**:
- 8-day schedule system with favorites and filtering
- Speaker profiles with Firebase Storage images
- Real-time song search with Czech language support
- GPS-enabled places with map integration
- QR code scanning and display with local persistence
- Multi-photo upload system to Firebase Storage
- Post-event rating system with multiple categories
- Firebase Remote Config with dynamic feature flags
- Anonymous authentication and user management
- Comprehensive analytics and crash reporting

## Ready for Native UI Implementation

The project provides a complete shared business logic foundation that can be consumed by:
- **Android**: Jetpack Compose UI
- **iOS**: SwiftUI

All data operations, Firebase integration, state management, and business logic are handled in the shared module, allowing for rapid native UI development.

## Getting Started

1. **Clone and Build**:
   ```bash
   cd xcamp_kmp
   ./gradlew build
   ```

2. **Android Development**:
   ```bash
   ./gradlew :composeApp:installDebug
   ```

3. **iOS Development**:
   Open `iosApp/iosApp.xcodeproj` in Xcode

The project is structured to follow DRY, KISS, and SOLID principles with small, focused files and clean architecture patterns exactly matching the original Flutter app functionality.