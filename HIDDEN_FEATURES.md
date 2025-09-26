# XcamP App - Hidden Features & Advanced Usage Guide

## Overview
This document covers advanced features, hidden behaviors, and non-obvious functionality within the XcamP app that aren't immediately apparent to users but significantly enhance the user experience.

## 🎯 Smart Navigation & Performance Features

### Dynamic Navigation System
- **Adaptive Tab Order**: Bottom navigation dynamically changes based on event state and remote config
  - Pre-Event: Home → Media → Info (3 tabs)
  - Active Event: Home → Schedule → Speakers → Places → Media → Info (6 tabs)
  - Post-Event: Home → Schedule → Rating → Media → Info (5 tabs)
- **Context-Aware State Management**: Tab availability controlled by `showAppData` remote config flag

### Automatic Day Navigation
- **Schedule Tab**: App automatically navigates to current day when opened during camp dates
- **Context-Aware Timing**: Uses `startDate` remote config to calculate which day to show
- **Smart Date Logic**: Automatically determines if event is over (1 week after start date)
- **8-Day Schedule**: Supports full week-long camp structure (Sobota to Sobota)

### Advanced Animation System
- **Performance-Optimized Transitions**: Different animation types based on device performance
- **Route-Specific Animations**: 
  - Main route: No animation for instant loading
  - Image routes: Fade transition for smooth viewing
  - Other routes: Slide + fade combination with adaptive curves
- **Low-End Device Detection**: Automatically disables complex animations on slower devices
- **Adaptive Duration**: Animation timing adjusts based on device capabilities
- **Smooth Transitions**: All tab switches include optimized fade and slide animations

### Adaptive Performance System
- **Sophisticated Device Detection**: App uses advanced 4-tier performance classification via PerformanceDetector (High/Medium/Low/Minimal)
- **Platform-Specific Analysis**: 
  - **iOS**: Model-based detection (iPhone 15/14/13/12 = High, iPhone 11/X = Medium, iPhone 8/7 = Low, iPhone 6s = Minimal)
  - **Android**: Memory-based detection (8GB+ = High, 6GB = High, 4GB = Medium, 3GB = Low, <3GB = Minimal)
- **Granular Animation Adaptation**: Each performance tier gets optimized animation durations and curves
  - **High Tier**: Full animations (300ms durations, complex curves like easeInOutQuart, elasticOut)
  - **Medium Tier**: Moderate animations (250ms durations, easeInOutCubic curves)
  - **Low Tier**: Simplified animations (200ms durations, basic easeInOut curves)
  - **Minimal Tier**: Ultra-light animations (150ms durations, linear curves only)
- **Complete Animation Disabling**: Lowest-tier devices skip animations entirely to maintain 60fps
- **Selective Haptic Feedback**: Haptic feedback disabled on low/minimal performance devices
- **Motor Framework Integration**: High-performance devices use advanced spring physics animations
- **Analytics Integration**: Device performance metrics tracked via Firebase Analytics for optimization insights
- **Memory Optimization**: Lazy loading of providers prevents startup ANR (Application Not Responding)
- **Timeout Protection**: 10-second initialization timeout prevents indefinite app hanging
- **Background Sync**: All data syncing happens asynchronously without blocking UI
- **Provider Performance**: All providers use `lazy: true` to prevent expensive startup operations

## 🔐 QR Code System - Advanced Features

### Multi-Mode QR Scanner
- **Camera Permission**: Graceful handling - shows instructions if permission denied
- **Brightness Auto-Adjust**: Screen brightness automatically increases when displaying QR codes
- **Dual Purpose**: 
  - **Scan Mode**: Scan and save your personal QR code from registration
  - **Display Mode**: Show your personal QR code to others
- **Data Persistence**: QR data stored locally with SharedPreferences
- **Reset Functionality**: Hidden admin pin (configurable via Firebase Remote Config) can reset stored QR data

### Group Management Integration
- **Automatic Redirection**: After successful QR scan, app can auto-navigate to Group Leaders screen
- **Group Number Storage**: Stores both QR data and extracted group number separately
- **Offline Operation**: QR functionality works completely offline once data is stored

## 🎨 Dynamic Theming & Design System

### Firebase Remote Config Color System
- **Live Theme Updates**: Colors can be changed remotely without app updates
- **Backward Compatibility**: Legacy color system still supported alongside Modern Dark Design System
- **Gradient Backgrounds**: Dynamic gradients using primary/secondary background colors
- **Context-Aware Colors**: Different content types (main, internal, gospel, food, basic (- deprecated, same as main)) have distinct color schemes

### Modern Dark Design System
- **Consistent Spacing**: 4px base unit system (xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, 2xl: 48px, 3xl: 64px)
- **Smart Typography**: Font size hierarchy with proper Czech language support
- **Interactive States**: All buttons and cards have hover/pressed animations
- **Accessibility**: WCAG AA compliant color contrasts throughout

## 📊 Smart Data Management

### Offline-First Architecture
- **ObjectBox Local Database**: Full app functionality without internet connection
- **Background Sync**: Automatic synchronization with Firestore when connection available
- **Graceful Degradation**: App continues working even if sync operations fail
- **Smart Caching**: Images cached locally with `cached_network_image`
- **Cleanup Service**: Automatic cleanup without app restart
- **Data Integrity**: Robust error handling prevents data corruption during failed operations

### Real-time Updates  
- **Firebase Listeners**: Live data updates from Firestore without user action TODO don't do live data!, only fetch when needed
- **Provider Pattern**: Efficient state management minimizes unnecessary rebuilds
- **Selective Updates**: Only affected UI components rebuild when data changes
- **Error Recovery**: Automatic retry logic for failed operations
- **Smart Sync Triggers**: Data synchronization triggered only on specific tab navigation events
  - Speakers tab → Sync speaker data
  - Places tab → Sync places data
  - Songs navigation → Sync songs data
- **Timeout Protection**: All database operations protected with 5-second timeouts

## 🔍 Advanced Search & Filtering

### Songs Search System
- **Real-time Search**: Search filters as you type with no delay
- **Multi-field Search**: Searches across song titles, lyrics and number
- **Czech Language Support**: Proper handling of Czech diacritics and special characters

### Schedule Smart Filtering
- **Type-Based Filtering**: Filter events by type (main, internal, gospel, food, basic (- deprecated, same as main))
- **Favorite System**: Quick access to starred events across all days
- **Time-Aware Display**: Past events automatically dimmed 
- **Category Colors**: Visual coding by event type

## 🎵 Media & Content Features

### Image Upload System
- **Multi-Image Selection**: Select and upload multiple photos simultaneously
- **Firebase Storage Integration**: Secure cloud storage with user-based folders
- **Progress Tracking**: Real-time upload progress indicators
- **Error Handling**: Graceful failure handling with retry options
- **Tab Organization**: Separate tabs for uploading new images and viewing your uploaded photos

### Rich Text Processing
- **Link Detection**: Automatic conversion of `[text](url)` markdown-style links
- **External URL Handling**: Smart handling of external links with `url_launcher`
- **Context-Aware Colors**: Links styled with theme-appropriate colors
- **Touch Feedback**: Haptic feedback on link interactions

### Interactive Preview System (iOS-Style)
- **Long-Press Gesture**: Hold any compatible list item to reveal content preview modal
- **Smooth Animations**: Bounce-in scale animation with fade effects using custom curves
- **Action Buttons**: Context-aware action buttons with proper localization ("Otevřít", "Zobrazit řečníka", etc.)
- **Preview Content**: Rich preview displays include icons, titles, descriptions, and formatted content
- **Haptic Feedback**: Medium haptic pulse when preview appears for tactile confirmation
- **Smart Positioning**: Modal automatically positions to avoid screen edges and overlapping content
- **Dismissal**: Can be dismissed by dragging, tapping outside, or using action buttons
- **Component Integration**: Seamlessly integrated with existing ListItem components via optional properties

## 📱 Platform-Specific Enhancements

### iOS Optimizations TODO those should be android optimizations as well
- **Screen Brightness Control**: QR code display automatically adjusts brightness
- **Haptic Feedback**: Subtle haptic responses for interactions
- **Safe Area Handling**: Proper layout for all iPhone screen types including notched displays
- **iOS-Style Previews**: Long-press gesture support for content previews with animated modal dialogs, action buttons, and smooth transitions (similar to iOS Safari and Messages apps)

### Performance Monitoring
- **Firebase Crashlytics**: Automatic crash reporting and error tracking
- **Analytics Integration**: User behavior tracking for app improvement
- **ANR Prevention**: Startup optimizations prevent Application Not Responding errors
- **Memory Management**: Automatic cleanup of unused resources

## 🔄 Background Services & Sync TODO no background services!

### Schedule Sync Service
- **Intelligent Sync**: Only syncs when data has actually changed
- **Conflict Resolution**: Handles conflicts between local and remote data
- **Bandwidth Optimization**: Minimal data transfer using efficient queries
- **Retry Logic**: Automatic retry on network failures with exponential backoff

### Cleanup Service
- **Automatic Cleanup**: Removes outdated data automatically
- **Storage Optimization**: Prevents local database from growing too large
- **Cache Management**: Intelligent image cache cleanup
- **Memory Monitoring**: Prevents memory leaks from unused providers

## 🎯 User Experience Enhancements

### Countdown Widget
- **Smart Visibility**: Automatically hides after event has passed
- **Czech Localization**: Proper Czech grammar for time units (den/dny/dní)
- **Real-time Updates**: Updates every second with smooth animations
- **Timezone Handling**: Proper handling of timezone changes and daylight saving

### Favorite System
- **Persistent Storage**: Favorites saved locally and survive app restarts
- **Visual Feedback**: Amber star with scale animation and haptic feedback
- **Cross-Screen Access**: Favorites accessible from multiple screens
- **Sync Integration**: Favorites can be synced across devices (if user authentication enabled) TODO remove this synchronization and notification system via this

### Loading States & Error Handling
- **Skeleton Loading**: Content-aware skeleton screens during data loading
- **Progressive Loading**: Show cached data immediately, update with fresh data
- **Error Boundaries**: Isolated error handling prevents full app crashes
- **Retry Mechanisms**: User-friendly retry options for failed operations

## 🔧 Developer & Debug Features

### Secret Developer Mode Activation
- **Hidden Production Access**: Secret gesture sequence allows dev mode activation in production builds
- **Security Implementation**: Time-limited (24-hour expiration) and rate-limited (3 attempts max with 30-second cooldown) TODO unnecessary
- **Gesture Sequence**: Long press (3 seconds) + triple tap (within 2 seconds) on version text in Info screen
- **Visual Feedback**: Version text changes to "Dev Mode Aktivován" on success, "Zkuste později" on cooldown TODO unnecessary, badge is enough
- **Secret Mode Indicator**: Shows "SECRET" badge with warning orange color instead of "DEV"  TODO unnecessary, DEV is enough
- **Production Warning**: DevSettings shows warning banner when secret mode is active in production builds
- **Automatic Expiration**: Secret mode automatically expires after 24 hours for security

### Advanced Error Handling
- **Intelligent Crashlytics**: Distinguishes between fatal errors and handled image loading errors
- **Non-Fatal Image Errors**: Image loading failures logged as non-fatal for debugging without user impact
- **Startup ANR Prevention**: Comprehensive timeout and lazy loading prevents Application Not Responding errors
- **Firebase Initialization Resilience**: App continues working even if Firebase initialization fails

### Hot Reload Support
- **State Preservation**: Hot reload preserves navigation state and user data
- **Provider Persistence**: State management survives hot reloads
- **Asset Updates**: Images and assets update without full restart
- **Anonymous User Management**: Automatic Firebase anonymous authentication

### Remote Configuration
- **Feature Flags**: Enable/disable features without app updates
  - showAppData: Controls main event features availability
- **Dynamic Event Configuration**: 
  - startDate: Configurable event start date (default: '2026-07-18')
  - Automatic event state detection
- **Emergency Controls**: Remote kill switches for problematic features TODO remove this
- **Content Updates**: Update text content and messaging remotely

## 📋 Power User Tips

### Navigation Shortcuts
- **Double-tap Home**: Quick return to current day in schedule (implementation dependent) TODO what is that
- **Swipe Gestures**: Context-sensitive swipe actions where available

### Data Management
- **Pull to Refresh**: Most screens support pull-to-refresh for manual sync
- **Storage Usage**: App efficiently manages local storage to prevent bloat
- **Cache Clearing**: Temporary data automatically cleared to maintain performance

### Accessibility Features
- **Screen Reader Support**: Full VoiceOver/TalkBack compatibility
- **High Contrast**: Respects system accessibility settings
- **Font Size Scaling**: Supports system font size adjustments
- **Touch Target Sizing**: All interactive elements meet accessibility guidelines

## 🚀 Performance Features

### Battery Optimization
- **Background Sync Control**: Intelligent background processing TODO remove this
- **CPU Usage Monitoring**: Prevents excessive CPU usage during animations
- **Network Efficiency**: Minimal network usage with smart caching
- **GPU Optimization**: Efficient rendering for smooth animations

### Memory Management
- **Image Optimization**: Automatic image compression and sizing
- **Provider Cleanup**: Automatic disposal of unused state providers
- **Cache Limits**: Intelligent cache size management
- **Memory Leak Prevention**: Proper disposal of controllers and listeners

## 🎮 Advanced User Interaction Features

### Smart QR Code Header Integration
- **Context-Sensitive Display**: QR scanner button only appears on Home tab when showAppData = true
- **Visual Feedback**: Custom button design with accent color and rounded corners
- **Analytics Integration**: QR scanner usage tracked via Firebase Analytics
- **Haptic Response**: Tactile feedback when accessing QR functionality

### Floating Action Button Intelligence
- **Context-Aware Display**: Schedule filter FAB only visible on Schedule tab
- **Custom Styling**: Matches app design system with transparent background
- **Modal Integration**: Triggers bottom sheet with drag handle for intuitive interaction
- **Performance Optimized**: Uses AnimatedScaleContainer for smooth interactions

### Tab Management System
- **State Validation**: Ensures selected tab is valid for current app state
- **Automatic Fallback**: Falls back to Home tab if current tab becomes invalid
- **Animation Coordination**: Smooth reverse → forward animation sequence on tab changes
- **Provider Sync Integration**: Automatically triggers data sync when switching to relevant tabs

This comprehensive guide reveals the sophisticated architecture and user experience optimizations built into the XcamP app that work seamlessly behind the scenes to provide a premium mobile experience with dynamic feature management and performance optimization.
