# SQLDelight Migrations Reference

## Migration Files Structure

SQLDelight migrations are defined in `.sqm` files located in the `migrations/` directory:

```
shared/src/commonMain/sqldelight/
└── com/example/database/
    ├── User.sq
    ├── Book.sq
    └── migrations/
        ├── 1.sqm    -- Migration from version 1 to 2
        ├── 2.sqm    -- Migration from version 2 to 3
        └── 3.sqm    -- Migration from version 3 to 4
```

Each migration file contains SQL statements that transform the database from one schema version to the next.

## Migration File Format

```sql
-- 1.sqm
-- Migrate from version 1 to version 2

-- Add new column
ALTER TABLE User ADD COLUMN age INTEGER;

-- Create new table
CREATE TABLE Profile (
  userId TEXT NOT NULL PRIMARY KEY,
  bio TEXT,
  FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
);

-- Create index
CREATE INDEX profile_user_idx ON Profile(userId);
```

## Common Migration Operations

### Add Column

```sql
-- Add nullable column
ALTER TABLE User ADD COLUMN bio TEXT;

-- Add column with default value
ALTER TABLE User ADD COLUMN isActive INTEGER NOT NULL DEFAULT 1;

-- Add column with default value (using expression)
ALTER TABLE User ADD COLUMN createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000);
```

### Add Table

```sql
-- New table with foreign key
CREATE TABLE Address (
  id TEXT NOT NULL PRIMARY KEY,
  userId TEXT NOT NULL,
  street TEXT NOT NULL,
  city TEXT NOT NULL,
  FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX address_user_idx ON Address(userId);
CREATE INDEX address_city_idx ON Address(city);
```

### Add Index

```sql
-- Single column index
CREATE INDEX user_email_idx ON User(email);

-- Composite index
CREATE INDEX user_status_created_idx ON User(status, createdAt DESC);

-- Unique index
CREATE UNIQUE INDEX user_username_idx ON User(username);

-- Partial index
CREATE INDEX user_active_idx ON User(email)
WHERE isActive = 1;
```

### Rename Column

SQLite has limited `ALTER TABLE` support. To rename a column:

```sql
-- 1. Create new table with renamed column
CREATE TABLE User_new (
  id TEXT NOT NULL PRIMARY KEY,
  fullName TEXT NOT NULL,  -- renamed from 'name'
  email TEXT NOT NULL
);

-- 2. Copy data
INSERT INTO User_new (id, fullName, email)
SELECT id, name, email FROM User;

-- 3. Drop old table
DROP TABLE User;

-- 4. Rename new table
ALTER TABLE User_new RENAME TO User;

-- 5. Recreate indexes
CREATE INDEX user_email_idx ON User(email);
```

### Rename Table

```sql
-- Simple rename
ALTER TABLE OldTableName RENAME TO NewTableName;
```

### Drop Column

SQLite doesn't support `DROP COLUMN` directly. Use the same pattern as rename:

```sql
-- 1. Create new table without the column
CREATE TABLE User_new (
  id TEXT NOT NULL PRIMARY KEY,
  email TEXT NOT NULL
  -- 'bio' column removed
);

-- 2. Copy data
INSERT INTO User_new (id, email)
SELECT id, email FROM User;

-- 3. Drop old table
DROP TABLE User;

-- 4. Rename new table
ALTER TABLE User_new RENAME TO User;

-- 5. Recreate indexes
CREATE INDEX user_email_idx ON User(email);
```

### Drop Table

```sql
-- Drop table
DROP TABLE OldTable;
```

### Drop Index

```sql
-- Drop index
DROP INDEX IF EXISTS old_index_name;
```

### Change Column Type

```sql
-- Change TEXT to INTEGER (example: status to enum code)
-- 1. Create new table with changed type
CREATE TABLE User_new (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  status INTEGER NOT NULL DEFAULT 0  -- was TEXT
);

-- 2. Copy data with transformation
INSERT INTO User_new (id, name, status)
SELECT id, name,
  CASE status
    WHEN 'active' THEN 1
    WHEN 'inactive' THEN 0
    ELSE 0
  END
FROM User;

-- 3. Drop old table
DROP TABLE User;

-- 4. Rename new table
ALTER TABLE User_new RENAME TO User;

-- 5. Recreate indexes
CREATE INDEX user_status_idx ON User(status);
```

## Migration Strategies

### Data Transformation

When migrating, you may need to transform data:

```sql
-- Add computed column based on existing data
ALTER TABLE Order ADD COLUMN total REAL;

-- Populate with calculated values
UPDATE Order
SET total = (subtotal + tax - discount);

-- Add status column with default based on existing data
ALTER TABLE Task ADD COLUMN status TEXT DEFAULT 'pending';

-- Set status based on completion flag
UPDATE Task
SET status = CASE
  WHEN isCompleted = 1 THEN 'completed'
  ELSE 'pending'
END;
```

### Complex Schema Changes

For major schema changes, consider using a temporary table approach:

```sql
-- 1. Create temporary table with new schema
CREATE TABLE User_temp (
  id TEXT NOT NULL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  displayName TEXT NOT NULL,
  createdAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
  updatedAt INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000)
);

-- 2. Migrate data with transformations
INSERT INTO User_temp (id, email, displayName, createdAt)
SELECT
  id,
  email,
  COALESCE(displayName, username) AS displayName,  -- Fallback to username
  createdAt
FROM User;

-- 3. Drop old table
DROP TABLE User;

-- 4. Rename temporary table
ALTER TABLE User_temp RENAME TO User;

-- 5. Recreate indexes
CREATE UNIQUE INDEX user_email_idx ON User(email);
CREATE INDEX user_created_idx ON User(createdAt DESC);
```

### Foreign Key Migration

When adding foreign keys to existing tables:

```sql
-- 1. Add column (nullable first to avoid constraint violations)
ALTER TABLE Order ADD COLUMN userId TEXT;

-- 2. Populate with existing data if available
UPDATE Order
SET userId = (SELECT userId FROM OldOrderMapping WHERE orderId = Order.id);

-- 3. Make column NOT NULL (requires table recreate)
-- (Use table recreate pattern from above)

-- 4. Add foreign key constraint (requires table recreate)
-- (Include FK in CREATE TABLE statement)
```

## Testing Migrations

### Unit Testing

Test migrations by verifying the schema and data integrity:

```kotlin
@Test
fun testMigration1to2() = runTest {
  // Create database at version 1
  val driverV1 = SqlDriver(
    schema = AppDatabase.Schema,
    name = "test.db",
    version = 1
  )

  // Insert test data
  val dbV1 = AppDatabase(driverV1)
  dbV1.userQueries.insert(
    id = "1",
    name = "John Doe",
    email = "john@example.com"
  )

  // Close and migrate to version 2
  driverV1.close()

  val driverV2 = SqlDriver(
    schema = AppDatabase.Schema,
    name = "test.db",
    version = 2
  )

  // Verify schema
  val cursor = driverV2.executeQuery(null, "PRAGMA table_info(User)", { cursor ->
    // Verify new column exists
  })

  // Verify data integrity
  val dbV2 = AppDatabase(driverV2)
  val users = dbV2.userQueries.selectAll().executeAsList()
  assertEquals(1, users.size)
  assertEquals("John Doe", users[0].name)
}
```

### Migration Verification

Use SQLite's built-in tools to verify migrations:

```sql
-- Check current schema version
PRAGMA user_version;

-- Get table schema
PRAGMA table_info(User);

-- Get index information
PRAGMA index_list(User);
PRAGMA index_info(user_email_idx);

-- Get foreign key information
PRAGMA foreign_key_list(Order);

-- Verify database integrity
PRAGMA integrity_check;
```

## SQLite Version Compatibility

SQLDelight generates SQLite code that targets specific SQLite versions. Be aware of:

### SQLite Features by Version

| Feature | SQLite Version | Notes |
|---------|---------------|-------|
| Basic SQL | All | Core SQLite features |
| Generated Columns | 3.31+ | Computed column values |
| UPSERT (`ON CONFLICT`) | 3.24+ | Insert or update on conflict |
| Window Functions | 3.25+ | Analytic functions |
| CTE (`WITH` clauses) | 3.8.3+ | Common table expressions |
| Partial Indexes | 3.8.0+ | Indexes with WHERE clause |

### Platform-Specific SQLite Versions

| Platform | SQLite Version | Minimum SDK |
|----------|---------------|-------------|
| Android | 3.22.0 (API 22) | API 21 |
| Android | 3.32.2 (API 30) | API 30 |
| iOS (SQLCipher) | 3.35+ | iOS 9+ |
| JVM (sqlite-jdbc) | 3.36+ | N/A |

### Cross-Platform Best Practices

For maximum compatibility across all platforms:

1. **Avoid** generated columns and computed values
2. **Use** `INSERT OR REPLACE` instead of UPSERT if targeting older versions
3. **Test** on minimum supported platform versions
4. **Use** standard SQL syntax supported by SQLite 3.22+

## Migration Best Practices

| Practice | Recommendation |
|----------|----------------|
| Version numbering | Increment sequentially (1, 2, 3...) |
| File naming | Use sequential numbers (1.sqm, 2.sqm) |
| Backward compatibility | Ensure migrations can be rolled back |
| Data preservation | Always preserve existing data |
| Testing | Test each migration in isolation |
| Foreign keys | Add indexes on foreign key columns |
| Transactions | Use transactions for multi-step migrations |
| Verification | Verify schema and data after migration |
| Documentation | Comment complex migrations |
| Performance | Keep migrations fast for large datasets |

## Rollback Strategies

SQLDelight doesn't support automatic rollbacks. Implement manually:

```kotlin
// Manual rollback with backup
suspend fun migrateWithRollback(driver: SqlDriver, targetVersion: Int) {
  val backupFile = File("backup_${System.currentTimeMillis()}.db")
  driver.database.copyTo(backupFile)

  try {
    AppDatabase.Schema.migrate(driver, targetVersion)
  } catch (e: Exception) {
    // Restore from backup
    backupFile.copyTo(driver.database, overwrite = true)
    throw e
  }
}
```

## Common Pitfalls

1. **NOT NULL without DEFAULT**: Adding a NOT NULL column without a default value fails on existing tables
2. **Dropping columns**: Requires full table recreate
3. **Foreign key violations**: Adding FKs fails if orphaned records exist
4. **Large migrations**: Use batching for large datasets to avoid memory issues
5. **Platform differences**: Test on all target platforms (Android, iOS, desktop)
