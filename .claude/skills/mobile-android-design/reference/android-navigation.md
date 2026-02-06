# Android Navigation in Compose

Comprehensive guide for implementing navigation patterns in Jetpack Compose applications using Navigation Compose.

## Navigation Compose Basics

### Dependencies

```gradle
dependencies {
    implementation("androidx.navigation:navigation-compose:2.8.5")
    // For type-safe navigation (recommended)
    implementation("androidx.navigation:navigation-compose:2.8.5")
    implementation("androidx.hilt:hilt-navigation-compose:1.2.0")
}
```

### Setup NavHost

```kotlin
@Composable
fun MyAppNavHost(
    navController: NavHostController,
    modifier: Modifier = Modifier
) {
    NavHost(
        navController = navController,
        startDestination = "home",
        modifier = modifier
    ) {
        composable("home") {
            HomeScreen(
                onNavigateToDetails = { itemId ->
                    navController.navigate("details/$itemId")
                }
            )
        }
        composable("profile") {
            ProfileScreen()
        }
    }
}
```

### NavController Setup

```kotlin
@Composable
fun MyApp() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = { BottomBar(navController) }
    ) { padding ->
        MyAppNavHost(
            navController = navController,
            modifier = Modifier.padding(padding)
        )
    }
}
```

## Type-Safe Navigation

### Define Routes with Serializable Classes

```kotlin
import kotlinx.serialization.Serializable

@Serializable
data object Home

@Serializable
data class Details(val itemId: String)

@Serializable
data class Profile(val userId: String? = null)

@Serializable
data object Settings
```

### Type-Safe NavHost

```kotlin
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
                onNavigateToDetails = { itemId ->
                    navController.navigate(Details(itemId))
                }
            )
        }

        composable<Details> { backStackEntry ->
            val details: Details = backStackEntry.toRoute()
            DetailsScreen(
                itemId = details.itemId,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable<Profile> { backStackEntry ->
            val profile: Profile = backStackEntry.toRoute()
            ProfileScreen(
                userId = profile.userId
            )
        }
    }
}
```

### Navigate with Arguments

```kotlin
@Composable
fun HomeScreen(
    onNavigateToDetails: (String) -> Unit
) {
    LazyColumn {
        items(items) { item ->
            ListItem(
                headlineContent = { Text(item.title) },
                onClick = { onNavigateToDetails(item.id) }
            )
        }
    }
}
```

### Optional Arguments

```kotlin
@Serializable
data class Search(
    val query: String? = null,
    val category: String? = null
)

composable<Search> { backStackEntry ->
    val search: Search = backStackEntry.toRoute()
    SearchScreen(
        query = search.query,
        category = search.category
    )
}

// Navigate with or without arguments
navController.navigate(Search(query = "kotlin"))
navController.navigate(Search()) // Both null
```

## Bottom Navigation

### Define Navigation Items

```kotlin
sealed class BottomNavItem(
    val route: String,
    val icon: ImageVector,
    @StringRes val labelRes: Int
) {
    data object Home : BottomNavItem("home", Icons.Default.Home, R.string.home)
    data object Search : BottomNavItem("search", Icons.Default.Search, R.string.search)
    data object Profile : BottomNavItem("profile", Icons.Default.Person, R.string.profile)
}
```

### Bottom Navigation Bar

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

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    NavigationBar {
        items.forEach { item ->
            val selected = currentRoute == item.route
            NavigationBarItem(
                icon = {
                    Icon(
                        item.icon,
                        contentDescription = stringResource(item.labelRes)
                    )
                },
                label = { Text(stringResource(item.labelRes)) },
                selected = selected,
                onClick = {
                    if (currentRoute != item.route) {
                        navController.navigate(item.route) {
                            // Pop up to the start destination of the graph to
                            // avoid building up a large stack of destinations
                            popUpTo(navController.graph.findStartDestination().id) {
                                saveState = true
                            }
                            // Avoid multiple copies of the same destination when
                            // reselecting the same item
                            launchSingleTop = true
                            // Restore state when reselecting a previously selected item
                            restoreState = true
                        }
                    }
                }
            )
        }
    }
}
```

### Type-Safe Bottom Navigation

```kotlin
@Composable
fun BottomBar(
    navController: NavHostController
) {
    NavigationBar {
        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentDestination = navBackStackEntry?.destination

        items.forEach { item ->
            val selected = currentDestination?.hasRoute(item.route::class) == true

            NavigationBarItem(
                icon = {
                    Icon(
                        painter = painterResource(item.iconRes),
                        contentDescription = stringResource(item.labelRes)
                    )
                },
                label = { Text(stringResource(item.labelRes)) },
                selected = selected,
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

## Navigation Rail

### Navigation Rail for Larger Screens

```kotlin
@OptIn(ExperimentalMaterial3AdaptiveApi::class)
@Composable
fun NavigationRail(
    navController: NavHostController,
    modifier: Modifier = Modifier
) {
    val items = listOf(/* ... */)
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    NavigationRail(
        modifier = modifier,
        containerColor = MaterialTheme.colorScheme.surface,
        header = {
            FloatingActionButton(
                onClick = { /* Handle create */ },
                modifier = Modifier.padding(16.dp)
            ) {
                Icon(Icons.Default.Add, contentDescription = null)
            }
        }
    ) {
        items.forEach { item ->
            val selected = currentDestination?.hasRoute(item.route::class) == true

            NavigationRailItem(
                selected = selected,
                onClick = {
                    navController.navigate(item.route) {
                        popUpTo(navController.graph.findStartDestination().id) {
                            saveState = true
                        }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                icon = {
                    Icon(
                        painter = painterResource(item.iconRes),
                        contentDescription = stringResource(item.labelRes)
                    )
                },
                label = { Text(stringResource(item.labelRes)) },
                alwaysShowLabel = false
            )
        }
    }
}
```

## Navigation Drawer

### Permanent Navigation Drawer (Desktop/Tablet)

```kotlin
@OptIn(ExperimentalMaterial3AdaptiveApi::class)
@Composable
fun PermanentDrawer(
    navController: NavHostController,
    content: @Composable (PaddingValues) -> Unit
) {
    PermanentNavigationDrawer(
        drawerContent = {
            PermanentDrawerSheet(
                modifier = Modifier.width(300.dp)
            ) {
                DrawerHeader()
                DrawerItems(navController)
            }
        }
    ) { padding ->
        content(padding)
    }
}

@Composable
fun DrawerHeader() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Text(
            "App Name",
            style = MaterialTheme.typography.titleLarge
        )
        Text(
            "user@example.com",
            style = MaterialTheme.typography.bodyMedium
        )
    }
}
```

### Modal Navigation Drawer (Mobile)

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ModalDrawer(
    navController: NavHostController,
    content: @Composable () -> Unit
) {
    val drawerState = rememberDrawerState(DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet {
                DrawerHeader()
                DrawerItems(
                    navController = navController,
                    onItemClick = {
                        scope.launch { drawerState.close() }
                    }
                )
            }
        },
        content = content
    )
}
```

### Dismissible Navigation Drawer (Tablet)

```kotlin
@OptIn(ExperimentalMaterial3AdaptiveApi::class)
@Composable
fun DismissibleDrawer(
    navController: NavHostController,
    content: @Composable (PaddingValues) -> Unit
) {
    val drawerState = rememberDrawerState(DrawerValue.Closed)

    DismissibleNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            DismissibleDrawerSheet {
                DrawerHeader()
                DrawerItems(navController)
            }
        }
    ) { padding ->
        content(padding)
    }
}
```

## Deep Linking

### Define Deep Link

```kotlin
// Define deep link pattern
val uriPattern = "https://www.example.com/details/{itemId}"

composable(
    route = "details/{itemId}",
    deepLinks = listOf(navDeepLink { uriPattern = uriPattern })
) { backStackEntry ->
    val itemId = backStackEntry.arguments?.getString("itemId")
    DetailsScreen(itemId = itemId)
}
```

### Type-Safe Deep Link

```kotlin
@Serializable
data class Details(val itemId: String)

composable<Details>(
    deepLinks = listOf(
        navDeepLink<Details>(basePath = "details"),
        navDeepLink<Details>(
            action = Intent.ACTION_VIEW,
            mimeType = "image/*",
            uriPattern = "https://www.example.com/details/{itemId}"
        )
    )
) { backStackEntry ->
    val details: Details = backStackEntry.toRoute()
    DetailsScreen(details.itemId)
}
```

### Handle Deep Link Intent

```kotlin
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            val navController = rememberNavController()

            // Handle deep link from intent
            val deepLinkIntent = intent
            navController.handleDeepLink(deepLinkIntent)

            MyApp(navController)
        }
    }
}
```

## Nested Navigation

### Nested Graphs

```kotlin
@Serializable
data object TabsRoot

@Serializable
data object Home

@Serializable
data object Search

@Serializable
data object Profile

@Serializable
data class Details(val itemId: String)

@Composable
fun MyAppNavHost(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = TabsRoot
    ) {
        // Nested navigation graph for tabs
        navigation<TabsRoot>(startDestination = Home) {
            composable<Home> { HomeScreen(/* ... */) }
            composable<Search> { SearchScreen(/* ... */) }
            composable<Profile> { ProfileScreen(/* ... */) }
        }

        // Details screen outside tabs
        composable<Details> { backStackEntry ->
            val details: Details = backStackEntry.toRoute()
            DetailsScreen(details.itemId)
        }
    }
}
```

## Navigation State Management

### Navigation with ViewModel

```kotlin
@HiltViewModel
class NavigationViewModel @Inject constructor() : ViewModel() {
    val navigationCommands = Channel<NavigationCommand>(Channel.BUFFERED)

    fun navigateTo(route: Any) {
        navigationCommands.trySend(NavigationCommand.Navigate(route))
    }

    fun navigateBack() {
        navigationCommands.trySend(NavigationCommand.NavigateBack)
    }
}

sealed class NavigationCommand {
    data class Navigate(val route: Any) : NavigationCommand()
    data object NavigateBack : NavigationCommand()
}

@Composable
fun NavigationEffects(
    navController: NavHostController,
    viewModel: NavigationViewModel
) {
    LaunchedEffect(Unit) {
        viewModel.navigationCommands.receiveAsFlow().collect { command ->
            when (command) {
                is NavigationCommand.Navigate -> {
                    navController.navigate(command.route)
                }
                NavigationCommand.NavigateBack -> {
                    navController.popBackStack()
                }
            }
        }
    }
}
```

## Navigation Animations

### Custom Enter/Exit Transitions

```kotlin
composable<Details>(
    enterTransition = {
        slideIntoContainer(
            towards = AnimatedContentTransitionScope.SlideDirection.Start,
            animationSpec = tween(300)
        )
    },
    exitTransition = {
        slideOutOfContainer(
            towards = AnimatedContentTransitionScope.SlideDirection.Start,
            animationSpec = tween(300)
        )
    },
    popEnterTransition = {
        slideIntoContainer(
            towards = AnimatedContentTransitionScope.SlideDirection.End,
            animationSpec = tween(300)
        )
    },
    popExitTransition = {
        slideOutOfContainer(
            towards = AnimatedContentTransitionScope.SlideDirection.End,
            animationSpec = tween(300)
        )
    }
) { backStackEntry ->
    val details: Details = backStackEntry.toRoute()
    DetailsScreen(details.itemId)
}
```

### Shared Element Transitions

```kotlin
composable<Details>(
    enterTransition = {
        fadeIn(
            animationSpec = tween(300)
        )
    },
    exitTransition = {
        fadeOut(
            animationSpec = tween(300)
        )
    },
    popEnterTransition = {
        fadeIn(
            animationSpec = tween(300)
        )
    },
    popExitTransition = {
        fadeOut(
            animationSpec = tween(300)
        )
    }
) { backStackEntry ->
    // Shared element transitions require experimental API
    // Coming in future Navigation Compose versions
}
```

## Navigation Result Callbacks

### Pass Data Back to Previous Screen

```kotlin
// Navigate with result callback
@Composable
fun FromScreen() {
    val navController = rememberNavController()

    Button(onClick = {
        navController.navigate(
            OptionsScreenDestination(
                onOptionSelected = { option ->
                    navController.previousBackStackEntry
                        ?.savedStateHandle
                        ?.set("selected_option", option)
                    navController.popBackStack()
                }
            )
        )
    }) {
        Text("Select Option")
    }
}

// Receive result
@Composable
fun ToScreen() {
    val navController = rememberNavController()
    val selectedOption by navController.currentBackStackEntry
        ?.savedStateHandle
        ?.getStateFlow<String?>("selected_option", null)
        ?.collectAsState() ?: remember { mutableStateOf(null) }

    LaunchedEffect(selectedOption) {
        selectedOption?.let { option ->
            // Handle selected option
            navController.previousBackStackEntry
                ?.savedStateHandle
                ?.remove<String>("selected_option")
        }
    }
}
```

## Best Practices

1. **Use type-safe navigation** for compile-time safety and better developer experience
2. **Pop up to start destination** when navigating in bottom navigation to avoid large back stacks
3. **Save and restore state** for bottom navigation items using `saveState` and `restoreState`
4. **Use nested navigation** for related flows that should be managed together
5. **Handle deep links** properly to allow external apps to navigate into your app
6. **Test navigation flows** using Compose testing tools
7. **Consider window size** when choosing between bottom nav, navigation rail, and drawer
