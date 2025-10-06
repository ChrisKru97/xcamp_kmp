# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

XcamP is a Kotlin Multiplatform project for a comprehensive camp/event management app. The project targets Android (Jetpack Compose) and iOS (SwiftUI) with complete shared business logic for all data operations, Firebase integration, and state management.

## Essential Documentation (Source of Truth)

**These files contain the definitive specification for app behavior and features:**
- **`APP_FEATURES.md`** - Complete feature specifications, navigation system, and app state management
- **`FIREBASE_STRUCTURE.md`** - Firestore collections, Firebase Storage organization, and data relationships
- **`HIDDEN_FEATURES.md`** - Advanced features, performance optimizations, and developer features

**When implementing features, always reference these documents first as they represent the authoritative requirements.**

## Essential Commands

### Build and Development
```bash
# Build all modules
./gradlew build

# Android development
./gradlew :composeApp:installDebug

# iOS development - open in Xcode
open iosApp/iosApp.xcodeproj

# Clean build
./gradlew clean

# Generate SQLDelight code
./gradlew generateCommonMainXcampDatabaseInterface
```

### Testing
```bash
# Run all tests
./gradlew test

# Run shared module tests only
./gradlew :shared:test
```

## Architecture

### Shared Module Structure
- **`shared/src/commonMain/kotlin/`** - Shared business logic for all platforms
- **`shared/src/androidMain/kotlin/`** - Android-specific implementations (database drivers, etc.)
- **`shared/src/iosMain/kotlin/`** - iOS-specific implementations

### Key Architecture Components

#### Data Layer (`cz.krutsche.xcamp.shared.data/`)
- **`config/`** - AppConfigService for Remote Config and app state management
- **`firebase/`** - Complete Firebase services (Auth, Firestore, Storage, Analytics, Crashlytics)
- **`local/`** - DatabaseManager and local SQLite operations
- **`repository/`** - Repository pattern implementations for each entity type

#### Domain Models (`cz.krutsche.xcamp.shared.domain.model/`)
- Section (Schedule events with favorites and filtering)
- Speaker, Song, Place, News, GroupLeader, Rating entities

#### Database (SQLDelight)
- Schema: `shared/src/commonMain/sqldelight/cz/krutsche/xcamp/shared/db/XcampDatabase.sq`
- Generated code: Type-safe database operations with async coroutine support
- All operations use `INSERT OR REPLACE` pattern for data synchronization

#### App Initialization
- Entry point: `XcampApp.kt` - handles Firebase initialization, anonymous auth, Remote Config
- State management based on event phases (Limited Mode → Active Event → Post-Event)
- Dynamic tab navigation controlled by Remote Config

### Platform-Specific Modules
- **`composeApp/`** - Android Jetpack Compose application
- **`iosApp/`** - iOS SwiftUI application (Xcode project)

### Key Dependencies
- **Firebase GitLive SDK 2.3.0** - Multiplatform Firebase services
- **SQLDelight 2.1.0** - Type-safe SQL with async coroutine extensions
- **Koin 4.0.1** - Dependency injection
- **Kotlin 2.2.20** with Coroutines 1.10.2
- **Ktor 3.0.2** - Network client
- **Kotlinx Serialization & DateTime** - JSON and date handling

## Bundle Identifiers
- Android: `cz.krutsche.xcamp`
- iOS: `com.krutsche.xcamp`

## Platform Minimum Requirements
- **Android**: Minimum SDK 24 (Android 7.0 Nougat)
- **iOS**: Deployment target 14.1 (iOS 14.1+)
- **Kotlin**: 2.2.20
- **Swift**: 5.0

### Platform Compatibility Notes
- Always use APIs compatible with the minimum targets above
- For iOS: Ensure all libraries and APIs support iOS 14.1+
- For Android: Ensure all libraries and APIs support Android 7.0+
- When newer APIs are required, use proper availability checks and fallback implementations

## App State Management & Navigation

### Dynamic Navigation System (Reference: APP_FEATURES.md)
The app uses a **dynamic bottom tab system** controlled by Remote Config:

**Limited Mode** (`showAppData = false`): Home → Media → Info (3 tabs)
**Active Event** (`showAppData = true`, during event): Home → Schedule → Speakers → Places → Media → Info (6 tabs)
**Post-Event** (`showAppData = true`, after event): Home → Schedule → Rating → Media → Info (5 tabs)

### Key App States
- **Pre-Event**: Countdown, news, media links, contact info
- **Active Event**: Complete schedule (8-day Sobota-Sobota), speakers, places, QR functionality
- **Post-Event**: Rating system, media access, schedule review

### Remote Config Controls
- **`showAppData`**: Primary feature flag controlling event functionality
- **`startDate`**: Event start date (default: '2026-07-18')
- **Event Over Logic**: Automatically determined as 1 week after start date

## Firebase Configuration (Reference: FIREBASE_STRUCTURE.md)

### Firebase Project: `xcamp-dea26`
- **Authentication**: Anonymous auth on app start
- **Firestore**: Complete camp data with 5-second timeout protection
- **Storage**: User photo uploads, speaker/place images
- **Remote Config**: Feature flags and app state management
- **Analytics & Crashlytics**: User behavior and error monitoring

### Data Collections
**Persistent Collections**: `chrost`, `feedback`, `info`, `places`, `rating`, `songs`, `speakers`, `textRating`, `users`, `notifications`, `merch`
**Event-Specific Collections** (deleted post-event): `schedule`, `groupLeaders`, `news`

## Key Features & Systems

### Schedule System (8-Day Event)
- **Event Types**: Main, Internal, Gospel, Food, Basic (deprecated → Main)
- **Favorites System**: Star/unstar events across all days
- **Auto-Navigation**: Current day during event dates
- **Time-Aware Display**: Past events dimmed/hidden
- **Smart Filtering**: Filter by event type via floating action button

### QR Code System (Reference: HIDDEN_FEATURES.md)
- **Dual Purpose**: Scan personal QR at registration + display for others
- **Brightness Auto-Adjust**: Screen brightness increases when displaying
- **Local Persistence**: QR data stored via SharedPreferences
- **Admin Reset**: Hidden pin (Remote Config) can reset QR data
- **Group Integration**: Auto-navigation to Group Leaders after scan

### Songbook System
- **Real-time Search**: Multi-field search (titles, lyrics, numbers)
- **Czech Language Support**: Proper diacritics handling
- **Numbered Songs**: Complete camp songbook with traditional numbering

### Media & Upload System
- **Photo Upload**: Multi-photo Firebase Storage upload
- **Progress Tracking**: Real-time upload indicators
- **User Organization**: Separate tabs for upload/view your photos
- **Chrost Integration**: Upload photos for camp newsletter

### Performance Optimization (Reference: HIDDEN_FEATURES.md)
- **Device-Adaptive Performance**: 4-tier performance classification
- **Animation System**: Performance-based animation complexity
- **Offline-First**: Complete functionality without network
- **5-Second Timeouts**: All network operations protected
- **Memory Management**: Lazy loading, automatic cleanup

## Database Schema Notes
- All timestamps stored as INTEGER (Unix timestamp)
- JSON arrays stored as TEXT for complex fields (speakers, repeatedDates)
- Favorites system for Section entities
- Search functionality on Song name/text with LIKE queries
- Priority-based ordering for Places and Speakers

## Development Notes
- All network operations include 5-second timeouts
- Offline-first architecture with local SQLite + Firebase sync
- Repository pattern with Result<T> return types for error handling
- Comprehensive logging via Crashlytics for debugging
- **Always reference APP_FEATURES.md, FIREBASE_STRUCTURE.md, and HIDDEN_FEATURES.md for implementation details**

## Critical Development Requirements
- **ALWAYS use the latest KMP-compatible versions** of all frameworks and dependencies
- **NEVER use deprecated APIs** - always migrate to current API patterns when encountered
- When compilation fails, systematically fix all issues until build succeeds completely
- Use simplest approach and research latest API documentation when needed
- Ensure full compatibility across Android and iOS targets

## Development Principles

**ALWAYS follow these core principles when coding:**

### KISS (Keep It Simple, Stupid)
- Write simple, readable code that's easy to understand
- Avoid over-engineering and complex solutions
- Use clear, descriptive names for variables, functions, and classes
- Break complex functions into smaller, focused functions
- Prefer explicit code over clever tricks

### DRY (Don't Repeat Yourself)
- Extract common functionality into shared utilities or base classes
- Use inheritance and composition to eliminate code duplication
- Create reusable components for common UI patterns
- Centralize configuration and constants
- Example: Use BaseRepository for common repository patterns

### SOLID Principles
- **S**ingle Responsibility: Each class should have one reason to change
- **O**pen/Closed: Open for extension, closed for modification
- **L**iskov Substitution: Subtypes must be substitutable for base types
- **I**nterface Segregation: Many specific interfaces over one general interface
- **D**ependency Inversion: Depend on abstractions, not concretions

### Code Quality Standards
- Use Result<T> pattern for error handling instead of exceptions
- All network operations must include timeout protection (5-second default)
- Use suspend functions for async operations with proper coroutine context
- Apply functional programming patterns where appropriate (map, filter, fold)
- Write self-documenting code that doesn't require extensive comments
- Use extension functions to enhance existing APIs rather than utility classes

### iOS SwiftUI Development Guidelines

#### View Splitting Principles
**Always split complex views into smaller, focused components:**
- **Single Responsibility Views**: Each view component should have one clear purpose
- **Reusable Components**: Extract common UI patterns into separate view files
- **Component Size**: Keep individual view files under 50 lines when possible
- **Clear Naming**: Use descriptive names that indicate the component's purpose

#### No Logic in Swift Files
**CRITICAL: All business logic must be in Kotlin shared code, not Swift files:**
- **Swift files should only contain UI code**: Views, layouts, styling, animations
- **Business logic in Kotlin**: All data processing, calculations, state management, and decision logic must be implemented in the shared Kotlin module
- **Shared services**: Use Kotlin classes for RemoteConfig, AppState calculations, link generation, data formatting
- **Swift as UI layer only**: Swift components should only call Kotlin methods and display the results
- **No conditional logic**: Avoid if/else statements, switch cases, and data transformations in Swift - move these to Kotlin
- **Pure functions**: Kotlin logic should be pure functions that return data for Swift to display

#### iOS Design Principles
- **Native iOS Aesthetics**: Prefer standard iOS design patterns over custom styling
- **System Colors**: Use system colors and semantic colors where appropriate
- **Standard Controls**: Leverage built-in iOS controls (NavigationLink, Button, List, etc.)
- **Minimal Custom Styling**: Avoid excessive gradients, shadows, and custom effects
- **Asset Integration**: Use colors and images from Assets.xcassets for consistency
