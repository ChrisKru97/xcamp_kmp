# SQLDelight Skill

Assist with SQLDelight database schemas, queries, and migrations in Kotlin Multiplatform projects.

## Usage

```
/sqldelight [task]
```

**Examples:**
- `/sqldelight add user table with email, name, created_at`
- `/sqldelight migrate user table add last_login column`
- `/sqldelight query for active users by email`
- `/sqldelight regenerate database code`

## File Structure

```
shared/src/commonMain/sqldelight/com/krutsche/xcamp/db/
├── XcampDatabase.sq          # Main schema file
├── XcampDatabase.sqm         # Migration files (versioned)
└── [Entity].sq               # Additional schema files
```

## Table Definition Pattern

```sql
-- Table: tableName
CREATE TABLE table_name (
    id TEXT NOT NULL PRIMARY KEY,
    field_name TEXT NOT NULL,
    nullable_field TEXT,
    number_field INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
);

-- Query:selectAll
SELECT * FROM table_name;

-- Query:selectById
SELECT * FROM table_name
WHERE id = ?;

-- Query:insert
INSERT OR REPLACE INTO table_name (
    id, field_name, nullable_field, number_field, created_at
)
VALUES (?, ?, ?, ?, ?);

-- Query:update
UPDATE table_name
SET field_name = ?, nullable_field = ?
WHERE id = ?;

-- Query:delete
DELETE FROM table_name
WHERE id = ?;

-- Query:deleteAll
DELETE FROM table_name;
```

## Migration Pattern

**File:** `XcampDatabase.sqm`

```sql
-- Migration: 1
CREATE TABLE table_name (
    id TEXT NOT NULL PRIMARY KEY,
    field_name TEXT NOT NULL
);

-- Migration: 2
ALTER TABLE table_name ADD COLUMN new_field TEXT;
```

## Key Patterns

### Reserved Keywords
SQLite reserved keywords require bracket escaping:
- `group`, `order`, `values`, `index`, `select`, `insert`
- Use `[group]`, `[order]`, etc. in column names

### Foreign Keys
```sql
CREATE TABLE child_table (
    id TEXT NOT NULL PRIMARY KEY,
    parent_id TEXT NOT NULL,
    FOREIGN KEY (parent_id) REFERENCES parent_table(id) ON DELETE CASCADE
);
```

### Kotlin Query Execution
```kotlin
// In repository or database manager
database.xcampDatabaseQueries
    .selectById(id)
    .executeAsOneOrNull()

// For queries with parameters
database.xcampDatabaseQueries
    .insert(id, fieldName, nullableField, numberField, createdAt)
    .await()
```

### Async Coroutines
SQLDelight supports coroutine operations:
```kotlin
suspend fun insert(entity: Entity) {
    database.xcampDatabaseQueries.insert(...).await()
}

suspend fun getById(id: String): Entity? {
    return database.xcampDatabaseQueries.selectById(id).executeAsOneOrNull()
}
```

## Code Regeneration

After modifying `.sq` or `.sqm` files, regenerate Kotlin code:

```bash
./gradlew generateCommonMainXcampDatabaseInterface
```

Or clean build:
```bash
./gradlew clean generateCommonMainXcampDatabaseInterface
```

## Project-Specific Context

**Project:** XcamP KMP
**Database:** XcampDatabase
**Package:** `com.krutsche.xcamp.db`
**SQLDelight Version:** 2.1.0

**Current Tables:**
- See `shared/src/commonMain/sqldelight/com/krutsche/xcamp/db/` for existing schema
- Common patterns use `TEXT` for IDs, `INTEGER` for timestamps (epoch millis)
