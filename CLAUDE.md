# CLAUDE.md

Guidance for Claude Code (claude.ai/code) working with this repository.

## Project Overview

XcamP is a Kotlin Multiplatform camp/event management app targeting Android (Jetpack Compose) and iOS (SwiftUI) with shared business logic.

**Essential Documentation** (source of truth):
- `APP_FEATURES.md` - Feature specs, navigation, app state
- `FIREBASE_STRUCTURE.md` - Firestore collections, Storage structure
- `HIDDEN_FEATURES.md` - Advanced features and optimizations
- `PLACES.md` - Firestore place name → ID mapping
- `SPEAKERS.md` - Firestore speaker name → ID mapping

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
- `domain/model/` - Section, Speaker, Song, Place, News, Rating

**Database**: SQLDelight (`XcampDatabase.sq`) with async coroutine support, `INSERT OR REPLACE` pattern.

**Platform Modules**: `composeApp/` (Android), `iosApp/` (iOS)

## Bundle Identifiers & Platform Requirements

| Platform | Bundle ID | Minimum |
|----------|-----------|---------|
| Android | `cz.krutsche.xcamp` | API 24 (Android 7.0) |
| iOS | `com.krutsche.xcamp` | iOS 15 |

Use latest KMP-compatible APIs. For platform-specific guidance, see:
- iOS: `.claude/subagents/ios-dev.md`
- Android: `.claude/subagents/android-dev.md`

## Key Dependencies

- Firebase GitLive SDK 2.4.0 (Auth, Firestore, Storage, Remote Config)
- Firebase Crashlytics (platform-native, manual versioning)
  - Android: firebase-crashlytics 19.5.1
  - iOS: FirebaseCrashlytics (native SDK)
- SQLDelight 2.2.1
- Kotlin 2.3.10 + Coroutines 1.10.2

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

- Auth: Anonymous on app start (via Firebase GitLive SDK)
- Firestore: 5-second timeout protection (via Firebase GitLive SDK)
- Storage: Photo uploads, speaker/place images (via Firebase GitLive SDK)
- Remote Config: Feature flags, app state (via Firebase GitLive SDK)
- Crashlytics: Platform-native SDKs with expect/actual bridge
  - Android: Firebase Crashlytics SDK
  - iOS: FirebaseCrashlytics (native, wrapped in Kotlin)
  - Shared: `CrashlyticsService` expect/actual interface for cross-platform error reporting

**Collections**:
- Persistent: `chrost`, `feedback`, `info`, `places`, `rating`, `songs`, `speakers`, `textRating`, `users`, `notifications`, `merch`
- Event-specific (deleted post-event): `schedule`, `news`

> **See also:** [`PLACES.md`](PLACES.md) for Firestore place ID mapping, [`SPEAKERS.md`](SPEAKERS.md) for Firestore speaker ID mapping

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

## MCP Tools

### XcodeBuild MCP (iOS)

For iOS development, the XcodeBuild MCP server provides comprehensive simulator and build automation:

**Session Setup** (required before most operations):
```
session-set-defaults({
  "projectPath": "/Users/christiankrutsche/Documents/xcamp_kmp/iosApp/iosApp.xcodeproj",
  "scheme": "iosApp",
  "simulatorId": "<UUID>",
  "useLatestOS": true
})
```

**Available Simulators** (discover with `list_sims`):
- iPhone 16e (iOS 18.6): `210C8C91-3D13-4AC9-8922-6EED3EBB15B1`
- iPhone Air (iOS 26.2): `CE3EE1DB-76CF-4F2B-A9D8-699FA2B0CEE2`
- iPhone SE (3rd gen) (iOS 15.5): `17E4EB1E-2D9F-4983-BA42-172F77C769C9`

**Common Commands**:
| Tool | Purpose |
|------|---------|
| `list_sims` | List all available simulators |
| `boot_sim` | Boot a simulator |
| `build_run_sim` | Build and run app on simulator |
| `screenshot` | Capture screenshot of simulator |
| `describe_ui` | Get UI element hierarchy with coordinates |
| `tap` / `swipe` / `gesture` | Interact with UI elements |
| `launch_app_logs_sim` | Launch app and capture logs |
| `stop_app_sim` | Stop running app |

**Alternative CLI Commands** (without MCP):
```bash
# Boot simulator
xcrun simctl boot "<UUID>"

# Open Simulator
open -a Simulator

# Build and run
xcodebuild -project iosApp/iosApp.xcodeproj -scheme iosApp -sdk iphonesimulator \
  -destination 'id=<UUID>' build
```

## Tool Usage Preference

**Web Content & Search**:
- NEVER use the built-in `webReader`, `webSearchPrime` or `webfetch` tools
- ALWAYS use the Playwright MCP (`mcp__playwright__*`) for fetching or reading web content
- ALWAYS use the Web Search MCP (`mcp__web-search__*`) for searching the internet
- If a tool returns a 429 error, do not retry with the same tool; switch immediately to the alternative MCP tools mentioned above

### Web & Browser MCP Tools

For web searching and fetching:
- `web-search` - Search the web using DuckDuckGo
- `playwright` - Browser automation for scraping and testing and fetching web pages

## Development Agents

Specialized Claude Code plugin agents for parallel platform work. These agents can be spawned via the Task tool for autonomous, focused work.

### Available Agents

| Agent | Purpose | Trigger |
|-------|---------|---------|
| `ios-component-generator` | SwiftUI component creation with duplicate detection | Creating new iOS views/components |
| `android-component-generator` | Compose component creation with duplicate detection | Creating new Android composables |
| `ios-developer` | SwiftUI views, previews, components | iOS/Swift UI work |
| `android-developer` | Compose, Material, Gradle | Android UI work |
| `firebase-specialist` | Firestore, Storage, Remote Config | Database/cloud ops |
| `shared-logic-dev` | Repositories, SQLDelight, ServiceFactory | Kotlin shared module |
| `strings-manager` | Strings.kt, localization | UI text management |
| `ui-reviewer` | KISS/DRY code review | UI quality review |
| `code-reviewer` | Code quality, anti-patterns, architecture | Comprehensive code review |

### Parallel Work Examples

Launch multiple agents simultaneously for maximum efficiency:
- `ios-developer` + `android-developer` for cross-platform UI implementation
- `shared-logic-dev` + `firebase-specialist` for backend features
- Any implementation agent + `ui-reviewer` for implementation with UI quality review
- Any implementation agent + `code-reviewer` for comprehensive code quality review

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
- `.claude/subagents/component-generator-ios.md` - iOS SwiftUI component creation guide
- `.claude/subagents/component-generator-android.md` - Android Compose component creation guide
- `.claude/subagents/ios-dev.md`
- `.claude/subagents/android-dev.md`
- `.claude/subagents/firebase-integration.md`
- `.claude/subagents/shared-logic.md`
- `.claude/subagents/strings-management.md`
- `.claude/subagents/ui-review.md`
- `.claude/subagents/code-review.md`

## Skills

Project-specific skills for specialized tasks:

- `/kotlin-multiplatform` - Platform abstraction decision-making for XcamP KMP. Guides when to share vs keep platform-specific, source set placement (commonMain, androidMain, iosMain), expect/actual patterns, and KMP architecture decisions
- `/kmp-sqldelight` - SQLDelight database patterns for KMP. Use when working with database schemas, queries, migrations, or local data persistence
- `/sqldelight` - Work with SQLDelight database schemas, queries, and migrations
- `/mobile-developer` - Kotlin Multiplatform, SwiftUI, and Jetpack Compose development with modern architecture patterns, offline sync, and app store optimization
- `/mobile-design` - Cross-platform mobile design thinking for iOS and Android. Touch interaction, performance patterns, platform conventions, anti-patterns. Use when building Kotlin Multiplatform, SwiftUI, or Jetpack Compose apps
- `/mobile-ios-design` - iOS Human Interface Guidelines and SwiftUI patterns for native iOS apps
- `/mobile-android-design` - Master Material Design 3 and Jetpack Compose patterns for building native Android apps. Use when designing Android interfaces, implementing Compose UI, or following Google's Material Design guidelines.

## Post-Development Workflow (REQUIRED)

**NEVER assume a feature is complete without these steps!**

### 1. Code Review
- Spawn `code-reviewer` agent for comprehensive code quality review
- Spawn `ui-reviewer` agent for KISS/DRY UI component review
- Address all violations before proceeding
- Ensure proper component separation and naming

### 2. Build & Launch
- iOS: Use MCP `build_run_sim` to build and launch in simulator
- Android: `./gradlew :composeApp:installDebug` (when Android MCP available)

### 3. Visual & Functional Testing (iOS)
Use MCP tools to verify the feature works:
- `screenshot` - Capture current visual state
- `describe_ui` - Verify UI element hierarchy
- `tap`, `swipe`, `gesture` - Test all interactions
- `launch_app_logs_sim` - Monitor for runtime errors

### 4. Clean Code Checklist
- [ ] No hardcoded strings (use Strings.kt)
- [ ] No duplicate code patterns
- [ ] SwiftUI previews added for new views
- [ ] Proper error handling implemented
- [ ] **No unnecessary comments** - Code should be self-documenting; only comment "why" not "what", or complex/non-obvious logic

## Code Quality Standards

**Comments Policy**: Minimize comments in code. Prefer self-documenting code with clear names and structure. Only add comments when:
- Explaining **why** something is done (not **what** is done)
- Documenting complex algorithms or non-obvious logic
- Notes about workarounds or technical debt
- Standard `// MARK:` comments for code organization

### Android Development Blocker
**IMPORTANT:** If asked to do Android-specific UI work, STOP and require the user to add Android MCP tools first before proceeding!

## Accessibility Policy

**IMPORTANT**: This app does NOT require accessibility features. Do NOT add or maintain:
- Accessibility labels, hints, or identifiers
- Accessibility traits or elements
- Accessibility testing or auditing
- Any accessibility-related SwiftUI modifiers

When reviewing or generating code, ignore accessibility concerns entirely.
