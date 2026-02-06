# mobile-android-design

Master Material Design 3 and Jetpack Compose patterns for building native Android apps.

## When to use this skill

Use this skill when:
- Designing Android UI interfaces and layouts
- Implementing Jetpack Compose components
- Applying Material Design 3 theming and styling
- Setting up navigation in Compose apps
- Choosing appropriate Material components for specific use cases
- Ensuring apps follow Google's Material Design guidelines
- Implementing responsive layouts for different screen sizes

## Material Design 3 Principles

Material Design 3 (Material You) emphasizes:
- **Personalization**: Dynamic color that adapts to user's wallpaper
- **Adaptive layout**: Components that work across phones, tablets, and foldables
- **Expressive motion**: Meaningful animations and transitions
- **Accessibility**: WCAG-compliant color contrast and touch targets

## Jetpack Compose Layout System

### Core Layouts

```kotlin
// Column - vertical arrangement
Column(
    modifier = Modifier.fillMaxWidth(),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    Text("Title")
    Text("Subtitle")
}

// Row - horizontal arrangement
Row(
    modifier = Modifier.fillMaxWidth(),
    horizontalArrangement = Arrangement.SpaceBetween,
    verticalAlignment = Alignment.CenterVertically
) {
    Text("Start")
    Text("End")
}

// Box - stacking children
Box(
    modifier = Modifier.height(200.dp),
    contentAlignment = Alignment.Center
) {
    CircularProgressIndicator()
    Text("Loading...")
}
```

### Modifiers Order

Apply modifiers in this order for performance:
1. Size modifiers (`fillMaxWidth`, `size`)
2. Layout modifiers (`padding`, `offset`)
3. Appearance modifiers (`background`, `border`)
4. Interaction modifiers (`clickable`, `scroll`)
5. Drawing modifiers (`drawBehind`, `zIndex`)

### State in Compose

```kotlin
// Remember - state survives recomposition
var text by remember { mutableStateOf("") }

// RememberSaveable - state survives configuration changes
var text by rememberSaveable { mutableStateOf("") }

// Derived state - computed from other state
val isValid by remember {
    derivedStateOf { text.length >= 6 }
}

// State hoisting - lift state to caller
@Composable
fun MyTextField(
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier
) {
    TextField(
        value = value,
        onValueChange = onValueChange,
        modifier = modifier
    )
}
```

## Navigation Patterns

### Navigation Compose Setup

```kotlin
// Define routes
object Screen {
    const val HOME = "home"
    const val DETAILS = "details/{itemId}"
    const val PROFILE = "profile/{userId}"
}

// Create NavHost
@Composable
fun MyAppNavHost(
    navController: NavHostController,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = Screen.HOME,
        modifier = modifier
    ) {
        composable(Screen.HOME) {
            HomeScreen(
                onItemClick = { itemId ->
                    navController.navigate("details/$itemId")
                }
            )
        }

        composable(
            route = Screen.DETAILS,
            arguments = listOf(navArgument("itemId") { type = NavType.StringType })
        ) { backStackEntry ->
            val itemId = backStackEntry.arguments?.getString("itemId")
            DetailsScreen(itemId = itemId)
        }
    }
}
```

### Type-Safe Navigation (Recommended)

```kotlin
// Define navigation graph with type safety
@Serializable
data object Home

@Serializable
data class Details(val itemId: String)

@Composable
fun MyAppNavHost(
    navController: NavHostController
) {
    NavHost(
        navController = navController,
        startDestination = Home
    ) {
        composable<Home> {
            HomeScreen(
                onItemClick = { itemId ->
                    navController.navigate(Details(itemId))
                }
            )
        }

        composable<Details> { backStackEntry ->
            val details: Details = backStackEntry.toRoute()
            DetailsScreen(itemId = details.itemId)
        }
    }
}
```

### Bottom Navigation

```kotlin
@Composable
fun BottomBar(
    navController: NavHostController
) {
    val items = listOf(
        BottomNavItem.Home,
        BottomNavItem.Search,
        BottomNavItem.Profile
    )

    NavigationBar {
        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentRoute = navBackStackEntry?.destination?.route

        items.forEach { item ->
            NavigationBarItem(
                icon = { Icon(item.icon, contentDescription = null) },
                label = { Text(stringResource(item.labelRes)) },
                selected = currentRoute == item.route,
                onClick = {
                    navController.navigate(item.route) {
                        popUpTo(navController.graph.findStartDestination().id) {
                            saveState = true
                        }
                        launchSingleTop = true
                        restoreState = true
                    }
                }
            )
        }
    }
}
```

### Navigation Rail (Tablet/Desktop)

```kotlin
@Composable
fun NavigationRail(
    navController: NavHostController,
    modifier: Modifier = Modifier
) {
    val items = listOf(/* ... */)

    NavigationRail(
        modifier = modifier,
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        items.forEach { item ->
            val selected = /* ... */
            NavigationRailItem(
                selected = selected,
                onClick = { /* ... */ },
                icon = { Icon(item.icon, contentDescription = null) },
                label = { Text(stringResource(item.labelRes)) }
            )
        }
    }
}
```

## Material 3 Theming

### Color System

```kotlin
// Generate theme from seed color
private val Blue80 = Color(0xFF607D8B)
private val Blue = Color(0xFF2196F3)

private val LightColors = lightColorScheme(
    primary = Blue,
    onPrimary = Color.White,
    primaryContainer = Blue80,
    onPrimaryContainer = Color.White,
    background = Color(0xFFFFFBFE),
    onBackground = Color(0xFF1C1B1F)
)

private val DarkColors = darkColorScheme(
    primary = Blue80,
    onPrimary = Color.White,
    primaryContainer = Blue,
    onPrimaryContainer = Color.White,
    background = Color(0xFF1C1B1F),
    onBackground = Color(0xFFE6E1E5)
)

@Composable
fun MyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColors else LightColors

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
```

### Dynamic Color (Android 12+)

```kotlin
@Composable
fun MyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColorEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColors
        else -> LightColors
    }

    MaterialTheme(colorScheme = colorScheme, content = content)
}
```

### Typography

```kotlin
val Typography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp
    ),
    headlineLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    )
)
```

### Shape System

```kotlin
val Shapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(28.dp)
)
```

### Elevation and Surface

```kotlin
// Use tonal elevation in Material 3
Surface(
    modifier = Modifier.fillMaxWidth(),
        tonalElevation = 2.dp
) {
    // Content
}

// Surface with color variant
Surface(
    color = MaterialTheme.colorScheme.surfaceVariant,
    tonalElevation = 3.dp
) {
    // Content
}
```

## Component Examples

### Cards

```kotlin
// Elevated card - default
ElevatedCard(
    onClick = { /* Handle click */ },
    modifier = Modifier.fillMaxWidth()
) {
    Text("Elevated Card")
}

// Filled card - emphasis
FilledCard(
    onClick = { /* Handle click */ }
) {
    Text("Filled Card")
}

// Outlined card - less emphasis
OutlinedCard(
    onClick = { /* Handle click */ }
) {
    Text("Outlined Card")
}
```

### Buttons

```kotlin
// Filled button - primary action
Button(
    onClick = { /* Handle click */ },
    enabled = true
) {
    Icon(Icons.Default.Add, contentDescription = null)
    Spacer(Modifier.size(ButtonDefaults.IconSpacing))
    Text("Add Item")
}

// Filled tonal button - secondary action
FilledTonalButton(onClick = { /* ... */ }) {
    Text("Secondary")
}

// Outlined button - tertiary action
OutlinedButton(onClick = { /* ... */ }) {
    Text("Tertiary")
}

// Text button - low emphasis
TextButton(onClick = { /* ... */ }) {
    Text("Learn More")
}
```

### Text Fields

```kotlin
// Outlined text field
OutlinedTextField(
    value = text,
    onValueChange = { text = it },
    label = { Text("Email") },
    leadingIcon = {
        Icon(Icons.Default.Email, contentDescription = null)
    },
    supportingText = { Text("We'll never share your email") },
    isError = hasError,
    keyboardOptions = KeyboardOptions(
        keyboardType = KeyboardType.Email,
        imeAction = ImeAction.Next
    ),
    singleLine = true
)

// Filled text field
TextField(
    value = text,
    onValueChange = { text = it },
    label = { Text("Password") },
    visualTransformation = PasswordVisualTransformation(),
    keyboardOptions = KeyboardOptions(
        keyboardType = KeyboardType.Password,
        imeAction = ImeAction.Done
    )
)
```

### Chips

```kotlin
// Assist chip - suggests action
AssistChip(
    onClick = { /* Handle click */ },
    label = { Text("Get Directions") },
    leadingIcon = {
        Icon(Icons.Default.Directions, contentDescription = null)
    }
)

// Suggestion chip - filter option
SuggestionChip(
    onClick = { /* Toggle filter */ },
    label = { Text("Category") },
    icon = {
        Icon(
            if (selected) Icons.Default.Check else null,
            contentDescription = null
        )
    }
)

// Input chip - selected option
InputChip(
    selected = selected,
    onClick = { /* Toggle */ },
    label = { Text("Option") },
    avatar = {
        Icon(Icons.Default.Person, contentDescription = null)
    }
)
```

### Lists

```kotlin
// LazyColumn for large lists
LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(16.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    items(items.size) { index ->
        ListItem(
            headlineContent = { Text(items[index].title) },
            supportingContent = { Text(items[index].subtitle) },
            leadingContent = {
                Icon(Icons.Default.Star, contentDescription = null)
            },
            trailingContent = {
                Text(items[index].time)
            }
        )
    }
}

// Sticky headers
LazyColumn {
    items(groupedItems.size) { group ->
        stickyHeader {
            Text(
                group.name,
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.surface)
                    .padding(16.dp),
                style = MaterialTheme.typography.titleMedium
            )
        }
        items(group.items) { item ->
            ListItem(headlineContent = { Text(item.name) })
        }
    }
}
```

### Dialogs

```kotlin
var showDialog by remember { mutableStateOf(false) }

if (showDialog) {
    AlertDialog(
        onDismissRequest = { showDialog = false },
        icon = { Icon(Icons.Default.Warning, contentDescription = null) },
        title = { Text("Delete Item") },
        text = { Text("This action cannot be undone.") },
        confirmButton = {
            TextButton(
                onClick = { showDialog = false }
            ) {
                Text("Delete")
            }
        },
        dismissButton = {
            TextButton(
                onClick = { showDialog = false }
            ) {
                Text("Cancel")
            }
        }
    )
}
```

### Bottom Sheets

```kotlin
val sheetState = rememberModalBottomSheetState()
var showSheet by remember { mutableStateOf(false) }

if (showSheet) {
    ModalBottomSheet(
        onDismissRequest = { showSheet = false },
        sheetState = sheetState
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Sheet Content", style = MaterialTheme.typography.titleLarge)
            // More content
        }
    }
}
```

### Snackbars

```kotlin
val scope = rememberCoroutineScope()
val snackbarHostState = remember { SnackbarHostState() }

Scaffold(
    snackbarHost = { SnackbarHost(snackbarHostState) }
) { padding ->
    Button(
        onClick = {
            scope.launch {
                val result = snackbarHostState.showSnackbar(
                    message = "Item deleted",
                    actionLabel = "Undo",
                    duration = SnackbarDuration.Short
                )
                if (result == SnackbarResult.ActionPerformed) {
                    // Handle undo
                }
            }
        }
    ) {
        Text("Show Snackbar")
    }
}
```

## Responsive Design

### Window Size Classes

```kotlin
@Composable
fun MyApp() {
    val windowSizeClass = calculateWindowSizeClass(activity)

    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> {
            // Phone portrait
            CompactLayout()
        }
        WindowWidthSizeClass.Medium -> {
            // Phone landscape / Foldable
            MediumLayout()
        }
        WindowWidthSizeClass.Expanded -> {
            // Tablet
            ExpandedLayout()
        }
    }
}
```

### Adaptive Layout

```kotlin
@Composable
fun AdaptiveLayout() {
    val windowSize = calculateWindowSizeClass(activity)
    val isCompact = windowSize.widthSizeClass == WindowWidthSizeClass.Compact

    if (isCompact) {
        // Bottom navigation
        Scaffold(
            bottomBar = { BottomBar(navController) }
        ) { padding ->
            NavHost(navController, Modifier.padding(padding))
        }
    } else {
        // Navigation rail
        Row {
            NavigationRail(navController)
            NavHost(navController, Modifier.weight(1f))
        }
    }
}
```

## Best Practices

### Performance
- Use `key()` parameter in LazyColumn/LazyRow for stable items
- Avoid nested scrolling without clear purpose
- Use `derivedStateOf` for expensive computations
- Prefer composition over inheritance
- Keep composables small and focused

### Accessibility
- All interactive elements need minimum 48x48dp touch target
- Use `contentDescription` for images and icons
- Support keyboard navigation with `focusable()`
- Use semantic modifiers: `semantics { heading() }`
- Ensure color contrast meets WCAG AA standards

### State Management
- Hoist state to the lowest common ancestor
- Use `remember` for local UI state
- Use `rememberSaveable` for state that survives process death
- Use ViewModel for screen-level state
- Prefer stateless composables for reusability

### Composition
- Follow single responsibility principle
- Name composables with PascalCase
- Use `@Preview` annotation for UI development
- Write preview with multiple configurations
- Extract reusable components into separate files

## Common Issues and Solutions

### Recomposition Loop
Avoid reading state in a way that triggers infinite recomposition:
```kotlin
// Wrong
Box {
    val offset = randomOffset() // Runs every recomposition
}

// Correct
Box {
    val offset by remember { mutableStateOf(randomOffset()) }
}
```

### Remember with Keys
Use correct keys for remember:
```kotlin
// Wrong - doesn't update when item changes
val item by remember { mutableStateOf(fetchItem(itemId)) }

// Correct - recomputes when itemId changes
val item by remember(itemId) { mutableStateOf(fetchItem(itemId)) }
```

### Side Effects
Use proper side effect APIs:
- `LaunchedEffect`: Run when key changes, can call suspend functions
- `SideEffect`: Run every composition, non-suspending
- `rememberCoroutineScope`: Get scope for user interaction
- `DisposableEffect`: Setup/teardown with cleanup

```kotlin
// LaunchedEffect for one-time or key-based events
LaunchedEffect(userId) {
    viewModel.loadUser(userId)
}

// rememberCoroutineScope for button clicks
val scope = rememberCoroutineScope()
Button(onClick = {
    scope.launch {
        viewModel.submitForm()
    }
}) { Text("Submit") }
```
