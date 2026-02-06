# XcamP App - Hidden Features & Advanced Usage Guide

## Overview
This document covers advanced features, hidden behaviors, and non-obvious functionality within the XcamP app that aren't immediately apparent to users but significantly enhance the user experience.

## 🎯 Smart Navigation & Performance Features

### Dynamic Navigation System
- **Adaptive Tab Order**: Bottom navigation dynamically changes based on event state and remote config
  - Pre-Event: Home → Media → Info (3 tabs)
  - Active Event: Home → Schedule → Speakers & Places → Media → Info (5 tabs)
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

## 🔐 QR Code System - Advanced Features

### Multi-Mode QR Scanner
- **Camera Permission**: Graceful handling - shows instructions if permission denied
- **Brightness Auto-Adjust**: Screen brightness automatically increases when displaying QR codes
- **Dual Purpose**: 
  - **Scan Mode**: Scan and save your personal QR code from registration
  - **Display Mode**: Show your personal QR code to others
- **Data Persistence**: QR data stored locally with platform-specific key-value storage
- **Reset Functionality**: Hidden admin pin (configurable via Firebase Remote Config) can reset stored QR data

### Modern Dark Design System
- **Consistent Spacing**: 4px base unit system (xs: 4px, sm: 8px, md: 16px, lg: 24px, xl: 32px, 2xl: 48px, 3xl: 64px)
- **Smart Typography**: Font size hierarchy with proper Czech language support
- **Interactive States**: All buttons and cards have hover/pressed animations
- **Accessibility**: WCAG AA compliant color contrasts throughout

## 📊 Smart Data Management

### Offline-First Architecture
- **SQLDelight Local Database**: Full app functionality without internet connection
- **Background Sync**: Automatic synchronization with Firestore when connection available
- **Graceful Degradation**: App continues working even if sync operations fail
- **Smart Caching**: Images cached locally for offline viewing
- **Cleanup Service**: Automatic cleanup without app restart
- **Data Integrity**: Robust error handling prevents data corruption during failed operations

### Automatic Cache Clearing on Event State Transitions
- **Post → Pre Event Detection**: App detects when Remote Config `showAppData` transitions from post-event back to pre-event state
- **Full Database Reset**: SQLDelight database completely cleared (all tables dropped/recreated)
- **Image Cache Purge**: All cached images removed from local storage
- **Storage Optimization**: Reduces app storage footprint significantly between events
- **Transparent to User**: Happens automatically in background without user interaction
- **One-Way Transition**: Only triggers when going from post-event → pre-event (not during normal pre→active→post progression)

### Smart Sync Triggers: Data synchronization triggered only on specific tab navigation events
  - Speakers tab → Sync speaker data
  - Places tab → Sync places data
  - Songs navigation → Sync songs data
- **Timeout Protection**: All database operations protected with 5-second timeouts

## 🔍 Advanced Search & Filtering

### Schedule Smart Filtering
- **Type-Based Filtering**: Filter events by type (main, internal, gospel, food)
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
- **Context-Aware Colors**: Links styled with theme-appropriate colors
- **Touch Feedback**: Haptic feedback on link interactions

## 📱 Platform Enhancements

### Platform Optimizations
- **Screen Brightness Control**: QR code display automatically adjusts brightness
- **Haptic Feedback**: Subtle haptic responses for interactions
- **Safe Area Handling**: Proper layout for all screen types including notched displays

### Performance Monitoring
- **Firebase Crashlytics**: Automatic crash reporting and error tracking
- **Analytics Integration**: User behavior tracking for app improvement
- **ANR Prevention**: Startup optimizations prevent Application Not Responding errors
- **Memory Management**: Automatic cleanup of unused resources

## 🎯 User Experience Enhancements

### Countdown Widget
- **Smart Visibility**: Automatically hides after event has passed
- **Czech Localization**: Proper Czech grammar for time units (den/dny/dní)
- **Real-time Updates**: Updates every second with smooth animations
- **Timezone Handling**: Proper handling of timezone changes and daylight saving

### Favorites & Filter System
- **Filter FAB**: Floating action button on Schedule tab for quick access to filters
- **Type Filtering**: Filter by section type (main, internal, gospel, food)
- **Favorites Filter**: Toggle to show only favorited events
- **Persistent State**: Filter state preserved across navigation via Environment values
- **Visual Feedback**: Amber star with scale animation and haptic feedback when toggling favorites

### Loading States & Error Handling
- **Skeleton Loading**: Content-aware skeleton screens during data loading
- **Progressive Loading**: Show cached data immediately, update with fresh data
- **Error Boundaries**: Isolated error handling prevents full app crashes
- **Retry Mechanisms**: User-friendly retry options for failed operations

### Advanced Error Handling
- **Intelligent Crashlytics**: Distinguishes between fatal errors and handled image loading errors
- **Non-Fatal Image Errors**: Image loading failures logged as non-fatal for debugging without user impact
- **Startup ANR Prevention**: Comprehensive timeout and lazy loading prevents Application Not Responding errors
- **Firebase Initialization Resilience**: App continues working even if Firebase initialization fails

## 📋 Power User Tips

### Navigation Shortcuts
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

## 🔄 Version Update Enforcement System

### Forced Update Mechanism
- **Remote Config Control**: App version requirements controlled via Firebase Remote Config
- **Platform-Specific Version Checking**: Compares current version against Google Play/App Store minimum version
- **Non-Bypassable Update**: App becomes completely unusable until updated to required version
- **Smart Update Messaging**: Clear communication about required update and reasons
- **Startup Version Check**: Version validation occurs immediately after app initialization
- **Blocking UI**: Full-screen modal prevents app usage when update required
- **Deep Link Integration**: Direct links to app store for seamless update process
- **Emergency Update Capability**: Instant forced update for critical security issues

This comprehensive guide reveals the sophisticated architecture and user experience optimizations built into the XcamP app that work seamlessly behind the scenes to provide a premium mobile experience with dynamic feature management and performance optimization.
