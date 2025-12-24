# Android Development Subagent

Specialized guidance for Android Jetpack Compose development in the XcamP KMP project.

## Trigger Keywords
Compose, Android, Gradle, Material, Jetpack

## Platform Requirements
- **Minimum**: API 24 (Android 7.0 Nougat)
- **Language**: Kotlin 2.2.20
- **Bundle ID**: `cz.krutsche.xcamp`
- **UI Framework**: Jetpack Compose

## Build Commands

```bash
# Install debug build to device
./gradlew :composeApp:installDebug

# Build all modules
./gradlew build

# Clean build
./gradlew clean
```

## Compose Development Guidelines

### Component Organization
- **Reusable Components**: Extract common UI patterns into `@Composable` functions
- **Single Responsibility**: Each composable should have one clear purpose
- **Preview Support**: Use `@Preview` annotation for UI components

### Material Design
- Use Material 3 components (`androidx.compose.material3`)
- Leverage built-in components: `Button`, `Card`, `LazyRow`, `LazyColumn`
- Follow Material Design guidelines for spacing and typography

### State Management
- **Remember**: Use `remember` for local UI state
- **ViewModel**: Access shared logic via ViewModels that call Kotlin shared services
- **State Hoisting**: Lift state to the lowest common ancestor

### Navigation
- Use `androidx.navigation.compose` for navigation
- Define navigation graph in composables
- Pass view models and repositories through navigation

## File Organization
```
composeApp/
├── src/main/java/cz/krutsche/xcamp/
│   ├── ui/              # Compose UI components
│   ├── viewmodel/       # Android-specific ViewModels
│   └── MainActivity.kt  # Entry point
```

## Compatibility Notes
- Ensure all libraries support API 24+
- Use proper availability checks when using newer APIs

## Common Patterns

### Loading State
```kotlin
when (val state = viewModel.state) {
    is Loading -> CircularProgressIndicator()
    is Success -> Content(state.data)
    is Error -> ErrorMessage(state.message)
}
```

### List Items
```kotlin
LazyColumn {
    items(items) { item ->
        ItemCard(
            item = item,
            onClick = { viewModel.onItemClick(item) }
        )
    }
}
```

## Theming
- Use `MaterialTheme` for consistent styling
- Define colors, typography, shapes in `ui/theme/`
- Support dark mode via `isSystemInDarkTheme()`
