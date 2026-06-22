# AGENTS.md

## Project: Warshty (ورشتي)

ERP for carpentry workshops — manages jobs, persons (CRM), treasury, and financial reports. Offline-first, Arabic-only, mobile-first (max 430px).

## Repository Layout

```
warshty_yahia/
├── BRD.md                      # Original business requirements
├── warshty_v1/
│   ├── doc/                    # Architecture docs (BRD v4, business rules, DB schema, domain model)
│   └── warshty_app/            # Flutter app (the active codebase)
│       ├── lib/
│       │   ├── main.dart       # Entry point (currently default counter — needs wiring)
│       │   └── core/           # Shared infrastructure layer
│       │       ├── constants/  # AppConstants (sizes, spacing, DB name)
│       │       ├── database/   # DatabaseHelper singleton (sqflite schema + seed data)
│       │       ├── errors/     # Custom exceptions
│       │       ├── network/    # Connection checker (connectivity_plus v6)
│       │       ├── theme/      # AppColors, AppTextStyles, AppTheme (dark+light)
│       │       └── utils/      # AppFormatters (currency, dates — Arabic locale)
│       └── pubspec.yaml
└── beta/                       # Older HTML versions (v3, v4) — reference only
```

## Key Commands

```bash
# From warshty_v1/warshty_app/
flutter pub get          # Install dependencies
dart analyze             # Static analysis (uses flutter_lints)
flutter run              # Run on device/emulator
flutter test             # Run tests (widget_test.dart exists but minimal)
```

No CI, no custom lint scripts, no build scripts.

## Architecture Facts

- **Database**: SQLite via sqflite. Schema uses composite PKs for weak entities (e.g., `(job_id, partial_id)`). Foreign keys enabled via `PRAGMA foreign_keys = ON` in `_onConfigure`.
- **Two separate ledgers**: Debt Register (person transactions: أخذت/عطيت) and Cash Register (treasury: وارد/مصروف). They never affect each other — this is a core design constraint.
- **Job payments auto-create treasury income**: When a payment is recorded on a job, it must also be inserted into `treasury_income`. This is the only cross-ledger link.
- **Balances are computed, never stored**: Person balance, job profit, treasury balance — all calculated from transactions at query time.
- **Weak entity IDs**: Use `DatabaseHelper.nextPartialId()` to generate sequential partial IDs per owner.
- **Categories are seeded on DB creation**: 14 default categories (مصروف, وارد, مصنعية, تكلفة).

## Style Conventions

- **Arabic-only UI**: All user-facing text is Arabic. No English in labels, buttons, or messages.
- **Font**: Google Fonts Tajawal — use `GoogleFonts.tajawal()` everywhere.
- **Colors**: Use `AppColors` constants. Dark mode is default; accent is `#00D4AA` (dark) / `#008A6E` (light).
- **Spacing/Radius**: Use `AppConstants` values (spacing8, radiusMd, etc.) — derived from the original HTML/CSS design.
- **Text styles**: Use `AppTextStyles` static methods — they take `BuildContext` for theme-aware coloring.
- **RTL layout**: Entire app is RTL. No LTR considerations needed.

## Gotchas

- `main.dart` is still the Flutter default counter widget. The `core/` layer is built but not yet wired into the app.
- The `core_plan.md` in `.opencode/plans/` shows a slightly older schema (TEXT IDs, different table names). The actual `database_helper.dart` uses INTEGER autoincrement IDs and different table/column names — **trust the code, not the plan**.
- `connectivity_plus` v6 returns `List<ConnectivityResult>`, not a single result.
- No auth/login implementation exists yet in Flutter — BRD requires SHA-256 master password with lockout logic.
- The older HTML versions in `beta/` and `vesions/` are the original reference implementation — useful for understanding intended behavior, but the Flutter app is the active target.

## Reference Docs

- `warshty_v1/doc/01-brd.md` — Full BRD v4 (most detailed functional spec)
- `warshty_v1/doc/03-business-rules.md` — All business rules with IDs (BR-001 through BR-604)
- `warshty_v1/doc/06-database-schema.md` — SQL schema reference (note: differs slightly from Flutter implementation)
- `BRD.md` — Original high-level requirements
