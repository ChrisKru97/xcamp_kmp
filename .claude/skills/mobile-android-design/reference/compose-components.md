# Jetpack Compose Components

Comprehensive guide for Material 3 and common Jetpack Compose UI components.

## Lists and Collections

### LazyColumn (Vertical List)

```kotlin
LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(16.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    items(count = items.size) { index ->
        ListItem(
            headlineContent = { Text(items[index].title) },
            supportingContent = { Text(items[index].subtitle) },
            leadingContent = {
                Icon(Icons.Default.Star, contentDescription = null)
            },
            modifier = Modifier.clickable {
                onItemClick(items[index])
            }
        )
    }
}
```

### LazyRow (Horizontal List)

```kotlin
LazyRow(
    modifier = Modifier.fillMaxWidth(),
    horizontalArrangement = Arrangement.spacedBy(8.dp),
    contentPadding = PaddingValues(horizontal = 16.dp)
) {
    items(items) { item ->
        Card(modifier = Modifier.width(200.dp)) {
            Column(Modifier.padding(16.dp)) {
                Text(item.title)
                Text(item.subtitle)
            }
        }
    }
}
```

### LazyVerticalGrid (Grid Layout)

```kotlin
LazyVerticalGrid(
    columns = GridCells.Adaptive(minSize = 150.dp),
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(16.dp),
    horizontalArrangement = Arrangement.spacedBy(8.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    items(items) { item ->
        Card {
            Column(Modifier.padding(16.dp)) {
                Text(item.title)
                Text(item.subtitle)
            }
        }
    }
}

// Fixed number of columns
LazyVerticalGrid(
    columns = GridCells.Fixed(2)
) { /* ... */ }
```

### Pull to Refresh

```kotlin
val isRefreshing by viewModel.isRefreshing.collectAsState()

Box(Modifier.pullRefresh(pullRefreshState)) {
    LazyColumn { /* ... */ }

    PullRefreshIndicator(
        refreshing = isRefreshing,
        state = pullRefreshState,
        modifier = Modifier.align(Alignment.TopCenter)
    )
}

// In ViewModel
class MyViewModel : ViewModel() {
    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing.asStateFlow()

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            // Fetch data
            _isRefreshing.value = false
        }
    }
}
```

### Swipe to Dismiss

```kotlin
val dismissState = rememberDismissState(
    confirmValueChange = {
        if (it == DismissValue.DismissedToStart) {
            onSwipe(item)
            true
        } else {
            false
        }
    }
)

SwipeToDismiss(
    state = dismissState,
    background = {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(MaterialTheme.colorScheme.error)
                .padding(horizontal = 20.dp),
            contentAlignment = Alignment.CenterEnd
        ) {
            Icon(
                Icons.Default.Delete,
                contentDescription = "Delete",
                tint = MaterialTheme.colorScheme.onError
            )
        }
    },
    dismissContent = {
        ListItem(
            headlineContent = { Text(item.title) },
            supportingContent = { Text(item.subtitle) }
        )
    },
    directions = setOf(DismissDirection.EndToStart)
)
```

### Sticky Headers

```kotlin
LazyColumn {
    items(groupedItems.size) { groupIndex ->
        val group = groupedItems[groupIndex]

        stickyHeader {
            Surface(
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 2.dp
            ) {
                Text(
                    group.name,
                    modifier = Modifier.padding(16.dp),
                    style = MaterialTheme.typography.titleMedium
                )
            }
        }

        items(group.items) { item ->
            ListItem(headlineContent = { Text(item.title) })
        }
    }
}
```

### Lazy Paging (Paging Library)

```kotlin
// Flow-based paging
val lazyPagingItems = viewModel.items.collectAsLazyPagingItems()

LazyColumn {
    items(
        count = lazyPagingItems.itemCount,
        key = lazyPagingItems.itemKey { it.id }
    ) { index ->
        val item = lazyPagingItems[index]
        if (item != null) {
            ListItem(headlineContent = { Text(item.title) })
        }
    }

    lazyPagingItems.apply {
        when {
            loadState.refresh is LoadState.Loading -> {
                item { CircularProgressIndicator() }
            }
            loadState.append is LoadState.Loading -> {
                item { CircularProgressIndicator() }
            }
        }
    }
}
```

## Forms and Input

### Text Field Variants

```kotlin
// Outlined text field
OutlinedTextField(
    value = text,
    onValueChange = { text = it },
    label = { Text("Email") },
    leadingIcon = {
        Icon(Icons.Default.Email, contentDescription = null)
    },
    trailingIcon = {
        if (text.isNotEmpty()) {
            IconButton(onClick = { text = "" }) {
                Icon(Icons.Default.Clear, contentDescription = "Clear")
            }
        }
    },
    supportingText = { Text("We'll never share your email") },
    isError = hasError,
    singleLine = true,
    keyboardOptions = KeyboardOptions(
        keyboardType = KeyboardType.Email,
        imeAction = ImeAction.Next
    )
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
    ),
    keyboardActions = KeyboardActions(
        onDone = { /* Handle submit */ }
    )
)

// Outlined text area
OutlinedTextField(
    value = description,
    onValueChange = { description = it },
    label = { Text("Description") },
    minLines = 3,
    maxLines = 5,
    modifier = Modifier.fillMaxWidth()
)
```

### Search Bar

```kotlin
var query by remember { mutableStateOf("") }
var active by remember { mutableStateOf(false) }

SearchBar(
    query = query,
    onQueryChange = { query = it },
    onSearch = {
        active = false
        viewModel.search(query)
    },
    active = active,
    onActiveChange = { active = it },
    placeholder = { Text("Search...") },
    leadingIcon = {
        Icon(Icons.Default.Search, contentDescription = null)
    },
    trailingIcon = {
        if (query.isNotEmpty()) {
            IconButton(onClick = { query = "" }) {
                Icon(Icons.Default.Clear, contentDescription = "Clear")
            }
        }
    }
) {
    // Search history/suggestions
    suggestions.forEach { suggestion ->
        ListItem(
            headlineContent = { Text(suggestion) },
            leadingIcon = {
                Icon(Icons.Default.History, contentDescription = null)
            },
            modifier = Modifier.clickable {
                query = suggestion
                active = false
                viewModel.search(suggestion)
            }
        )
    }
}
```

### Selection Controls

```kotlin
// Checkbox
Row(
    verticalAlignment = Alignment.CenterVertically
) {
    Checkbox(
        checked = checked,
        onCheckedChange = { checked = it }
    )
    Spacer(Modifier.size(8.dp))
    Text("Accept terms and conditions")
}

// Tri-state checkbox
@Composable
fun TriStateCheckbox(
    state: ToggleableState,
    onClick: () -> Unit
) {
    Checkbox(
        checked = state == ToggleableState.On,
        onCheckedChange = { onClick() },
        enabled = true
    )
}

// Switch
Row(
    verticalAlignment = Alignment.CenterVertically
) {
    Text("Enable notifications")
    Spacer(Modifier.weight(1f))
    Switch(
        checked = enabled,
        onCheckedChange = { enabled = it }
    )
}

// Radio buttons
Column {
    options.forEach { option ->
        Row(
            Modifier.clickable { selectedOption = option },
            verticalAlignment = Alignment.CenterVertically
        ) {
            RadioButton(
                selected = selectedOption == option,
                onClick = { selectedOption = option }
            )
            Spacer(Modifier.size(8.dp))
            Text(option.label)
        }
    }
}
```

### Slider

```kotlin
var sliderPosition by remember { mutableStateOf(0f) }

Column(Modifier.padding(16.dp)) {
    Text("Value: ${sliderPosition.toInt()}")
    Slider(
        value = sliderPosition,
        onValueChange = { sliderPosition = it },
        valueRange = 0f..100f,
        steps = 10,
        modifier = Modifier.fillMaxWidth()
    )
}

// Range slider
var rangeStart by remember { mutableStateOf(0f) }
var rangeEnd by remember { mutableStateOf(100f) }

RangeSlider(
    value = rangeStart..rangeEnd,
    onValueChange = { range ->
        rangeStart = range.start
        rangeEnd = range.endInclusive
    },
    valueRange = 0f..100f,
    modifier = Modifier.fillMaxWidth()
)
```

## Dialogs and Bottom Sheets

### AlertDialog

```kotlin
var showDialog by remember { mutableStateOf(false) }

if (showDialog) {
    AlertDialog(
        onDismissRequest = { showDialog = false },
        icon = {
            Icon(Icons.Default.Warning, contentDescription = null)
        },
        title = {
            Text("Delete Item")
        },
        text = {
            Text("This action cannot be undone. Are you sure?")
        },
        confirmButton = {
            TextButton(
                onClick = {
                    showDialog = false
                    onDelete()
                }
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

### Custom Dialog

```kotlin
if (showDialog) {
    Dialog(onDismissRequest = { showDialog = false }) {
        Surface(
            shape = MaterialTheme.shapes.large,
            tonalElevation = 6.dp
        ) {
            Column(
                Modifier
                    .padding(24.dp)
                    .fillMaxWidth()
            ) {
                Text(
                    "Custom Dialog",
                    style = MaterialTheme.typography.titleLarge
                )
                Spacer(Modifier.size(16.dp))
                Text("Dialog content goes here...")
                Spacer(Modifier.size(24.dp))
                Row(
                    horizontalArrangement = Arrangement.End,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    TextButton(onClick = { showDialog = false }) {
                        Text("Cancel")
                    }
                    Button(onClick = { onConfirm(); showDialog = false }) {
                        Text("Confirm")
                    }
                }
            }
        }
    }
}
```

### Bottom Sheet

```kotlin
val sheetState = rememberModalBottomSheetState()
var showSheet by remember { mutableStateOf(false) }

if (showSheet) {
    ModalBottomSheet(
        onDismissRequest = { showSheet = false },
        sheetState = sheetState,
        windowInsets = WindowInsets(0)
    ) {
        Column(
            Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                "Sheet Title",
                style = MaterialTheme.typography.titleLarge
            )
            Divider()
            // Sheet content
            SheetOptions.forEach { option ->
                ListItem(
                    headlineContent = { Text(option.label) },
                    leadingContent = {
                        Icon(option.icon, contentDescription = null)
                    },
                    modifier = Modifier.clickable {
                        onOptionSelected(option)
                        showSheet = false
                    }
                )
            }
        }
    }
}

// Standard bottom sheet (non-modal)
val sheetState = rememberBottomSheetScaffoldState()

BottomSheetScaffold(
    scaffoldState = sheetState,
    sheetContent = {
        Column(Modifier.padding(16.dp)) {
            Text("Sheet content")
        }
    },
    sheetPeekHeight = 64.dp
) { padding ->
    Box(Modifier.padding(padding)) {
        Text("Main content")
    }
}
```

## Date and Time Pickers

### Date Picker (Material 3)

```kotlin
val datePickerState = rememberDatePickerState()

DatePickerDialog(
    onDateSelected = { millis ->
        onDateSelected(millis)
        showDatePicker = false
    },
    onDismiss = { showDatePicker = false }
) {
    DatePicker(state = datePickerState)
}

// Get selected date
datePickerState.selectedDateMillis?.let { millis ->
    val date = Instant.fromEpochMilliseconds(millis)
        .toLocalDateTime(TimeZone.currentSystemDefault())
    Text("Selected: ${date.date}")
}
```

### Time Picker

```kotlin
@OptIn(ExperimentalMaterial3Api::class)
val timePickerState = rememberTimePickerState(
    initialHour = 12,
    initialMinute = 0,
    is24Hour = true
)

TimePickerDialog(
    onTimeSelected = {
        onTimeSelected(timePickerState.hour, timePickerState.minute)
        showTimePicker = false
    },
    onDismiss = { showTimePicker = false }
) {
    TimePicker(state = timePickerState)
}
```

## Loading States

### Progress Indicator

```kotlin
// Circular indeterminate
Box(
    Modifier.fillMaxSize(),
    contentAlignment = Alignment.Center
) {
    CircularProgressIndicator()
}

// Linear indeterminate
LinearProgressIndicator(
    modifier = Modifier.fillMaxWidth()
)

// Determinate circular
CircularProgressIndicator(
    progress = { progress / 100f },
    modifier = Modifier.size(48.dp)
)

// Determinate linear
LinearProgressIndicator(
    progress = { progress / 100f },
    modifier = Modifier.fillMaxWidth()
)
```

### Skeleton Loading

```kotlin
@Composable
fun SkeletonListItem() {
    ListItem(
        headlineContent = {
            Box(
                Modifier
                    .fillMaxWidth(0.7f)
                    .height(24.dp)
                    .background(
                        MaterialTheme.colorScheme.surfaceVariant,
                        CircleShape
                    )
            )
        },
        supportingContent = {
            Box(
                Modifier
                    .fillMaxWidth(0.4f)
                    .height(16.dp)
                    .background(
                        MaterialTheme.colorScheme.surfaceVariant,
                        CircleShape
                    )
            )
        },
        leadingContent = {
            Box(
                Modifier
                    .size(40.dp)
                    .background(
                        MaterialTheme.colorScheme.surfaceVariant,
                        CircleShape
                    )
            )
        }
    )
}
```

### Async Content Pattern

```kotlin
@Composable
fun AsyncContentScreen(
    viewModel: MyViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    when (uiState) {
        is UiState.Loading -> {
            Box(
                Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        }
        is UiState.Success -> {
            val data = (uiState as UiState.Success).data
            LazyColumn {
                items(data) { item ->
                    ListItem(headlineContent = { Text(item.title) })
                }
            }
        }
        is UiState.Error -> {
            val error = (uiState as UiState.Error).message
            Box(
                Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        "Error loading data",
                        style = MaterialTheme.typography.titleLarge
                    )
                    Text(error)
                    Button(onClick = { viewModel.retry() }) {
                        Text("Retry")
                    }
                }
            }
        }
    }
}
```

## Animations

### Animated Visibility

```kotlin
var visible by remember { mutableStateOf(true) }

AnimatedVisibility(
    visible = visible,
    enter = fadeIn() + expandVertically(),
    exit = fadeOut() + shrinkVertically()
) {
    Box(
        Modifier
            .fillMaxWidth()
            .height(200.dp)
            .background(MaterialTheme.colorScheme.primary)
    )
}

// Animate size changes
AnimatedContent(
    targetState = expanded,
    transitionSpec = {
        fadeIn(animationSpec = tween(300)) togetherWith
        fadeOut(animationSpec = tween(300))
    },
    label = "size_animation"
) { isExpanded ->
    if (isExpanded) {
        ExpandedContent()
    } else {
        CollapsedContent()
    }
}
```

### Animate State Changes

```kotlin
var size by remember { mutableStateOf(100.dp) }

Box(
    Modifier
        .size(size)
        .background(MaterialTheme.colorScheme.primary)
        .clickable {
            size = if (size == 100.dp) 200.dp else 100.dp
        }
        .animateContentSize(
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioMediumBouncy,
                stiffness = Spring.StiffnessLow
            )
        )
)
```

### Gesture Animations

```kotlin
val offsetX by remember { mutableStateOf(0f) }
val animOffsetX by animateDpAsState(
    targetValue = offsetX.dp,
    animationSpec = spring(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow
    ),
    label = "offset"
)

Box(
    Modifier
        .offset(x = animOffsetX)
        .size(100.dp)
        .background(MaterialTheme.colorScheme.primary)
        .pointerInput(Unit) {
            detectDragGestures { change, dragAmount ->
                change.consume()
                offsetX += dragAmount.x
            }
        }
)
```

### Crossfade Animation

```kotlin
var currentTab by remember { mutableStateOf(0) }

Crossfade(
    targetState = currentTab,
    animationSpec = tween(durationMillis = 300),
    label = "tab_switch"
) { tab ->
    when (tab) {
        0 -> Tab1Content()
        1 -> Tab2Content()
        2 -> Tab3Content()
    }
}
```

### Infinite Animation

```kotlin
val infiniteTransition = rememberInfiniteTransition(label = "rotation")
val rotation by infiniteTransition.animateFloat(
    initialValue = 0f,
    targetValue = 360f,
    animationSpec = infiniteRepeatable(
        animation = tween(1000, easing = LinearEasing),
        repeatMode = RepeatMode.Restart
    ),
    label = "rotation"
)

Icon(
    Icons.Default.Refresh,
    contentDescription = null,
    modifier = Modifier
        .size(48.dp)
        .graphicsLayer { rotationZ = rotation }
)
```

## Scaffold Layouts

### Basic Scaffold

```kotlin
val snackbarHostState = remember { SnackbarHostState() }
val scope = rememberCoroutineScope()

Scaffold(
    topBar = {
        SmallTopAppBar(
            title = { Text("My App") }
        )
    },
    bottomBar = {
        NavigationBar {
            // Bottom nav items
        }
    },
    floatingActionButton = {
        FloatingActionButton(
            onClick = { /* Handle FAB click */ }
        ) {
            Icon(Icons.Default.Add, contentDescription = null)
        }
    },
    snackbarHost = { SnackbarHost(snackbarHostState) }
) { padding ->
    LazyColumn(
        modifier = Modifier.padding(padding)
    ) {
        // Content
    }
}
```

### Large Top App Bar Layout

```kotlin
val scrollBehavior = TopAppBarDefaults.enterAlwaysScrollBehavior()

Scaffold(
    modifier = Modifier.nestedScroll(scrollBehavior.nestedScrollConnection),
    topBar = {
        LargeTopAppBar(
            title = { Text("Large Top App Bar") },
            scrollBehavior = scrollBehavior
        )
    }
) { padding ->
    LazyColumn(
        modifier = Modifier.padding(padding)
    ) {
        // Scrollable content
    }
}
```

### Navigation Drawer Layout

```kotlin
val drawerState = rememberDrawerState(DrawerValue.Closed)

ModalNavigationDrawer(
    drawerState = drawerState,
    drawerContent = {
        ModalDrawerSheet {
            Text("Drawer Title")
            Divider()
            // Drawer items
        }
    }
) {
    Scaffold(
        topBar = {
            SmallTopAppBar(
                title = { Text("My App") },
                navigationIcon = {
                    IconButton(
                        onClick = {
                            scope.launch {
                                drawerState.open()
                            }
                        }
                    ) {
                        Icon(Icons.Default.Menu, contentDescription = null)
                    }
                }
            )
        }
    ) { padding ->
        // Content
    }
}
```
