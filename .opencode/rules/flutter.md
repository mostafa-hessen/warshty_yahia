# Flutter UI Rules — ورشتي

## Language & Layout

- **Arabic-only**: Every user-facing string is Arabic. No English in labels, buttons, messages, or placeholders.
- **RTL**: The entire app is Right-to-Left. Do not add any LTR considerations.
- **Font**: Always use `GoogleFonts.tajawal()` — never use default Material font.
- **Mobile-first**: Max width is 430px (`AppConstants.maxAppWidth`). Design for single-hand use.

## Colors (AppColors)

Use `AppColors` constants from `lib/core/theme/app_colors.dart`. Never hardcode color values.

**Dark mode (default):**
- Backgrounds: `darkBgPrimary`, `darkBgSecondary`, `darkBgCard`, `darkBgCardHover`
- Text: `darkTextPrimary`, `darkTextSecondary`, `darkTextMuted`
- Border: `darkBorder`
- Accent: `darkAccent` (#00D4AA)
- Glow/shadow: `darkAccentGlow`

**Light mode:**
- Backgrounds: `lightBgPrimary`, `lightBgSecondary`, `lightBgCard`, `lightBgCardHover`
- Text: `lightTextPrimary`, `lightTextSecondary`, `lightTextMuted`
- Border: `lightBorder`
- Accent: `lightAccent` (#008A6E)
- Glow/shadow: `lightAccentGlow`

**Semantic colors:** `success`, `warning`, `danger`, `info`, `purple` — use light variants (`successLight`, etc.) for light mode.

**Overlay:** `AppColors.modalOverlay` for modal backdrops (70% black).

## Spacing & Radius (AppConstants)

Use `AppConstants` constants from `lib/core/constants/app_constants.dart`. Never hardcode spacing or radius values.

**Spacing:** `spacing2` through `spacing100` (17 values: 2, 3, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 40, 50, 100).

**Border radius:** `radiusXs` (4), `radiusSm` (8), `radiusMd` (10), `radiusLg` (12), `radiusXl` (14), `radius2xl` (18), `radius3xl` (22), `radiusChip` (16).

**Icon sizes:** `iconSm` (14), `iconMd` (16), `iconLg` (20), `iconXl` (22), `iconBtnSize` (36).

**Misc:** `maxAppWidth` (430), `bottomNavHeight` (56), `fabSize` (52), `personBottomBarHeight` (56).

## Text Styles (AppTextStyles)

Use `AppTextStyles` static methods from `lib/core/theme/app_text_styles.dart`. Every method takes `BuildContext` and returns a theme-aware `TextStyle`.

Key methods: `logoText`, `loginTitle`, `balanceAmount`, `balanceLabel`, `statValue`, `statLabel`, `sectionTitle`, `cardTitle`, `cardAmount`, `modalTitle`, `formLabel`, `formInput`, `button`, `loginButton`, `tab`, `workshopButton`, `categoryChip`, `navLabel`, `badge`, `detailSectionTitle`, `detailLabel`, `detailValue`, `summaryLabel`, `summaryValue`, `summaryTotal`, `treasuryAmount`, `financeMiniValue`, `financeLargeValue`, `txAmountMain`, `txTagAmount`, `reportCardLabel`, `reportCardValue`, `plSectionTitle`, `plRow`, `plTotalRow`, `personActionBtn`, `actionBtn`, `backBtn`.

## Theme (AppTheme)

Two complete `ThemeData` objects: `AppTheme.dark` and `AppTheme.light`.

**Dark theme highlights:**
- `scaffoldBackgroundColor = darkBgPrimary`
- AppBar: transparent, elevation 0, title uses Tajawal w800
- InputDecoration: filled, darkBgCard fill, radius 10, focused border 1.5px accent
- ElevatedButton: accent bg, dark text, radius 10, vertical padding 14
- Card: zero elevation, radius 14, border
- BottomNav: semi-transparent dark bg, accent selected
- Chip: radius 16, accent when selected
- Dialog: bg = darkBgSecondary, top corners radius 22
- SnackBar: floating, radius 10

## Formatters (AppFormatters)

Use `AppFormatters` from `lib/core/utils/formatters.dart`:

- `currency(double)` → "١٥٬٠٠٠ ج.م" (Arabic locale, no decimals)
- `formatNumber(double)` → "١٥٬٠٠٠" (no currency symbol)
- `formatDate(String?)` → "٢٠ يونيو ٢٠٢٦" (Arabic month names)
- `formatDateTime(String?)` → "٢٠ يونيو ٢٠٢٦ ٢:٣٠ م"
- `formatDateShort(String?)` → "20/06/2026" (numeric)
- `today()` → ISO date string "2026-06-20"
- `now()` → ISO datetime string

All date methods return '—' for null/empty input and gracefully return raw string on parse failure.

## Widget Patterns

- Use `SizedBox` for spacing, not `Container` with empty child.
- Cards should use `AppConstants.radiusXl` (14px) border radius.
- Modals should use `AppConstants.radius3xl` (22px) for top corners only.
- Use `ClipRRect` with asymmetric radius for modal top corners.
- Accent glow shadows: use `darkAccentGlow` / `lightAccentGlow` with `BoxShadow(blurRadius: 20, spreadRadius: -4)`.
- Empty states: centered column with icon + `emptyTitle` + `emptyText`.
- Loading states: `CircularProgressIndicator` with accent color.

## Navigation

- Use named routes with `Navigator.pushNamed` / `Navigator.pop`.
- Define routes in `main.dart` under `routes:` map.
- Bottom navigation: 4 tabs — الرئيسية (Home), الأشخاص (Persons), الخزينة (Treasury), التقارير (Reports).
