# 🗺️ الخطة الكاملة — Warshty ERP Flutter

## 📁 الهيكل النهائي للمشروع

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart              ✓
│   ├── database/
│   │   ├── database_constants.dart         ✓
│   │   ├── database_helper.dart            ✓
│   │   ├── database_tables.dart            ✓
│   │   ├── database_seed.dart              ✓
│   │   └── database_migrations.dart        ✓
│   ├── di/
│   │   └── injection_container.dart        ✓
│   ├── errors/
│   │   └── exceptions.dart                 ✓
│   ├── navigation/
│   │   ├── bottom_nav_item.dart            ✓
│   │   └── nav_items.dart                  ✓
│   ├── network/
│   │   └── connection_checker.dart         ✓
│   ├── presentation/
│   │   ├── app_shell.dart                  ✓
│   │   └── widgets/                        ✦ إنشاء
│   │       ├── app_card.dart
│   │       ├── app_modal.dart
│   │       ├── empty_state.dart
│   │       ├── balance_card.dart
│   │       ├── stat_card.dart
│   │       ├── detail_section.dart
│   │       ├── detail_row.dart
│   │       ├── summary_card.dart
│   │       ├── section_title.dart
│   │       ├── transaction_item.dart
│   │       ├── avatar_widget.dart
│   │       ├── category_chip.dart
│   │       ├── search_bar.dart
│   │       ├── action_button.dart
│   │       ├── confirm_dialog.dart
│   │       └── loading_state.dart
│   ├── routing/
│   │   ├── route_paths.dart                ✓
│   │   └── app_router.dart                 ✓
│   ├── storage/
│   │   └── app_prefs.dart                  ✓
│   ├── theme/
│   │   ├── app_colors.dart                 ✓
│   │   ├── app_text_styles.dart            ✓
│   │   ├── app_theme.dart                  ✓
│   │   └── theme_cubit.dart                ✓
│   └── utils/
│       └── formatters.dart                 ✓
│
├── features/
│   ├── person/
│   │   ├── data/models/
│   │   │   └── person_model.dart
│   │   ├── data/datasources/
│   │   │   └── person_local_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── person_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── person_cubit.dart
│   │   │   └── person_state.dart
│   │   ├── presentation/screens/
│   │   │   ├── persons_screen.dart
│   │   │   └── person_detail_screen.dart
│   │   └── presentation/widgets/
│   │       ├── person_card.dart
│   │       └── add_person_form.dart
│   │
│   ├── job/
│   │   ├── data/models/
│   │   │   ├── job_model.dart
│   │   │   ├── job_material_model.dart
│   │   │   ├── job_labor_model.dart
│   │   │   ├── job_other_cost_model.dart
│   │   │   └── job_payment_model.dart
│   │   ├── data/datasources/
│   │   │   └── job_local_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── job_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── job_cubit.dart
│   │   │   └── job_state.dart
│   │   ├── presentation/screens/
│   │   │   ├── jobs_screen.dart
│   │   │   └── job_detail_screen.dart
│   │   └── presentation/widgets/
│   │       ├── job_card.dart
│   │       └── add_job_form.dart
│   │
│   ├── treasury/
│   │   ├── data/models/
│   │   │   └── treasury_transaction_model.dart
│   │   ├── data/datasources/
│   │   │   └── treasury_local_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── treasury_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── treasury_cubit.dart
│   │   │   └── treasury_state.dart
│   │   ├── presentation/screens/
│   │   │   └── treasury_screen.dart
│   │   └── presentation/widgets/
│   │       └── add_treasury_form.dart
│   │
│   ├── dashboard/
│   │   ├── data/datasources/
│   │   │   └── dashboard_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── dashboard_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── dashboard_cubit.dart
│   │   │   └── dashboard_state.dart
│   │   ├── presentation/screens/
│   │   │   └── home_screen.dart
│   │   └── presentation/widgets/
│   │       ├── stats_grid.dart
│   │       └── recent_jobs_list.dart
│   │
│   ├── reports/
│   │   ├── data/datasources/
│   │   │   └── reports_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── reports_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── reports_cubit.dart
│   │   │   └── reports_state.dart
│   │   ├── presentation/screens/
│   │   │   └── reports_screen.dart
│   │   └── presentation/widgets/
│   │       ├── pl_report.dart
│   │       ├── persons_report.dart
│   │       └── jobs_report.dart
│   │
│   ├── category/
│   │   ├── data/models/
│   │   │   └── category_model.dart
│   │   ├── data/datasources/
│   │   │   └── category_local_datasource.dart
│   │   ├── domain/repositories/
│   │   │   └── category_repository.dart
│   │   ├── presentation/cubits/
│   │   │   ├── category_cubit.dart
│   │   │   └── category_state.dart
│   │   ├── presentation/screens/
│   │   │   └── categories_screen.dart
│   │   └── presentation/widgets/
│   │       └── add_category_form.dart
│   │
│   └── auth/
│       ├── data/datasources/
│       │   └── auth_local_datasource.dart
│       ├── domain/repositories/
│       │   └── auth_repository.dart
│       ├── presentation/cubits/
│       │   ├── auth_cubit.dart
│       │   └── auth_state.dart
│       └── presentation/screens/
│           └── login_screen.dart
```

---

## 📋 Phases Timeline

| Phase | المحتوى | المدة التقريبية |
|-------|---------|----------------|
| 0 ✓ | `core/` — البنية التحتية (Theme, DB, Routing, DI, Storage) | ✅ تم |
| 1 | Shared Widgets Library — 16 widget مشترك | **التالي** |
| 2 | Person Feature — أول Feature كامل (CRUD + Tx + Detail) | |
| 3 | Category Feature — إدارة التصنيفات (بسيط) | |
| 4 | Job Feature — الأصعب (6 جداول، 4 Weak Entities) | |
| 5 | Treasury Feature — وارد/مصروف + رصيد | |
| 6 | Dashboard Feature — تجميع البيانات، Stats، Recent | |
| 7 | Reports Feature — PL، Persons Report، Jobs Report | |
| 8 | Auth Feature — دخول + كلمة سر + قفل | |

---

## 🎯 كل Phase بالتفصيل

### Phase 1: Shared Widgets Library

**المشكلة:** Person و Job و Treasury كلهم هيحتاجوا Card، Modal، Empty State، Balance Card، Detail Section... لو عملنا كل واحد لوحده هنكرر كود.

**الحل:** 16 widget قابل لإعادة الاستخدام في `lib/core/presentation/widgets/`

- `app_card.dart` — بطاقة عرض (person, job, treasury)
- `app_modal.dart` — modal مع header + close + ClipRRect
- `empty_state.dart` — أيقونة + عنوان + نص فارغ
- `balance_card.dart` — عرض الرصيد
- `stat_card.dart` — إحصائية للـ Dashboard
- `detail_section.dart` — قسم تفاصيل مع عنوان
- `detail_row.dart` — label + value
- `summary_card.dart` — ملخص بحسابات
- `section_title.dart` — عنوان قسم + زر اختياري
- `transaction_item.dart` — معاملة (أخذت/عطيت)
- `avatar_widget.dart` — صورة مصغرة بالحروف الأولى
- `category_chip.dart` — شريحة تصنيف
- `search_bar.dart` — حقل بحث
- `action_button.dart` — زر أخضر/أحمر
- `confirm_dialog.dart` — نافذة تأكيد
- `loading_state.dart` — تحميل + خطأ

---

### Phase 2: Person Feature

**الملفات:**

| القسم | الملفات |
|-------|---------|
| Model | `person_model.dart` |
| DataSource | `person_local_datasource.dart` |
| Repository | `person_repository.dart` + impl |
| Cubit | `person_cubit.dart` + `person_state.dart` |
| Screens | `persons_screen.dart` + `person_detail_screen.dart` |
| Widgets | `person_card.dart` + `add_person_form.dart` |

**الشاشات:**
1. `PersonsScreen` — search + filter بتصنيفات + person cards list + FAB
2. `PersonDetailScreen` — tabs (حساب شخصي / شغلانات) + transactions + أخذت/عطيت bottom bar

**المودالات:**
- Person Modal (إضافة/تعديل شخص)
- Person Tx Modal (تسجيل أخذت/عطيت)
- Edit Tx Modal (تعديل/حذف معاملة)
- Person Report Modal (تقرير المعاملات)

**الـ DB:** `person` فقط

**أنماط جديدة:**
- Full CRUD pipeline (Model → DS → Repo → Cubit → Screen)
- Search + Filter with chips
- Computed field: balance (أخذت - عطيت)
- Tab switching داخل الـ Detail
- Modal forms
- Avatar with initials + color

---

### Phase 3: Category Feature

**الملفات:**
- `category_model.dart` + DataSource + Repository + Cubit
- `categories_screen.dart` + `add_category_form.dart`

**الشاشات:**
- `CategoriesScreen` — 3 tabs (مصروفات / واردات / مصنعيات) + chips + add

**ملاحظة:** الـ 15 category معمولهم seed — الـ Feature للإضافة/التعديل/الحذف فقط.

---

### Phase 4: Job Feature

**الملفات:**

| القسم | الملفات |
|-------|---------|
| Models | `job_model.dart`, `job_material_model.dart`, `job_labor_model.dart`, `job_other_cost_model.dart`, `job_payment_model.dart` |
| DataSource | `job_local_datasource.dart` |
| Repository | `job_repository.dart` + impl |
| Cubit | `job_cubit.dart` + `job_state.dart` |
| Screens | `jobs_screen.dart` + `job_detail_screen.dart` |
| Widgets | `job_card.dart` + `add_job_form.dart` |

**الشاشات:**
1. `JobsScreen` — workshop toggle + search + 3 tabs (قيد/مكتملة/مستحق)
2. `JobDetailScreen` — معلومات + summary + خامات + مصنعيات + تكاليف أخرى + دفعات

**المودالات:**
- Job Modal (إضافة/تعديل)
- Material Modal
- Labor Modal
- OtherCost Modal
- Payment Modal

**الـ DB:** `job` + `job_material` + `job_labor` + `job_other_cost` + `job_payment` + `treasury_transaction`

**أنماط جديدة:**
- Composite PK للـ weak entities (`owner_id` + `partial_id`)
- ربط person_transaction مع treasury عند الدفعة
- Computed fields: totalCosts, profit, remaining
- Batch insert للـ weak entities

---

### Phase 5: Treasury Feature

**الملفات:**
- `treasury_transaction_model.dart` + DataSource + Repository + Cubit
- `treasury_screen.dart` + `add_treasury_form.dart`

**الشاشات:**
- `TreasuryScreen` — balance card + وارد/مصروف buttons + transaction list

**المودالات:**
- Income Modal (وارد)
- Expense Modal (مصروف)

---

### Phase 6: Dashboard Feature

**الملفات:**
- `dashboard_datasource.dart` (بيجيب بيانات من جداول متعددة)
- `dashboard_repository.dart` + `dashboard_cubit.dart` + `dashboard_state.dart`
- `home_screen.dart` + `stats_grid.dart` + `recent_jobs_list.dart`

**الشاشات:**
- `HomeScreen` — balance card + 4 stats + recent jobs + recent persons
- FAB يفتح Person modal على Dashboard و Persons، Job modal على Jobs

---

### Phase 7: Reports Feature

**الملفات:**
- `reports_datasource.dart` + `reports_repository.dart` + `reports_cubit.dart` + `reports_state.dart`
- `reports_screen.dart` + `pl_report.dart` + `persons_report.dart` + `jobs_report.dart`

**التقارير:**
1. **PL Report** — أرباح/خسائر مجمعة مع period filter (الكل/شهر/سنة)
2. **Persons Report** — تقارير عن الأشخاص
3. **Jobs Report** — تقارير عن الشغلانات

---

### Phase 8: Auth Feature

**الملفات:**
- `auth_local_datasource.dart` (SHA-256 hash، failed attempts، lock logic)
- `auth_repository.dart` + `auth_cubit.dart` + `auth_state.dart`
- `login_screen.dart`

**الشاشات:**
- `LoginScreen` — إنشاء كلمة سر / دخول / مقفل

**الـ DB:** `user` table

---

## 🧩 القرارات المفتوحة

| القرار | الخيارات | المقترح |
|--------|---------|---------|
| عدد تبويبات البوتوم ناف | 4 ولا 5 (إضافة Jobs) | 5 |
| أول Feature | Person ولا Workshop | Person (نتخطى Workshop) |
| موعد Auth | الأول ولا الآخر | الآخر (Phase 8) |
