# Android Component Generator Subagent

Expert guidance for creating new Jetpack Compose components in the XcamP KMP project following strict architecture patterns.

## Trigger Keywords
create android component, compose composable, new android component, android view, make composable, add component, create compose component

## Platform Requirements
- **Minimum**: API 24 (Android 7.0 Nougat)
- **Language**: Kotlin 2.2.20
- **Bundle ID**: `cz.krutsche.xcamp`
- **UI Framework**: Jetpack Compose with Material 3
- **Build**: `./gradlew :composeApp:installDebug`

## Component Creation Workflow

### Step 1: Duplicate Detection (CRITICAL)

Before creating any component, ALWAYS search for existing similar components:

```bash
# Find all existing composables by type
grep -r "@Composable.*fun.*Tile" composeApp/
grep -r "@Composable.*fun.*Card" composeApp/
grep -r "@Composable.*fun.*Button" composeApp/
grep -r "@Composable.*fun.*Grid" composeApp/

# List all composables with line counts
find composeApp -name "*.kt" -exec wc -l {} \; | sort -rn

# Search for specific patterns
grep -r "LazyColumn\|LazyRow" composeApp/
grep -r "Card\|Surface" composeApp/
```

**Warning Triggers** - Stop and ask user if:
- Component type already exists (e.g., user wants "ContactTile" but generic `Tile` exists)
- Description matches existing component (>80% similar)
- Component would be used < 3 times (suggest inline instead)

**Consolidation Guidance**:
- If >80% similar to existing → use existing or consolidate into generic
- If only data source differs → use generics/interfaces
- If 3+ similar components → extract common pattern

### Step 2: Determine Component Type

Ask clarifying questions:
1. **Location**: Should this go in `ui/components/` (reusable) or feature-specific?
2. **Reusability**: Will this be used in multiple places or just once?
3. **Generic vs Specific**: Should this work with different data types (generic) or is it feature-specific?
4. **State management**: Where does state live? (ViewModel, local, or hoisted)

### Step 3: Choose Component Category

| Category | Description | Location | Example |
|----------|-------------|----------|---------|
| **Common/Generic** | Reusable across features, uses interfaces | `ui/components/` | `GenericTile`, `AppCard` |
| **Feature-Specific** | Single feature use, tight coupling | `ui/screens/{feature}/` | `ScheduleItem`, `SpeakerCard` |
| **Screen** | Full-screen composition, navigation target | `ui/screens/` | `HomeScreen`, `ScheduleScreen` |
| **Theme/Design** | Design tokens, colors, typography | `ui/theme/` | `Spacing`, `Color` |

### Step 4: Design Guidelines

#### Generic Composable Pattern (Recommended for Reusability)

Use when: Same UI pattern appears 3+ times with >80% code similarity

```kotlin
interface TileData {
    val icon: String
    val title: String
    val url: String
}

@Composable
fun GenericTile(
    item: TileData,
    onClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = { onClick(item.url) },
        modifier = modifier
    ) {
        Column {
            Icon(imageVector = Icons.Default.Star, contentDescription = null)
            Text(text = item.title)
        }
    }
}
```

#### Feature-Specific Composable Pattern

Use when: Unique behavior, complex interactions, feature-specific state

```kotlin
@Composable
fun ScheduleItem(
    section: Section,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    var isExpanded by remember { mutableStateOf(false) }

    Column(modifier = modifier) {
        Text(text = section.title)
        if (isExpanded) {
            Text(text = section.description)
        }
    }
}
```

## Android Component Templates

### Template 1: Generic Data Composable (Reusable)

**File**: `composeApp/src/main/java/cz/krutsche/xcamp/ui/components/GenericTile.kt`

```kotlin
package cz.krutsche.xcamp.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import cz.krutsche.xcamp.ui.theme.Spacing
import cz.krutsche.xcamp.ui.theme.CornerRadius

/**
 * Generic tile component for displaying clickable items.
 *
 * @param item The data to display
 * @param onClick Callback when tile is clicked, receives the item's URL
 * @param modifier Modifier for the root composable
 */
@Composable
fun <T : TileData> GenericTile(
    item: T,
    onClick: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    var isPressed by remember { mutableStateOf(false) }

    Card(
        onClick = { onClick(item.url) },
        modifier = modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min),
        shape = MaterialTheme.shapes.medium,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier
                .padding(Spacing.md)
                .fillMaxWidth(),
            verticalArrangement = Arrangement.spacedBy(Spacing.sm)
        ) {
            // Icon
            Text(
                text = item.icon, // Replace with Icon painterResource or ImageVector
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            // Title
            Text(
                text = item.title,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 2
            )
        }
    }
}

/**
 * Interface defining the data contract for tile components.
 */
interface TileData {
    val icon: String
    val title: String
    val url: String
}

// Preview
@Preview(showBackground = true)
@Composable
private fun GenericTilePreview() {
    val sampleData = object : TileData {
        override val icon = "★"
        override val title = "Example Title"
        override val url = "https://example.com"
    }

    MaterialTheme {
        GenericTile(
            item = sampleData,
            onClick = {}
        )
    }
}
```

### Template 2: Feature-Specific Composable with ViewModel

**File**: `composeApp/src/main/java/cz/krutsche/xcamp/ui/screens/feature/FeatureScreen.kt`

```kotlin
package cz.krutsche.xcamp.ui screens.feature

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.viewmodel.compose.viewModel
import cz.krutsche.xcamp.shared.localization.Strings
import cz.krutsche.xcamp.ui.theme.Spacing

@Composable
fun FeatureScreen(
    viewModel: FeatureViewModel = viewModel(),
    modifier: Modifier = Modifier
) {
    val state by viewModel.state.collectAsState()

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(Spacing.md),
        verticalArrangement = Arrangement.spacedBy(Spacing.sm)
    ) {
        // Title
        Text(
            text = Strings.Feature.TITLE,
            style = MaterialTheme.typography.titleLarge
        )

        // Content based on state
        when (state) {
            is FeatureState.Loading -> {
                CircularProgressIndicator()
            }
            is FeatureState.Success -> {
                FeatureContent(state.data)
            }
            is FeatureState.Error -> {
                ErrorMessage(state.message)
            }
        }
    }
}

@Composable
private fun FeatureContent(data: String) {
    Text(
        text = data,
        style = MaterialTheme.typography.bodyMedium
    )
}

@Composable
private fun ErrorMessage(message: String) {
    Text(
        text = message,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.error
    )
}

@Preview(showBackground = true)
@Composable
private fun FeatureScreenPreview() {
    MaterialTheme {
        FeatureScreen()
    }
}
```

### Template 3: Expandable/Collapsible Composable

**File**: `composeApp/src/main/java/cz/krutsche/xcamp/ui/components/ExpandableCard.kt`

```kotlin
package cz.krutsche.xcamp.ui.components

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExpandLess
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.tooling.preview.Preview
import cz.krutsche.xcamp.ui.theme.Spacing
import cz.krutsche.xcamp.ui.theme.CornerRadius

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExpandableCard(
    title: String,
    content: String,
    icon: String, // Replace with ImageVector or painter resource
    modifier: Modifier = Modifier
) {
    var isExpanded by remember { mutableStateOf(false) }

    Card(
        onClick = { isExpanded = !isExpanded },
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.medium
    ) {
        Column(
            modifier = Modifier
                .padding(Spacing.md)
                .fillMaxWidth()
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(Spacing.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = icon, // Replace with Icon
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleMedium
                    )
                }

                // Expand/collapse icon
                Icon(
                    imageVector = if (isExpanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                    contentDescription = if (isExpanded) "Collapse" else "Expand",
                    modifier = Modifier.rotate(
                        animateFloatAsState(
                            targetValue = if (isExpanded) 180f else 0f,
                            animationSpec = spring(
                                dampingRatio = Spring.DampingRatioMediumBouncy,
                                stiffness = Spring.StiffnessLow
                            )
                        ).value
                    )
                )
            }

            // Expandable content
            AnimatedVisibility(
                visible = isExpanded,
                enter = expandVertically() + fadeIn(),
                exit = shrinkVertically() + fadeOut()
            ) {
                Text(
                    text = content,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = Spacing.sm)
                )
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun ExpandableCardPreview() {
    MaterialTheme {
        ExpandableCard(
            title = "Example Title",
            content = "This is the expandable content that appears when you tap the card.",
            icon = "ℹ️"
        )
    }
}
```

### Template 4: Simple Display Composable (Pure UI)

**File**: `composeApp/src/main/java/cz/krutsche/xcamp/ui/components/SimpleBadge.kt`

```kotlin
package cz.krutsche.xcamp.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import cz.krutsche.xcamp.ui.theme.Spacing

@Composable
fun SimpleBadge(
    text: String,
    color: Color,
    modifier: Modifier = Modifier
) {
    Text(
        text = text,
        style = MaterialTheme.typography.labelSmall,
        color = MaterialTheme.colorScheme.onPrimary,
        modifier = modifier
            .background(color, CircleShape)
            .padding(horizontal = Spacing.sm, vertical = Spacing.xs)
    )
}

@Preview(showBackground = true)
@Composable
private fun SimpleBadgePreview() {
    MaterialTheme {
        Row(horizontalArrangement = Arrangement.spacedBy(Spacing.sm)) {
            SimpleBadge(text = "New", color = Color.Blue)
            SimpleBadge(text = "Updated", color = Color.Green)
            SimpleBadge(text = "Important", color = Color.Red)
        }
    }
}
```

## Design Token Usage

**Define design tokens in `ui/theme/`** - match iOS values for consistency:

```kotlin
// ui/theme/Spacing.kt (includes CornerRadius)
package cz.krutsche.xcamp.ui.theme

import androidx.compose.ui.unit.dp

object Spacing {
    val xs = 4.dp
    val sm = 8.dp
    val md = 16.dp
    val lg = 24.dp
    val xl = 32.dp
    val xxl = 48.dp
}

object CornerRadius {
    val small = 8.dp
    val medium = 12.dp
    val large = 16.dp
    val extraLarge = 24.dp
}
```

**Additional token files** (split structure):
```kotlin
// ui/theme/Color.kt - Material 3 color scheme
// ui/theme/Shadow.kt - Shadow definitions
// ui/theme/Gradient.kt - Gradient definitions
```

**Usage in composables**:
```kotlin
.padding(Spacing.md)
.width(Spacing.lg)
.clipShape(RoundedCornerShape(CornerRadius.medium))
```

## String Management (CRITICAL)

**ALL user-facing strings MUST be in `Strings.kt` (shared module)**

### Adding New Strings

1. Open `shared/src/commonMain/kotlin/cz/krutsche/xcamp/shared/localization/Strings.kt`
2. Add nested object for feature:

```kotlin
object Strings {
    object Feature {
        const val TITLE = "Název funkce"
        const val DESCRIPTION = "Popis funkce"
        const val BUTTON_TEXT = "Tlačítko"
        const val ERROR_MESSAGE = "Chyba při načítání"
    }
}
```

3. Use in Kotlin Compose:

```kotlin
// GOOD - Use Strings.kt
Text(text = Strings.Feature.TITLE)
Button(onClick = {}) { Text(Strings.Feature.BUTTON_TEXT) }

// BAD - Hardcoded strings
Text(text = "Feature Title")
Button(onClick = {}) { Text("Click me") }
```

**See `.claude/subagents/strings-management.md` for complete patterns.**

## State Management Guidelines

### State Hoisting Pattern

**DO hoist state** to the caller for reusable components:

```kotlin
// GOOD - State hoisted
@Composable
fun Counter(
    count: Int,
    onIncrement: () -> Unit,
    modifier: Modifier = Modifier
) {
    Button(onClick = onIncrement, modifier = modifier) {
        Text("Count: $count")
    }
}

// Usage
var count by remember { mutableStateOf(0) }
Counter(count, onIncrement = { count++ })
```

**DON'T** keep state internal unless component-specific:

```kotlin
// OK for component-specific state (like expansion)
@Composable
fun ExpandableCard(title: String, content: String) {
    var isExpanded by remember { mutableStateOf(false) }
    // isExpanded is internal to this component's behavior
}
```

### ViewModel Pattern

For screens with business logic:

```kotlin
@Composable
fun FeatureScreen(
    viewModel: FeatureViewModel = viewModel(),
    modifier: Modifier = Modifier
) {
    val state by viewModel.state.collectAsState()

    // All business logic in ViewModel
    // UI just displays state
}
```

## KISS/DRY Decision Guidelines

### When to Create Generic Composables

**Create generic when**:
- Same pattern appears 3+ times
- >80% code similarity between composables
- Only data source differs
- Need multiple variants with same behavior

**Example**: `<T : TileData>` generic tile for different data types

### When to Keep Feature-Specific Composables

**Keep separate when**:
- Unique interactions or animations
- Complex conditional logic
- Screen-specific behavior
- Significantly different layouts

**Example**: `ScheduleItem` with time-specific logic

### Avoid Over-Abstraction

**Don't create generic composables for**:
- One-off UI elements
- Components used < 3 times
- Things that might change differently per feature

## Component Checklist

### Before Creating Component
- [ ] Searched existing composables for duplicates?
- [ ] Verified no similar component exists in `ui/components/`?
- [ ] Confirmed strings exist in `Strings.kt` or added them?
- [ ] Chose correct location (`ui/components/`, `ui/screens/`, etc.)?

### For Android Composables
- [ ] Composable has single responsibility?
- [ ] `@Preview` annotation included?
- [ ] Uses Material 3 components?
- [ ] State properly hoisted?
- [ ] Design tokens used consistently?
- [ ] No hardcoded strings (all from Strings.kt)?
- [ ] Modifier parameter with sensible default?
- [ ] Content description for accessibility?

### For Generic Composables
- [ ] Interface defined for data type?
- [ ] Type parameter properly constrained?
- [ ] Preview includes example data?
- [ ] Documentation comment included?

## Component Naming Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Screen-level | PascalCase + "Screen" suffix | `HomeScreen`, `ScheduleScreen` |
| Components | PascalCase descriptive name | `ScheduleItem`, `SpeakerCard`, `GenericTile` |
| Generic | Include type parameter | `GenericTile<T : TileData>` |
| Composable functions | camelCase (PascalCase if exported) | `genericTile`, `scheduleItem` |
| Interfaces | PascalCase + "Data" suffix | `TileData`, `ItemData` |

## File Organization

```
composeApp/src/main/java/cz/krutsche/xcamp/
├── ui/
│   ├── components/       # Reusable composables
│   │   ├── GenericTile.kt
│   │   ├── AppCard.kt
│   │   └── ExpandableCard.kt
│   ├── screens/         # Screen-level composables
│   │   ├── home/
│   │   ├── schedule/
│   │   └── feature/
│   └── theme/           # Design tokens, colors, typography
│       ├── Color.kt              # Material 3 color scheme
│       ├── Type.kt               # Typography
│       ├── Spacing.kt            # Spacing and CornerRadius
│       ├── Shadow.kt             # Shadow definitions
│       └── Gradient.kt           # Gradient definitions
└── viewmodel/           # Android-specific ViewModels
```

## Common Pitfalls to Avoid

1. **Hardcoded strings**: Always use `Strings.kt` - see `strings-management.md`
2. **Business logic in UI**: Move to shared Kotlin module or ViewModels
3. **Duplicate composables**: Check `ui/components/` before creating new
4. **Over-genericization**: Don't make generic components for 1-2 use cases
5. **Poor state hoisting**: Keep state as local as possible, hoist for reuse
6. **Missing previews**: Always include `@Preview` annotations
7. **Inconsistent spacing**: Always use `Spacing` tokens
8. **Ignoring Material 3**: Use Material 3 components and patterns
9. **Large files**: Keep composables focused and concise
10. **No accessibility**: Add contentDescription to interactive elements

## Common Commands

```bash
# Build and install debug APK
./gradlew :composeApp:installDebug

# Clean build
./gradlew clean

# Find all Composable functions
grep -r "@Composable" composeApp/

# List all Kotlin files with line counts
find composeApp -name "*.kt" -exec wc -l {} \; | sort -rn

# Search for specific component patterns
grep -r "Card\|Surface" composeApp/
grep -r "LazyColumn\|LazyRow" composeApp/

# Run unit tests
./gradlew test

# Run instrumented tests
./gradlew connectedAndroidTest
```

## Example Creation Flow

**User Request**: "Create a tile component for displaying speakers"

1. **Duplicate Detection**:
   ```bash
   grep -r "@Composable.*fun.*Tile\|Speaker" composeApp/
   # Found: GenericTile<T : TileData> in ui/components/
   ```

2. **Analysis**: `GenericTile` exists and is generic!

3. **Decision**: Reuse existing component by implementing `TileData` interface for Speaker

4. **Result**: No new component needed - use existing generic component

**User Request**: "Create a schedule item component with time and location"

1. **Duplicate Detection**:
   ```bash
   grep -r "schedule\|Schedule" composeApp/
   # No matches for item component
   ```

2. **Analysis**: New unique component with specific layout requirements

3. **Decision**: Create `ScheduleItem.kt` in `ui/screens/schedule/`

4. **Implementation**: Use Card template, add strings to `Strings.kt`, include preview

## Related Documentation

- **Android Development**: `.claude/subagents/android-dev.md` - Compose patterns, Material 3, Gradle
- **UI Code Review**: `.claude/subagents/ui-review.md` - KISS/DRY principles, duplicate detection
- **Strings Management**: `.claude/subagents/strings-management.md` - ALL UI text in Strings.kt
- **Shared Logic**: `.claude/subagents/shared-logic.md` - Repository pattern, SQLDelight, Koin DI

## Material 3 Quick Reference

### Common Components

```kotlin
// Cards
Card(onClick = {}) { /* content */ }

// Buttons
Button(onClick = {}) { Text("Button") }
TextButton(onClick = {}) { Text("Text Button") }
FilledTonalButton(onClick = {}) { Text("Tonal") }

// Input
OutlinedTextField(value = "", onValueChange = {}, label = { Text("Label") })

// Lists
LazyColumn {
    items(items) { item -> ItemContent(item) }
}

// Navigation
NavigationHost(navController, startDestination) {
    composable("route") { Screen() }
}
```

### Theming

```kotlin
// Colors
MaterialTheme.colorScheme.primary
MaterialTheme.colorScheme.onPrimary
MaterialTheme.colorScheme.surface
MaterialTheme.colorScheme.background

// Typography
MaterialTheme.typography.displayLarge
MaterialTheme.typography.headlineMedium
MaterialTheme.typography.titleLarge
MaterialTheme.typography.bodyMedium
MaterialTheme.typography.labelSmall

// Shapes
MaterialTheme.shapes.small
MaterialTheme.shapes.medium
MaterialTheme.shapes.large
```
