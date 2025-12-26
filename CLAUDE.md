# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working with this repository.

## Project Overview

XcamP is a Kotlin Multiplatform camp/event management app targeting Android (Jetpack Compose) and iOS (SwiftUI) with shared business logic.

**Essential Documentation** (source of truth):
- `APP_FEATURES.md` - Feature specs, navigation, app state
- `FIREBASE_STRUCTURE.md` - Firestore collections, Storage structure
- `HIDDEN_FEATURES.md` - Advanced features and optimizations

## Essential Commands

```bash
# Build all
./gradlew build

# Android
./gradlew :composeApp:installDebug

# iOS
open iosApp/iosApp.xcodeproj

# Clean + Generate SQLDelight
./gradlew clean generateCommonMainXcampDatabaseInterface
```

## Architecture

**Shared Module** (`shared/src/`):
- `commonMain/kotlin/` - Shared business logic
- `androidMain/kotlin/` - Android-specific implementations
- `iosMain/kotlin/` - iOS-specific implementations

**Key Directories**:
- `data/config/` - AppConfigService (Remote Config, app state)
- `data/firebase/` - Firebase services (Auth, Firestore, Storage, Analytics, Crashlytics)
- `data/local/` - DatabaseManager, SQLite operations
- `data/repository/` - Repository pattern for each entity
- `domain/model/` - Section, Speaker, Song, Place, News, GroupLeader, Rating

**Database**: SQLDelight (`XcampDatabase.sq`) with async coroutine support, `INSERT OR REPLACE` pattern.

**Platform Modules**: `composeApp/` (Android), `iosApp/` (iOS)

## Bundle Identifiers & Platform Requirements

| Platform | Bundle ID | Minimum |
|----------|-----------|---------|
| Android | `cz.krutsche.xcamp` | API 24 (Android 7.0) |
| iOS | `com.krutsche.xcamp` | iOS 14.1 |

Use latest KMP-compatible APIs. For platform-specific guidance, see:
- iOS: `.claude/subagents/ios-dev.md`
- Android: `.claude/subagents/android-dev.md`

## Key Dependencies

- Firebase GitLive SDK 2.3.0
- SQLDelight 2.1.0
- Koin 4.0.1
- Kotlin 2.2.20 + Coroutines 1.10.2
- Ktor 3.0.2

## App State & Navigation

Dynamic bottom tabs controlled by Remote Config `showAppData`:

| Mode | Tabs |
|------|------|
| Limited (`showAppData=false`) | Home → Media → Info |
| Active Event | Home → Schedule → Speakers → Places → Media → Info |
| Post-Event | Home → Schedule → Rating → Media → Info |

**Remote Config**: `showAppData` (feature flag), `startDate` (event start, default '2026-07-18')

## Firebase Overview

**Project**: `xcamp-dea26`

- Auth: Anonymous on app start
- Firestore: 5-second timeout protection
- Storage: Photo uploads, speaker/place images
- Remote Config: Feature flags, app state
- Analytics & Crashlytics: Monitoring

**Collections**:
- Persistent: `chrost`, `feedback`, `info`, `places`, `rating`, `songs`, `speakers`, `textRating`, `users`, `notifications`, `merch`
- Event-specific (deleted post-event): `schedule`, `groupLeaders`, `news`

For Firebase implementation details, see `.claude/subagents/firebase-integration.md`

## Key Features

- **Schedule**: 8-day event, favorites, auto-navigation to current day, type filtering
- **QR Code**: Scan at registration + display for others, brightness auto-adjust
- **Songbook**: Real-time search, Czech diacritics, numbered songs
- **Media**: Photo upload to Firebase Storage with progress tracking

## Development Notes

- Offline-first: Local SQLite + Firebase sync
- Repository pattern with `Result<T>` error handling
- 5-second timeouts on all network operations
- Use latest KMP-compatible framework versions
- For shared module patterns, see `.claude/subagents/shared-logic.md`

## Development Agents

Specialized Claude Code plugin agents for parallel platform work. These agents can be spawned via the Task tool for autonomous, focused work.

### Available Agents

| Agent | Purpose | Trigger |
|-------|---------|---------|
| `ios-developer` | SwiftUI views, previews, components | iOS/Swift UI work |
| `android-developer` | Compose, Material, Gradle | Android UI work |
| `firebase-specialist` | Firestore, Storage, Remote Config | Database/cloud ops |
| `shared-logic-dev` | Repositories, SQLDelight, Koin | Kotlin shared module |
| `strings-manager` | Strings.kt, localization | UI text management |
| `ui-reviewer` | KISS/DRY code review | Quality review |

### Parallel Work Examples

Launch multiple agents simultaneously for maximum efficiency:
- `ios-developer` + `android-developer` for cross-platform UI implementation
- `shared-logic-dev` + `firebase-specialist` for backend features
- Any implementation agent + `ui-reviewer` for implementation with quality review

### When to Use Agents vs Documentation

**Spawn an agent when:**
- Creating new files or significant modifications
- Need autonomous multi-step work
- Complex platform-specific implementation
- Code review or refactoring tasks

**Read documentation directly when:**
- Quick reference lookup
- Understanding patterns before starting
- Verifying conventions mid-task

### Documentation References

For quick context (without spawning agents):
- `.claude/subagents/ios-dev.md`
- `.claude/subagents/android-dev.md`
- `.claude/subagents/firebase-integration.md`
- `.claude/subagents/shared-logic.md`
- `.claude/subagents/strings-management.md`
- `.claude/subagents/ui-review.md`
