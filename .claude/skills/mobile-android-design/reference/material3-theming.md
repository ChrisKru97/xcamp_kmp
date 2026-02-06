# Material 3 Theming in Compose

Comprehensive guide for implementing Material Design 3 theming, including color systems, typography, shapes, elevation, and responsive design.

## Color System

### Dynamic Color (Android 12+)

Dynamic color automatically generates a color scheme from the user's wallpaper.

```kotlin
@Composable
fun MyTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        content = content
    )
}
```

### Custom Color Scheme

Define custom colors when dynamic color isn't available or when you need brand colors.

```kotlin
private val Primary80 = Color(0xFF6750A4)
private val PrimaryContainer80 = Color(0xFFEADDFF)
private val OnPrimary80 = Color(0xFFFFFFFF)

private val Primary20 = Color(0xFF625B71)
private val PrimaryContainer20 = Color(0xFFE8DEF8)
private val OnPrimary20 = Color(0xFFFFFFFF)

private val LightColorScheme = lightColorScheme(
    primary = Primary80,
    onPrimary = OnPrimary80,
    primaryContainer = PrimaryContainer80,
    onPrimaryContainer = Primary20,

    secondary = Color(0xFF625B71),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFE8DEF8),
    onSecondaryContainer = Color(0xFF1D192B),

    tertiary = Color(0xFF7D5260),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFFFD8E4),
    onTertiaryContainer = Color(0xFF31111D),

    error = Color(0xFFBA1A1A),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = Color(0xFF410002),

    background = Color(0xFFFFFBFE),
    onBackground = Color(0xFF1C1B1F),

    surface = Color(0xFFFFFBFE),
    onSurface = Color(0xFF1C1B1F),
    surfaceVariant = Color(0xFFE7E0EC),
    onSurfaceVariant = Color(0xFF49454F),

    outline = Color(0xFF79747E),
    outlineVariant = Color(0xFFCAC4D0),

    inverseSurface = Color(0xFF313033),
    inverseOnSurface = Color(0xFFF4EFF4),

    scrim = Color(0xFF000000),
)

private val DarkColorScheme = darkColorScheme(
    primary = Primary20,
    onPrimary = OnPrimary20,
    primaryContainer = PrimaryContainer20,
    onPrimaryContainer = Primary80,

    secondary = Color(0xFFCCC2DC),
    onSecondary = Color(0xFF332D41),
    secondaryContainer = Color(0xFF4A4458),
    onSecondaryContainer = Color(0xFFE8DEF8),

    tertiary = Color(0xFFEFB8C8),
    onTertiary = Color(0xFF492532),
    tertiaryContainer = Color(0xFF633B48),
    onTertiaryContainer = Color(0xFFFFD8E4),

    error = Color(0xFFFFB4AB),
    onError = Color(0xFF690005),
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6),

    background = Color(0xFF1C1B1F),
    onBackground = Color(0xFFE6E1E5),

    surface = Color(0xFF1C1B1F),
    onSurface = Color(0xFFE6E1E5),
    surfaceVariant = Color(0xFF49454F),
    onSurfaceVariant = Color(0xFFCAC4D0),

    outline = Color(0xFF938F99),
    outlineVariant = Color(0xFF49454F),

    inverseSurface = Color(0xFFE6E1E5),
    inverseOnSurface = Color(0xFF313033),

    scrim = Color(0xFF000000),
)
```

### Extended Colors

Add additional colors beyond the standard Material palette for brand-specific needs.

```kotlin
val BrandBlue = Color(0xFF2196F3)
val BrandGreen = Color(0xFF4CAF50)

@Composable
fun MyApp() {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) DarkColorScheme else LightColorScheme
    ) {
        // Use extended colors
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .background(BrandBlue)
        ) {
            Text("Brand colored surface")
        }
    }
}

// Or create a custom theme object
data class ExtendedColors(
    val brand: Color,
    val success: Color,
    val warning: Color
)

val LocalExtendedColors = staticCompositionLocalOf {
    ExtendedColors(
        brand = Color.Unspecified,
        success = Color.Unspecified,
        warning = Color.Unspecified
    )
}

val AppExtendedColors = ExtendedColors(
    brand = BrandBlue,
    success = BrandGreen,
    warning = Color(0xFFFF9800)
)

@Composable
fun MyExtendedTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    CompositionLocalProvider(
        LocalExtendedColors provides AppExtendedColors
    ) {
        MaterialTheme(colorScheme = colorScheme) {
            content()
        }
    }
}

// Usage
@Composable
fun BrandColoredCard() {
    val extendedColors = LocalExtendedColors.current
    Card(
        colors = CardDefaults.cardColors(
            containerColor = extendedColors.brand
        )
    ) {
        Text("Brand card")
    }
}
```

### Color Usage Best Practices

```kotlin
// Use theme colors for consistency
Surface(
    color = MaterialTheme.colorScheme.surface,
    contentColor = MaterialTheme.colorScheme.onSurface
) {
    Text("Text automatically inherits onSurface color")
}

// Surface variants for subtle differentiation
Surface(
    color = MaterialTheme.colorScheme.surfaceVariant,
    contentColor = MaterialTheme.colorScheme.onSurfaceVariant
) {
    Text("Surface variant")
}

// Container colors for emphasis
Card(
    colors = CardDefaults.cardColors(
        containerColor = MaterialTheme.colorScheme.primaryContainer,
        contentColor = MaterialTheme.colorScheme.onPrimaryContainer
    )
) {
    Text("Primary container")
}

// Error colors for destructive actions
Button(
    colors = ButtonDefaults.buttonColors(
        containerColor = MaterialTheme.colorScheme.error,
        contentColor = MaterialTheme.colorScheme.onError
    )
) {
    Text("Delete")
}

// Tonal elevation for depth
Surface(
    tonalElevation = 2.dp
) {
    Text("Elevated surface")
}

Surface(
    tonalElevation = 8.dp
) {
    Text("More elevated surface")
}
```

## Typography

### Material 3 Type Scale

```kotlin
val AppTypography = Typography(
    // Display styles - largest text on screen
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp,
    ),
    displayMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp,
    ),
    displaySmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp,
    ),

    // Headline styles - high-emphasis text
    headlineLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp,
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp,
    ),
    headlineSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp,
    ),

    // Title styles - shorter, high-emphasis text
    titleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp,
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp,
    ),
    titleSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),

    // Body styles - body text and UI text
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp,
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp,
    ),
    bodySmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W400,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp,
    ),

    // Label styles - smaller text for buttons, labels
    labelLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp,
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontWeight = FontWeight.W500,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp,
    ),
)
```

### Custom Fonts

```kotlin
@Composable
fun AppTheme(content: @Composable () -> Unit) {
    val roboto = FontFamily(
        Font(R.font.roboto_regular, FontWeight.Normal),
        Font(R.font.roboto_medium, FontWeight.Medium),
        Font(R.font.roboto_bold, FontWeight.Bold),
    )

    val typography = Typography(
        displayLarge = TextStyle(
            fontFamily = roboto,
            fontWeight = FontWeight.W400,
            fontSize = 57.sp,
            lineHeight = 64.sp,
            letterSpacing = (-0.25).sp,
        ),
        // ... other styles
    )

    MaterialTheme(typography = typography, content = content)
}

// Or use Google Fonts
@Composable
fun GoogleFontsTheme(content: @Composable () -> Unit) {
    val provider = GoogleFont.Provider(
        providerAuthority = "com.google.android.gms.fonts",
        providerPackage = "com.google.android.gms",
        certificates = R.array.com_google_android_gms_fonts_certs
    )

    val fontName = GoogleFont("Roboto")
    val fontFamily = FontFamily(
        Font(googleFont = fontName, fontProvider = provider)
    )

    val typography = Typography(
        // Use fontFamily
        bodyLarge = TextStyle(
            fontFamily = fontFamily,
            fontWeight = FontWeight.Normal,
            fontSize = 16.sp
        )
        // ...
    )

    MaterialTheme(typography = typography, content = content)
}
```

### Typography Usage

```kotlin
@Composable
fun TypographyExamples() {
    Column(
        modifier = Modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            "Display Large",
            style = MaterialTheme.typography.displayLarge
        )
        Text(
            "Headline Medium",
            style = MaterialTheme.typography.headlineMedium
        )
        Text(
            "Title Large",
            style = MaterialTheme.typography.titleLarge
        )
        Text(
            "Body Large",
            style = MaterialTheme.typography.bodyLarge
        )
        Text(
            "Label Medium",
            style = MaterialTheme.typography.labelMedium
        )

        // Annotated string with multiple styles
        Text(
            buildAnnotatedString {
                withStyle(MaterialTheme.typography.titleLarge.toSpanStyle()) {
                    append("Bold Title\n")
                }
                withStyle(MaterialTheme.typography.bodyMedium.toSpanStyle()) {
                    append("Regular body text")
                }
            }
        )
    }
}
```

## Shape System

### Material 3 Shapes

```kotlin
val AppShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(12.dp),
    large = RoundedCornerShape(16.dp),
    extraLarge = RoundedCornerShape(28.dp)
)

@Composable
fun AppTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        shapes = AppShapes,
        content = content
    )
}
```

### Custom Shapes

```kotlin
// Cut corner shape
val CutCornerShape = CutCornerShape(8.dp)

// Fully rounded shape
val FullyRoundedShape = RoundedCornerShape(50)

// Asymmetric corners
val AsymmetricShape = RoundedCornerShape(
    topStart = 16.dp,
    topEnd = 0.dp,
    bottomStart = 0.dp,
    bottomEnd = 16.dp
)

// Usage
Surface(
    shape = AsymmetricShape,
    tonalElevation = 2.dp
) {
    Text("Asymmetric surface")
}
```

### Shape Usage

```kotlin
// Card shapes
Card(
    shape = MaterialTheme.shapes.medium,
    modifier = Modifier.fillMaxWidth()
) {
    Text("Medium rounded card")
}

// Surface shapes
Surface(
    shape = MaterialTheme.shapes.large,
    tonalElevation = 3.dp
) {
    Text("Large rounded surface")
}

// Button shapes
Button(
    shape = MaterialTheme.shapes.full,
    onClick = { /* ... */ }
) {
    Text("Fully rounded button")
}

// TextField shapes
OutlinedTextField(
    shape = MaterialTheme.shapes.small,
    value = text,
    onValueChange = { text = it }
)

// Custom clip for images
Image(
    painter = painterResource(R.drawable.avatar),
    contentDescription = null,
    modifier = Modifier
        .size(100.dp)
        .clip(CircleShape)
)
```

## Elevation and Shadows

### Tonal Elevation

Material 3 uses tonal elevation instead of shadows for depth.

```kotlin
// Surface tonal elevation
Surface(
    tonalElevation = 1.dp
) {
    Text("Level 1 elevation")
}

Surface(
    tonalElevation = 2.dp
) {
    Text("Level 2 elevation")
}

Surface(
    tonalElevation = 3.dp
) {
    Text("Level 3 elevation")
}

// Component-specific elevation
Card(
    elevation = CardDefaults.cardElevation(
        defaultElevation = 1.dp,
        pressedElevation = 2.dp,
        focusedElevation = 4.dp,
        hoveredElevation = 4.dp,
        draggedElevation = 8.dp
    )
) {
    Text("Card with state-based elevation")
}
```

### Shadow Elevation

For traditional shadows when needed:

```kotlin
Surface(
    modifier = Modifier.shadow(
        elevation = 8.dp,
        shape = MaterialTheme.shapes.medium
    )
) {
    Text("Shadow-based elevation")
}

// Combine tonal and shadow
Surface(
    modifier = Modifier.shadow(
        elevation = 4.dp,
        shape = MaterialTheme.shapes.large
    ),
    tonalElevation = 2.dp,
    shadowElevation = 4.dp
) {
    Text("Both tonal and shadow elevation")
}
```

## Responsive Design

### Window Size Classes

```kotlin
enum class WindowSizeClass { Compact, Medium, Expanded }

@Composable
fun rememberWindowSizeClass(): WindowSizeClass {
    val configuration = LocalConfiguration.current
    val windowMetrics = WindowMetricsCalculator.getOrCreate()
        .computeCurrentWindowMetrics(activity)
    val widthDp = windowMetrics.bounds.width() / configuration.densityDpi

    return when {
        widthDp < 600f -> WindowSizeClass.Compact
        widthDp < 840f -> WindowSizeClass.Medium
        else -> WindowSizeClass.Expanded
    }
}

// Or use experimental API
@OptIn(ExperimentalMaterial3AdaptiveApi::class)
@Composable
fun MyApp() {
    val windowSizeClass = calculateWindowSizeClass(activity)

    when (windowSizeClass.widthSizeClass) {
        WindowWidthSizeClass.Compact -> CompactLayout()
        WindowWidthSizeClass.Medium -> MediumLayout()
        WindowWidthSizeClass.Expanded -> ExpandedLayout()
    }
}
```

### Adaptive Layouts

```kotlin
@Composable
fun AdaptiveLayout() {
    val windowSizeClass = calculateWindowSizeClass(activity)

    if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Compact) {
        // Phone layout
        Scaffold(
            bottomBar = { BottomNavigation() }
        ) { padding ->
            NavHost(Modifier.padding(padding))
        }
    } else {
        // Tablet/desktop layout
        PermanentNavigationDrawer(
            drawerContent = { Drawer() }
        ) { padding ->
            NavHost(Modifier.padding(padding))
        }
    }
}

@Composable
fun AdaptiveDetailScreen() {
    val windowSizeClass = calculateWindowSizeClass(activity)
    val isExpanded = windowSizeClass.widthSizeClass == WindowWidthSizeClass.Expanded

    if (isExpanded) {
        // Master-detail layout
        Row {
            LazyColumn(Modifier.weight(1f)) {
                // List
            }
            VerticalDivider()
            Column(Modifier.weight(2f)) {
                // Detail
            }
        }
    } else {
        // Single pane with navigation
        NavHost()
    }
}
```

### Foldable Support

```kotlin
@OptIn(ExperimentalMaterial3AdaptiveApi::class)
@Composable
fun FoldableLayout() {
    val windowState = rememberWindowState()

    // Check for fold or hinge
    val hasFold = windowState.foldInfo != null

    if (hasFold) {
        val foldInfo = windowState.foldInfo!!
        val isFlat = foldInfo.state == FoldingFeature.State.FLAT

        if (isFlat) {
            // Layout content across both screens
            Row {
                Screen1(Modifier.weight(1f))
                Screen2(Modifier.weight(1f))
            }
        } else {
            // Single screen mode
            SingleScreenContent()
        }
    } else {
        // Regular tablet/phone layout
        RegularLayout()
    }
}
```

## Component Theming

### Button Theming

```kotlin
// Custom button colors
val CustomButtonColors = ButtonDefaults.buttonColors(
    containerColor = MaterialTheme.colorScheme.primary,
    contentColor = MaterialTheme.colorScheme.onPrimary,
    disabledContainerColor = MaterialTheme.colorScheme.onSurface.copy(
        alpha = 0.12f
    ),
    disabledContentColor = MaterialTheme.colorScheme.onSurface.copy(
        alpha = 0.38f
    )
)

Button(
    colors = CustomButtonColors,
    onClick = { /* ... */ }
) {
    Text("Custom button")
}
```

### Card Theming

```kotlin
val CustomCardColors = CardDefaults.cardColors(
    containerColor = MaterialTheme.colorScheme.surface,
    contentColor = MaterialTheme.colorScheme.onSurface,
    disabledContainerColor = MaterialTheme.colorScheme.onSurface.copy(
        alpha = 0.12f
    ),
    disabledContentColor = MaterialTheme.colorScheme.onSurface.copy(
        alpha = 0.38f
    )
)

Card(
    colors = CustomCardColors,
    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
) {
    Text("Custom card")
}
```

### Icon Theming

```kotlin
@Composable
fun ThemedIcon() {
    Icon(
        Icons.Default.Favorite,
        contentDescription = null,
        tint = MaterialTheme.colorScheme.primary
    )
}

// Tinted image icon
Icon(
    painter = painterResource(R.drawable.custom_icon),
    contentDescription = null,
    tint = MaterialTheme.colorScheme.secondary
)

// Untinted icon
Icon(
    painter = painterResource(R.drawable.colored_icon),
    contentDescription = null,
    tint = Color.Unspecified
)
```

## Theme Composition

```kotlin
@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context)
            else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    CompositionLocalProvider(
        LocalExtendedColors provides AppExtendedColors
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = AppTypography,
            shapes = AppShapes,
            content = content
        )
    }
}

// Usage in Application
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Set default night mode
        AppCompat.setDefaultNightMode(AppCompat.MODE_NIGHT_FOLLOW_SYSTEM)
    }
}

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            AppTheme {
                MyAppNavHost()
            }
        }
    }
}
```

## Best Practices

1. **Always use theme colors** instead of hardcoded colors for consistency
2. **Support both light and dark themes** for accessibility and user preference
3. **Use dynamic color** when possible to personalize the app experience
4. **Follow the Material 3 type scale** for consistent typography
5. **Use tonal elevation** for depth instead of shadows in most cases
6. **Make your app responsive** to different screen sizes using window size classes
7. **Test color contrast** to ensure WCAG AA compliance
8. **Provide custom colors** only when dynamic color isn't available
