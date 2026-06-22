# Database Rules — ورشتي

## Overview

SQLite via sqflite. All schema defined in `lib/core/database/database_helper.dart`. Trust the code over `doc/06-database-schema.md` — the Flutter implementation differs slightly from the docs.

## Schema: 12 Tables

### Strong Entities (6)

| Table | PK | Notes |
|---|---|---|
| `user` | `id` INTEGER AUTOINCREMENT | Auth only. `password_hash`, `failed_attempts`, `locked_until` |
| `workshop` | `id` INTEGER AUTOINCREMENT | `name`, `is_active` |
| `person` | `id` INTEGER AUTOINCREMENT | `name`, `phone`, `type` (default 'عميل'), `notes`, `is_active` |
| `category` | `id` INTEGER AUTOINCREMENT | `name`, `type` (مصروف/وارد/مصنعية/تكلفة), `is_active` |
| `treasury` | `id` INTEGER AUTOINCREMENT | Singleton — only one row (id=1) ever inserted |
| `job` | `id` INTEGER AUTOINCREMENT | `workshop_id` FK, `person_id` FK, `name`, `product_type`, `agreed_amount`, `status` (default 'قيد'), `start_date`, `notes` |

### Weak Entities (6) — Composite PK = (owner_id, partial_id)

| Table | Owner FK | Extra FKs | Notes |
|---|---|---|---|
| `treasury_transaction` | `treasury_id` | `category_id`, `workshop_id`, `job_id` | `type` = 'وارد' / 'مصروف', `source` = 'يدوي' / 'شغلانة' |
| `person_transaction` | `person_id` | — | `type` = 'أخذت' / 'عطيت' |
| `job_material` | `job_id` | — | `name`, `amount`, `description`, `date` |
| `job_labor` | `job_id` | `category_id` | `amount`, `description`, `date` |
| `job_other_cost` | `job_id` | `category_id` | `amount`, `description`, `date` |
| `job_payment` | `job_id` | composite FK `(ttx_treasury_id, ttx_partial_id)` → `treasury_transaction` | `amount`, `description`, `date` |

## Weak Entity ID Pattern

All weak entities use composite primary keys: `(owner_id, partial_id)`.

To generate the next `partial_id`:
```dart
final partialId = await DatabaseHelper.instance.nextPartialId(
  db,
  'job_material',  // table name
  'job_id',        // owner column name
  jobId,           // owner ID value
);
```

This counts existing rows for that owner and returns `count + 1`.

## Foreign Keys

Enabled via `PRAGMA foreign_keys = ON` in `_onConfigure`. This runs before every database open.

**Cascade rules:** None defined — all FKs use default (RESTRICT). Deleting a parent with children will fail.

**Important composite FK:** `job_payment(ttx_treasury_id, ttx_partial_id)` → `treasury_transaction(treasury_id, partial_id)`. This links payments to their treasury transactions.

## Seed Data

15 categories inserted during `_onCreate`:

| Type | Categories |
|---|---|
| مصروف | كهرباء, مياه, إيجار, رواتب, نقل, صيانة |
| وارد | دفعة عميل, عربون, إيراد منوع |
| مصنعية | أجرة نجار, أجرة دهان, أجرة تركيب, أجرة عام |
| تكلفة | خامات, شحن |

Treasury singleton: `INSERT INTO treasury (id) VALUES (1)` — always id=1.

## Two Separate Ledgers (Core Constraint)

1. **Debt Register** (`person_transaction`): Tracks money between workshop and persons. Types: `أخذت` (I took) / `عطيت` (I gave). These NEVER affect treasury.
2. **Cash Register** (`treasury_transaction`): Tracks actual cash flow. Types: `وارد` (income) / `مصروف` (expense). These NEVER affect person balances.

**The only cross-ledger link:** When `job_payment` is recorded, it MUST also create a `treasury_transaction` with `source = 'شغلانة'`. This is the income side. The expense side (`مصروف`) is recorded separately.

## Computed Fields (Never Stored)

- **Person balance**: Sum of `amount` where `type = 'أخذت'` minus sum where `type = 'عطيت'`
- **Job profit**: `agreed_amount` - total costs (materials + labor + other)
- **Job remaining**: `agreed_amount` - total payments
- **Treasury balance**: Sum of `وارد` amounts minus sum of `مصروف` amounts
- **Treasury total_income**: Sum of all `وارد` amounts
- **Treasury total_expense**: Sum of all `مصروف` amounts

## Query Patterns

- Use `db.rawQuery()` for computed fields (sums, counts, joins).
- Use `db.insert()` / `db.update()` / `db.delete()` for CRUD.
- Always filter by `is_active = 1` for soft-deleted records.
- Dates stored as ISO strings (`yyyy-MM-dd` or full ISO 8601).
- Use `db.batch()` for bulk operations (e.g., seed data).

## Database Access Pattern

```dart
// Get database
final db = await DatabaseHelper.instance.database;

// Weak entity insert
final partialId = await DatabaseHelper.instance.nextPartialId(
  db, 'job_material', 'job_id', jobId,
);
await db.insert('job_material', {
  'job_id': jobId,
  'partial_id': partialId,
  'name': name,
  'amount': amount,
  'description': description,
  'date': AppFormatters.today(),
});

// Computed query
final result = await db.rawQuery('''
  SELECT COALESCE(SUM(amount), 0) as total
  FROM person_transaction
  WHERE person_id = ? AND type = 'أخذت'
''', [personId]);
```
