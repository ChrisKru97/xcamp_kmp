# SQLDelight Schema Reference

## Data Types

SQLDelight maps SQLite types to Kotlin types based on column definitions. Here are the most common types:

### Primitive Types

| SQLite Type | Kotlin Type | Example Usage |
|-------------|-------------|---------------|
| `TEXT` | `String` | Names, descriptions, IDs |
| `INTEGER` | `Long` | IDs, timestamps, counters |
| `REAL` | `Double` | Decimals, coordinates |
| `BLOB` | `ByteArray` | Binary data, images |

### Boolean Values

SQLite doesn't have a native boolean type. Use `INTEGER` with 0 or 1:

```sql
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY,
  isActive INTEGER NOT NULL DEFAULT 1  -- 1 = true, 0 = false
);
```

### Date/Time Values

Store timestamps as `INTEGER` (milliseconds since epoch):

```sql
CREATE TABLE Event (
  id TEXT NOT NULL PRIMARY KEY,
  startTime INTEGER NOT NULL,  -- epoch millis
  endTime INTEGER NOT NULL      -- epoch millis
);
```

### UUID for Primary Keys

Use `TEXT` for UUIDs to ensure cross-platform compatibility:

```sql
CREATE TABLE Entity (
  id TEXT NOT NULL PRIMARY KEY,  -- UUID as string
  name TEXT NOT NULL
);
```

## Table Definitions

### Basic Table

```sql
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  age INTEGER,
  createdAt INTEGER NOT NULL
);
```

### Table with Default Values

```sql
CREATE TABLE Task (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  priority INTEGER NOT NULL DEFAULT 0,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
);
```

### Table with Foreign Key

```sql
CREATE TABLE Author (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE Book (
  id TEXT NOT NULL PRIMARY KEY,
  title TEXT NOT NULL,
  authorId TEXT NOT NULL,
  FOREIGN KEY (authorId) REFERENCES Author(id) ON DELETE CASCADE
);
```

### Composite Primary Key

```sql
CREATE TABLE TeamMember (
  teamId TEXT NOT NULL,
  userId TEXT NOT NULL,
  role TEXT NOT NULL,
  PRIMARY KEY (teamId, userId)
);
```

## Constraints

### Primary Key

```sql
-- Single column
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY
);

-- Named primary key
CREATE TABLE User (
  id TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (id)
);

-- Composite primary key
CREATE TABLE UserSetting (
  userId TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  PRIMARY KEY (userId, key)
);
```

### Foreign Key

```sql
CREATE TABLE Order (
  id TEXT NOT NULL PRIMARY KEY,
  userId TEXT NOT NULL,
  total REAL NOT NULL,
  FOREIGN KEY (userId) REFERENCES User(id)
    ON DELETE CASCADE      -- Delete orders when user is deleted
    ON UPDATE CASCADE      -- Update userId when user.id changes
);

-- Multiple foreign keys
CREATE TABLE OrderItem (
  id TEXT NOT NULL PRIMARY KEY,
  orderId TEXT NOT NULL,
  productId TEXT NOT NULL,
  FOREIGN KEY (orderId) REFERENCES Order(id) ON DELETE CASCADE,
  FOREIGN KEY (productId) REFERENCES Product(id) ON DELETE RESTRICT
);
```

### Unique Constraint

```sql
-- Column-level
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE
);

-- Table-level (named)
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY,
  email TEXT NOT NULL,
  username TEXT NOT NULL,
  CONSTRAINT unique_email UNIQUE (email)
);

-- Composite unique
CREATE TABLE UserLogin (
  userId TEXT NOT NULL,
  provider TEXT NOT NULL,
  providerId TEXT NOT NULL,
  PRIMARY KEY (userId, provider),
  CONSTRAINT unique_provider_login UNIQUE (provider, providerId)
);
```

### Check Constraint

```sql
CREATE TABLE Product (
  id TEXT NOT NULL PRIMARY KEY,
  price REAL NOT NULL,
  quantity INTEGER NOT NULL,
  CHECK (price >= 0),
  CHECK (quantity >= 0)
);

-- Named check constraint
CREATE TABLE Event (
  id TEXT NOT NULL PRIMARY KEY,
  startTime INTEGER NOT NULL,
  endTime INTEGER NOT NULL,
  CONSTRAINT valid_time_range CHECK (endTime > startTime)
);

-- Enum-like check
CREATE TABLE Task (
  id TEXT NOT NULL PRIMARY KEY,
  status TEXT NOT NULL,
  CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled'))
);
```

### Not Null Constraint

```sql
CREATE TABLE User (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,           -- Required
  email TEXT,                   -- Optional (nullable)
  bio TEXT                      -- Optional (nullable)
);
```

## Indexes

### Single Column Index

```sql
-- Basic index
CREATE INDEX user_email_idx ON User(email);

-- Unique index
CREATE UNIQUE INDEX user_username_idx ON User(username);

-- Descending index
CREATE INDEX user_created_idx ON User(createdAt DESC);
```

### Composite Index

```sql
-- Multiple columns
CREATE INDEX user_status_created_idx ON User(status, createdAt DESC);

-- Covering index (includes additional columns)
CREATE INDEX user_name_email_idx ON User(name, email);
```

### Partial Index (WHERE clause)

```sql
-- Index only active users
CREATE INDEX user_active_idx ON User(email)
WHERE isActive = 1;

-- Index pending orders
CREATE INDEX order_pending_idx ON Order(userId, createdAt)
WHERE status = 'pending';
```

### Unique Index

```sql
-- Ensure uniqueness across nullable columns
CREATE UNIQUE INDEX user_email_unique_idx ON User(email)
WHERE email IS NOT NULL;
```

### Index on Foreign Keys

```sql
-- Always index foreign keys for JOIN performance
CREATE INDEX book_author_idx ON Book(authorId);
CREATE INDEX order_user_idx ON Order(userId);
```

## Import Types

SQLDelight supports importing Kotlin types for custom column types:

```sql
-- At the top of your .sq file
import com.example.Uuid;
import com.example.Instant;
import com.example.BigDecimal;

CREATE TABLE Transaction (
  id Uuid NOT NULL PRIMARY KEY,
  amount BigDecimal NOT NULL,
  createdAt Instant NOT NULL
);
```

## Type Adapters

For custom Kotlin types that don't map directly to SQLite types, use column adapters:

```kotlin
// Define your Kotlin data class
@Parcelize
data class Uuid(val value: String) : Parcelable

// Create a column adapter
val UuidAdapter = ColumnAdapter(
  encode = { uuid: Uuid -> uuid.value },
  decode = { value: String -> Uuid(value) }
)

// Register with the database
val database = Database(
  driver = driver,
  UserAdapter = UuidAdapter
)
```

### Common Type Adapters

```kotlin
// UUID as string
val UuidAdapter = ColumnAdapter<String, UUID>(
  encode = { UUID.randomUUID().toString() },
  decode = { UUID.fromString(it) }
)

// Instant (epoch millis)
val InstantAdapter = ColumnAdapter<Long, Instant>(
  encode = { it.toEpochMilliseconds() },
  decode = { Instant.fromEpochMilliseconds(it) }
)

// Enum as string
val StatusAdapter = ColumnAdapter<String, Status>(
  encode = { it.name },
  decode = { Status.valueOf(it) }
)

// JSON string to object
val JsonAdapter = ColumnAdapter<String, MyData>(
  encode = { Json.encodeToString(it) },
  decode = { Json.decodeFromString(it) }
)
```

### Using Type Adapters with SQLDelight

```sql
-- With adapter, you can use custom types directly
import java.util.UUID;
import java.time.Instant;
import com.example.Status;

CREATE TABLE User (
  id UUID NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  status Status NOT NULL,
  createdAt Instant NOT NULL
);
```

## Schema Best Practices

| Practice | Recommendation |
|----------|----------------|
| Primary Keys | Use TEXT UUIDs for cross-platform compatibility |
| Timestamps | Store as INTEGER (epoch millis) not TEXT |
| Booleans | Use INTEGER (0/1), not BOOLEAN |
| Foreign Keys | Always index for JOIN performance |
| Nullable | Use sparingly - prefer NOT NULL with defaults |
| Constraints | Define at table creation for compile-time verification |
| Indexes | Add after tables in schema file |
| Composite Keys | Use for many-to-many relationships |
| Enums | Use TEXT with CHECK constraint for type safety |
