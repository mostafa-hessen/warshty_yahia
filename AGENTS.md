# ورشتي ERP — AGENTS.md

## نظرة عامة على المشروع

تطبيق Flutter لإدارة الورش والشغلانات (ERP مبسط).
التطبيق يعمل **offline بالكامل** — لا يوجد API خارجي.
اللغة: **عربية RTL** بالكامل.
الهدف: موبايل فقط (Android / iOS).

---

## Tech Stack

- **Flutter** (Dart) — UI framework
- **sqflite** — قاعدة بيانات SQLite محلية
- **flutter_bloc** — State Management (Cubit)
- **shared_preferences** — حفظ إعدادات الثيم (dark/light)
- **get_it** — Dependency Injection
- **go_router** — Navigation
- **google_fonts** — خط Tajawal العربي
- **equatable** — مقارنة الـ models
- **intl** — تنسيق الأرقام والتواريخ
- **connectivity_plus** — فحص الاتصال

---

# Architecture Rules — ورشتي

## Clean Architecture — Feature First

```
features/
└── workshop/
    ├── data/
    │   ├── models/
    │   │   └── workshop_model.dart             ← Equatable + fromMap/toMap
    │   └── datasources/
    │       └── workshop_local_datasource.dart  ← sqflite CRUD
    ├── domain/
    │   └── repositories/
    │       └── workshop_repository.dart        ← abstract class
    └── presentation/
        ├── cubits/
        │   ├── workshop_cubit.dart             ← Cubit
        │   └── workshop_state.dart             ← State classes
        ├── screens/
        │   ├── workshops_screen.dart
        │   └── workshop_detail_screen.dart
        └── widgets/
            ├── workshop_card.dart
            └── add_workshop_form.dart
```

## Theme Cubit (في core مش في features)

```
core/
└── theme/
    ├── app_colors.dart
    ├── app_text_styles.dart
    ├── app_theme.dart
    └── theme_cubit.dart   ← ThemeCubit + shared_preferences
```

---

## طبقات المشروع

```
UI (screens/widgets)
      ↓ BlocBuilder / BlocListener
Cubit
      ↓ استدعاء
Repository (abstract)
      ↓ تنفيذ
DataSource (sqflite)
      ↓ قراءة/كتابة
SQLite Database
```


### Theme (خارج الـ features):
```
core/
└── theme/
    └── theme_cubit.dart  ← ThemeCubit + shared_preferences
```

---

## قاعدة البيانات — 12 جدول

### Strong Entities (PK: INTEGER AUTOINCREMENT)
- `user` — بيانات تسجيل الدخول
- `workshop` — الورش
- `person` — العملاء والموردين
- `category` — تصنيفات المعاملات
- `treasury` — الخزينة (singleton — صف واحد id=1)
- `job` — الشغلانات (FK: workshop_id, person_id)

### Weak Entities (PK: Composite — owner_id + partial_id)
- `treasury_transaction` — معاملات الخزينة
- `person_transaction` — معاملات الأشخاص
- `job_material` — خامات الشغلانة
- `job_labor` — مصنعيات الشغلانة
- `job_other_cost` — تكاليف أخرى
- `job_payment` — دفعات الشغلانة

### قواعد مهمة:
- الـ Weak Entity دايماً PK = (owner_id + partial_id)
- nextPartialId = COUNT(*) WHERE owner_id = ? + 1
- الـ computed fields (balance, profit, remaining) مش بتتخزن — بتتحسب في Flutter
- Boolean في SQLite = 0 أو 1
- التواريخ بصيغة ISO string: "2026-06-22"

---

## الألوان والثيم

### Dark Mode (الأساسي):
- Background: `#0A0F1A`
- Card: `#1A2235`
- Accent: `#00D4AA` (تركواز)
- Text Primary: `#F0F4F8`
- Border: `#2A3548`

### Light Mode:
- Background: `#F0F4F0`
- Accent: `#008A6E`
- Text Primary: `#0D1F1A`

### Semantic:
- Success: `#10B981`
- Warning: `#F59E0B`
- Danger: `#EF4444`
- Info: `#3B82F6`
- Purple: `#8B5CF6`
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


---

## تنسيق الأرقام والتواريخ

```dart
// عملة
AppFormatters.currency(15000) // → "١٥٬٠٠٠ ج.م"

// تاريخ
AppFormatters.formatDate("2026-06-22") // → "٢٢ يونيو ٢٠٢٦"

// اليوم
AppFormatters.today() // → "2026-06-22"
```

---

## Exceptions المستخدمة

```dart
AppDatabaseException  // خطأ في SQLite (مش DatabaseException عشان بتتعارض مع sqflite)
NotFoundException     // عنصر مش موجود
ValidationException   // بيانات غلط
AppException          // خطأ عام
```

---

## قاعدة البيانات — هيكل الملفات

```
core/database/
├── database_helper.dart     ← Singleton + init فقط
├── database_tables.dart     ← كل CREATE TABLE statements
├── database_seed.dart       ← بيانات أولية (Categories)
├── database_migrations.dart ← migrations مستقبلية
└── database_constants.dart  ← أسماء الـ Tables والـ Columns
```

---

## قواعد الكود العامة

- دايماً استخدم `abstract final class` للـ static-only classes
- DatabaseHelper = Singleton
- كل الـ DB operations = `async/await`
- استخدم `batch` لما تعمل أكتر من عملية في نفس الوقت
- `PRAGMA foreign_keys = ON` في `onConfigure` مش `onOpen`
- RTL: كل الـ UI يدعم اتجاه عربي
- اسم التطبيق: "ورشتي"
- اسم الـ DB: "warshty.db"

---

## 🚫 قواعد من أخطاء سابقة — ممنوع مخالفتها

### 1. Enum for domain strings
**ممنوع:** `tx.type == 'أخذت'` أو أي string comparison لقيم منطقية.
**الحل:** كل Domain value له Enum (مثل `TransactionType`) مع `.dbValue` و `fromDb()`.

### 2. Model over Map
**ممنوع:** `j['name']` أو `(j['amount'] as num?)?.toDouble() ?? 0`.
**الحل:** أي بيانات من DB تعدي على Model مع `fromMap()` — Type Safety كامل.

### 3. Business logic خارج build()
**ممنوع:** Loops, sums, sorts, aggregations جوه `build()` أو أي Widget.
**الحل:** كل الحسابات تتحسب في Cubit/State مرة واحدة وتخزن كـ final fields.

### 4. Always check shared widgets first
**قبل كتابة أي Widget، افتح `core/presentation/widgets/` وشوف موجود إيه.**
لو موجود استخدمه — لو محتاج تعديل زود parameter مش تعمل inline copy-paste.

### 5. Keys on list items
**كل `list.map()` لـ Widgets محتاج `ValueKey(item.id)` — ممنوع map من غير Key.**

### 6. formatNumber for bare numbers
**ممنوع:** `.split(' ج')[0]` أو أي string parsing للـ formatted currency.
**استخدم:** `AppFormatters.formatNumber()` للرقم فقط، و `AppFormatters.currency()` للرقم + العملة.

### 7. Null safety — no force unwrap without guard
**ممنوع:** `person.id!` من غير null check قبله.
**الحل:** `if (person.id != null) ...` أو `??` مع default.

### 8. File size limit
**أي Widget file > 300 سطر، قسمه لملفات منفصلة** (Widget واحد لكل ملف).

### 9. قوائم > 20 عنصر تستخدم builder
**ممنوع:** `...list.map()` لقوائم > 20 عنصر جوه Column.
**استخدم:** `ListView.builder()` أو `SliverList` في `CustomScrollView`.

### 10. Ask before assuming
**لو مش متأكد من requirement أو فيه trade-off، اسأل المطور — متفترضش.**

### 11. Const كل ما تقدر
**`SizedBox(height: 8)` → `const SizedBox(height: 8)`** — Flutter بيكافئك على const.

### 12. InkWell over GestureDetector
استخدم `InkWell` (للـ ripple effect) بدل `GestureDetector` في كل الأماكن الممكنة، خاصة في الكروت والقوائم.

### 13. SnackBar — feedback بعد كل عملية
**أي عملية بيانات (إضافة/تعديل/حذف) لازم تظهر SnackBar نجاح/خطأ.**
- الـ `Cubit` يـ `rethrow` الأخطاء من mutation methods (لا يـ emit error states عشان مايفقدش الـ UI القديم).
- الـ `Screen` تستخدم `try/catch` حول استدعاء الـ Cubit وتظهر SnackBar مناسبة.
- `BlocConsumer` في الـ Screen عشان تسمع error states من `load()` / `loadDetail()`.
```dart
// Cubit — mutation لا تمسك الأخطاء
Future<void> update(PersonModel person) async {
  if (_processing) return;
  _processing = true;
  try {
    await _repository.update(person);
    await _reloadCurrent();
  } catch (e) {
    rethrow; // Screen هتتعامل معاه
  } finally {
    _processing = false;
  }
}

// Screen — الـ caller يتعامل مع النجاح/الخطأ
onSubmit: (updated) async {
  try {
    await cubit.update(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم التعديل بنجاح'), backgroundColor: AppColors.success),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger),
    );
  }
}
```

### 14. Loading guard — منع التكرار
**كل Cubit عنده `bool _processing` مع early return guard.**
- قبل أي mutation: `if (_processing) return;`
- `_processing = true` → await → `finally { _processing = false; }`
- الـ Forms تضيف `bool _submitting` وتعطل الزر + تظهر spinner خلال `await widget.onSubmit()`.
```dart
// Form button
ElevatedButton(
  onPressed: _submitting ? null : _submit,
  child: _submitting
    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
    : Text('حفظ'),
)

Future<void> _submit() async {
  setState(() => _submitting = true);
  try {
    await widget.onSubmit(...);
  } finally {
    if (mounted) setState(() => _submitting = false);
  }
}
```

### 15. reloadCurrent pattern
**بعد أي mutation، الـ Cubit يعمل reload حسب السياق الحالي — مش دايماً `load()`.**
```dart
Future<void> _reloadCurrent() async {
  final current = state;
  if (current is PersonDetailLoaded) {
    await loadDetail(current.person.id!); // نفضل في التفاصيل
  } else {
    await load(); // رجوع للقائمة
  }
}
```
بدون كده، لو كنت في Detail و `update()` كلت `load()`، الـ Screen هتستقبل `Loading`/`Loaded` (List states) وتظهر `SizedBox.shrink()` — شاشة فاضية.