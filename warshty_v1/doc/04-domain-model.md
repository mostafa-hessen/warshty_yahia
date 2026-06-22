# Domain Model (نموذج المجال) — الإصدار v4

**النظام:** نظام إدارة ورش النجارة "ورشتي" — إدارة الديون والنقدية والشغلانات
**آخر تحديث:** 10 يونيو 2026

---

## ملخص الـ Entities (13 entities)

| # | Entity | الوصف |
|---|---|---|
| 1 | User | المستخدم + إعدادات الأمان |
| 2 | Workshop | الورش (سيلا / الفيوم) |
| 3 | Category | التصنيفات (وارد / مصروف / مصنعية) |
| 4 | Person | الأشخاص (عملاء / موردين / صنايعية / موظفين / شركات) |
| 5 | PersonTransaction | حركات دفتر الديون (أخذت / عطيت) |
| 6 | Job | الشغلانات |
| 7 | JobMaterial | خامات الشغلانة |
| 8 | JobLabor | مصنعيات الشغلانة |
| 9 | JobOtherCost | تكاليف أخرى للشغلانة |
| 10 | JobPayment | دفعات الشغلانة → تروح للخزنة أوتوماتيك |
| 11 | Treasury | الخزنة (رصيد واحد محسوب) |
| 12 | TreasuryTransaction | حركات الخزنة (وارد / مصروف) |
| 13 | LedgerTransaction | سجل اليومية — توثيق كل الحركات |

---

## تفاصيل Entities والـ Attributes

---

### 1. User

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| passwordHash | string | SHA-256 |
| rememberToken | string | nullable — البقاء مسجلاً |
| failedAttempts | integer | default 0 — عدد المحاولات الفاشلة |
| lockedUntil | datetime | nullable — وقت القفل المؤقت |
| lastLogin | datetime | nullable — آخر دخول |
| theme | enum | "dark" / "light" — افتراضي dark |
| createdAt | datetime | تاريخ الإنشاء |

---

### 2. Workshop

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| name | string | اسم الورشة (سيـلا / الفيوم) |
| isActive | boolean | default true |
| createdAt | datetime | |

---

### 3. Category

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| name | string | اسم التصنيف |
| type | enum | "income" / "expense" / "labor" |
| isActive | boolean | default true |
| createdAt | datetime | |

---

### 4. Person

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| name | string | الاسم — إجباري |
| phone | string | رقم الهاتف — إجباري |
| type | enum | "client" / "supplier" / "craftsman" / "employee" / "company" |
| notes | text | nullable |
| isActive | boolean | default true |
| createdAt | datetime | |

---

### 5. PersonTransaction

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| personId | integer | FK → Person |
| type | enum | "debit" (أخذت) / "credit" (عطيت) |
| amount | decimal | > 0 |
| description | text | nullable — بيان المعاملة |
| date | date | تاريخ المعاملة |
| createdAt | datetime | |

> **ملاحظة:** الرصيد محسوب = إجمالي أخذت − إجمالي عطيت (لا يُخزَّن)

---

### 6. Job

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| name | string | اسم الشغلانة |
| clientId | integer | FK → Person |
| workshopId | integer | FK → Workshop |
| productType | string | nullable — نوع المنتج |
| agreedAmount | decimal | المبلغ المتفق عليه |
| status | enum | "active" / "completed" / "archived" |
| startDate | date | nullable |
| notes | text | nullable |
| createdAt | datetime | |
| updatedAt | datetime | |

---

### 7. JobMaterial

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| jobId | integer | FK → Job |
| description | string | اسم/وصف الخامة |
| quantity | decimal | الكمية |
| unitCost | decimal | سعر الوحدة |
| totalCost | decimal | محسوب = quantity × unitCost |
| createdAt | datetime | |

---

### 8. JobLabor

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| jobId | integer | FK → Job |
| categoryId | integer | FK → Category (type = labor) |
| description | string | بيان المصنعية |
| cost | decimal | التكلفة |
| createdAt | datetime | |

---

### 9. JobOtherCost

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| jobId | integer | FK → Job |
| description | string | بيان التكلفة |
| cost | decimal | |
| createdAt | datetime | |

---

### 10. JobPayment

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| jobId | integer | FK → Job |
| amount | decimal | > 0 |
| date | date | تاريخ الدفعة |
| treasuryTransactionId | integer | nullable — FK → TreasuryTransaction (auto) |
| createdAt | datetime | |

> **ملاحظة:** عند إضافة دفعة، تُنشأ TreasuryTransaction (type = income) تلقائياً

---

### 11. Treasury

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK — record واحد فقط |
| createdAt | datetime | |

> **الرصيد:** محسوب = إجمالي وارد − إجمالي مصروف (لا يُخزَّن)

---

### 12. TreasuryTransaction

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| treasuryId | integer | FK → Treasury |
| type | enum | "income" (وارد) / "expense" (مصروف) |
| amount | decimal | > 0 |
| description | string | بيان الحركة |
| categoryId | integer | FK → Category |
| workshopId | integer | FK → Workshop |
| jobId | integer | nullable — FK → Job (ربط المصروف بشغلانة) |
| source | enum | "manual" (يدوي) / "job_payment" (من دفعة شغلانة) |
| date | date | تاريخ الحركة |
| createdAt | datetime | |

---

### 13. LedgerTransaction

| الحقل | النوع | ملاحظة |
|---|---|---|
| id | integer | PK |
| type | enum | "person_debit" / "person_credit" / "job_payment" |
| amount | decimal | |
| description | string | |
| personId | integer | nullable — FK → Person |
| jobId | integer | nullable — FK → Job |
| personTransactionId | integer | nullable — FK → PersonTransaction |
| jobPaymentId | integer | nullable — FK → JobPayment |
| date | date | |
| createdAt | datetime | |

---

## العلاقات بين الـ Entities (Relationships)

```
User (1)

Workshop (1) ──────────────── (N) Job
Workshop (1) ──────────────── (N) TreasuryTransaction

Category (1) ──────────────── (N) JobLabor
Category (1) ──────────────── (N) TreasuryTransaction

Person (1) ────────────────── (N) PersonTransaction
Person (1) ────────────────── (N) Job (بصفته client)

Job (1) ───────────────────── (N) JobMaterial
Job (1) ───────────────────── (N) JobLabor
Job (1) ───────────────────── (N) JobOtherCost
Job (1) ───────────────────── (N) JobPayment
Job (1) ───────────────────── (N) TreasuryTransaction (nullable — اختياري)

JobPayment (1) ────────────── (1) TreasuryTransaction (auto — مصاحبة)

PersonTransaction (1) ─────── (1) LedgerTransaction
JobPayment (1) ────────────── (1) LedgerTransaction

Treasury (1) ──────────────── (N) TreasuryTransaction
```

---

## قواعد العمل الأساسية (Business Logic Rules)

### R1 — الفصل التام بين الدفترين
```
دفتر الديون ← PersonTransaction (أخذت/عطيت) ← لا يؤثر على الخزنة
دفتر الخزنة  ← TreasuryTransaction (وارد/مصروف) ← لا تؤثر على ديون الأشخاص
```

### R2 — الرصيد محسوب لا مخزَّن
```
Person Balance = Σ debit − Σ credit   (محسوب من PersonTransaction)
Treasury Balance = Σ income − Σ expense   (محسوب من TreasuryTransaction)
```

### R3 — حساب الشغلانة
```
إجمالي الخامات   = Σ (quantity × unitCost) لكل JobMaterial
إجمالي المصنعيات  = Σ cost لكل JobLabor
إجمالي تكاليف أخرى = Σ cost لكل JobOtherCost
─────────────────────────────────────────────────
إجمالي التكاليف    = الخامات + المصنعيات + تكاليف أخرى
الربح             = agreedAmount − إجمالي التكاليف
المتبقي          = agreedAmount − Σ JobPayment
```

### R4 — دفعات الشغلانة ← الخزنة (auto)
```
JobPayment.add → TreasuryTransaction.create(type=income, source=job_payment)
JobPayment.delete → TreasuryTransaction.delete
TreasuryTransaction(source=job_payment) → غير قابل للتعديل اليدوي
```

### R5 — لا حذف دائم
```
Job → Soft Archive (status=archived)
Person → Soft Disable (isActive=false)
```

---

## هيكل التخزين (Storage Schema — localStorage)

```json
{
  "settings": {
    "passwordHash": "sha256hash...",
    "rememberToken": "uuid...",
    "loginAttempts": 0,
    "lockedUntil": null,
    "lastLogin": "2026-06-10T12:00:00Z",
    "theme": "dark",
    "isSetup": true
  },
  "workshops": [
    { "id": 1, "name": "سيـلا", "isActive": true },
    { "id": 2, "name": "الفيوم", "isActive": true }
  ],
  "categories": [
    { "id": 1, "name": "كهرباء", "type": "expense" },
    { "id": 2, "name": "دفعة من عميل", "type": "income" }
  ],
  "persons": [
    {
      "id": 1,
      "name": "...",
      "phone": "...",
      "type": "client",
      "notes": "...",
      "isActive": true,
      "transactions": [
        { "id": 1, "type": "debit", "amount": 500, "description": "...", "date": "2026-06-10" }
      ]
    }
  ],
  "jobs": [
    {
      "id": 1,
      "name": "...",
      "clientId": 1,
      "workshopId": 1,
      "agreedAmount": 5000,
      "status": "active",
      "materials": [...],
      "laborItems": [...],
      "otherCosts": [...],
      "payments": [...]
    }
  ],
  "treasury": {
    "transactions": [
      {
        "id": 1,
        "type": "income",
        "amount": 2000,
        "description": "...",
        "categoryId": 2,
        "workshopId": 1,
        "source": "manual",
        "date": "2026-06-10"
      }
    ]
  },
  "ledgerTransactions": [...]
}
```
