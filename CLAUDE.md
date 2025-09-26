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
- Dev override system for Remote Config during development
- **Always reference APP_FEATURES.md, FIREBASE_STRUCTURE.md, and HIDDEN_FEATURES.md for implementation details**