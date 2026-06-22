-- ============================================================
--  SQLite Schema — mapped from ERD
--  Target: Flutter (sqflite)
-- ============================================================


-- ══════════════════════════════════════════════
--  1. USER
-- ══════════════════════════════════════════════
-- Strong Entity — بتاخد table لوحدها بكل attributesها
-- الـ PK هو id بس (مفيش composite هنا)
CREATE TABLE user (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  password_hash   TEXT    NOT NULL,
  remember_token  TEXT,
  failed_attempts INTEGER NOT NULL DEFAULT 0,
  locked_until    TEXT,
  created_at      TEXT    NOT NULL DEFAULT (datetime('now'))
);


-- ══════════════════════════════════════════════
--  2. WORKSHOP
-- ══════════════════════════════════════════════
-- Strong Entity — مستقلة تماماً
-- مفيش FK جوّاها لأنها مش تابعة لحد
CREATE TABLE workshop (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL,
  is_active  INTEGER NOT NULL DEFAULT 1,   -- 0/1 بدل boolean في SQLite
  created_at TEXT    NOT NULL DEFAULT (datetime('now'))
);


-- ══════════════════════════════════════════════
--  3. PERSON
-- ══════════════════════════════════════════════
-- Strong Entity
-- balance و jobs_balance = computed → مش بنخزنهم
-- بنحسبهم في Flutter من الـ transactions
CREATE TABLE person (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  name      TEXT    NOT NULL,
  phone     TEXT,
  type      TEXT    NOT NULL,   -- 'عميل' | 'مورد' | ...
  notes     TEXT,
  is_active INTEGER NOT NULL DEFAULT 1
  created_at TEXT    NOT NULL DEFAULT (datetime('now'))

  -- balance      ← محسوبة (SUM من person_transaction)
  -- jobs_balance ← محسوبة (SUM من job payments)
);


-- ══════════════════════════════════════════════
--  4. CATEGORY
-- ══════════════════════════════════════════════
-- Strong Entity — مستقلة
-- بتتربط بـ TreasuryTransaction و JobLabor و JobOtherCost
CREATE TABLE category (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  name       TEXT    NOT NULL,
  type       TEXT    NOT NULL,   -- 'وارد' | 'مصروف' | 'مصنعية' | 'تكلفة'
  is_active  INTEGER NOT NULL DEFAULT 1,
  created_at TEXT    NOT NULL DEFAULT (datetime('now'))
);


-- ══════════════════════════════════════════════
--  5. TREASURY
-- ══════════════════════════════════════════════
-- Strong Entity — singleton (صف واحد بس في الـ DB)
-- كل الـ computed attributes (balance, total_income, total_expense)
-- بنحسبها من treasury_transaction في Flutter
CREATE TABLE treasury (
  id INTEGER PRIMARY KEY AUTOINCREMENT
  -- balance       ← محسوبة (SUM amounts)
  -- total_income  ← محسوبة (SUM WHERE type='وارد')
  -- total_expense ← محسوبة (SUM WHERE type='مصروف')
);


-- ══════════════════════════════════════════════
--  6. JOB
-- ══════════════════════════════════════════════
-- Strong Entity
-- علاقة M:1 مع Workshop  → بنحط workshop_id هنا (FK جاي من الـ 1)
-- علاقة M:1 مع Person    → بنحط person_id هنا
-- total_costs / profit / remaining = computed → مش بنخزنهم
CREATE TABLE job (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  workshop_id    INTEGER NOT NULL,
  person_id      INTEGER NOT NULL,
  name           TEXT    NOT NULL,
  product_type   TEXT,
  agreed_amount  REAL    NOT NULL DEFAULT 0,
  status         TEXT    NOT NULL DEFAULT 'قيد',   -- 'قيد' | 'مكتملة' | 'باقي'
  start_date     TEXT,
  created_at TEXT    NOT NULL DEFAULT (datetime('now'))

  notes          TEXT,
  -- total_costs ← محسوبة (SUM job_material + job_labor + job_other_cost)
  -- profit      ← محسوبة (agreed_amount - total_costs)
  -- remaining   ← محسوبة (agreed_amount - SUM job_payment)
  FOREIGN KEY (workshop_id) REFERENCES workshop(id),
  FOREIGN KEY (person_id)   REFERENCES person(id)
);
-- 📌 قاعدة 1:M → الـ FK بيروح في جانب الـ M (هو الـ job)


-- ══════════════════════════════════════════════
--  7. TREASURY TRANSACTION
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Treasury (الـ Owner)
-- الـ PK = (treasury_id + partial_id) → Composite PK
-- عندها FKs إضافية: category, workshop, job (nullable)
CREATE TABLE treasury_transaction (
  treasury_id  INTEGER NOT NULL,
  partial_id   INTEGER NOT NULL,
  type         TEXT    NOT NULL,   -- 'وارد' | 'مصروف'
  amount       REAL    NOT NULL,
  description  TEXT,
  date         TEXT    NOT NULL,
  source       TEXT,               -- 'يدوي' | 'شغلانة'
  category_id  INTEGER,
  workshop_id  INTEGER,
  job_id       INTEGER ,            -- nullable لأن مش كل transaction بيكون ليها job
  PRIMARY KEY (treasury_id, partial_id),
  FOREIGN KEY (treasury_id) REFERENCES treasury(id),
  FOREIGN KEY (category_id) REFERENCES category(id),
  FOREIGN KEY (workshop_id) REFERENCES workshop(id),
  FOREIGN KEY (job_id)      REFERENCES job(id)
);
-- 📌 Weak Entity → PK = (treasury_id + partial_id)
-- 📌 job_id nullable عشان مش كل معاملة مرتبطة بشغلانة


-- ══════════════════════════════════════════════
--  8. PERSON TRANSACTION
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Person (الـ Owner)
-- الـ PK = (person_id + partial_id)
-- balance_before = computed → مش بنخزنه
CREATE TABLE person_transaction (
  person_id   INTEGER NOT NULL,
  partial_id  INTEGER NOT NULL,
  type        TEXT    NOT NULL,   -- 'أخذت' | 'عطيت'
  amount      REAL    NOT NULL,
  description TEXT,
  date        TEXT    NOT NULL,
  -- balance_before ← محسوبة في Flutter قبل ما تعمل الـ insert
  PRIMARY KEY (person_id, partial_id),
  FOREIGN KEY (person_id) REFERENCES person(id)
);


-- ══════════════════════════════════════════════
--  9. JOB MATERIAL
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Job
-- الـ PK = (job_id + partial_id)
CREATE TABLE job_material (
  job_id      INTEGER NOT NULL,
  partial_id  INTEGER NOT NULL,
  name        TEXT    NOT NULL,
  amount      REAL,
  description TEXT,
  date        TEXT,
  PRIMARY KEY (job_id, partial_id),
  FOREIGN KEY (job_id) REFERENCES job(id)
);


-- ══════════════════════════════════════════════
--  10. JOB LABOR
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Job
-- الـ PK = (job_id + partial_id)
-- عندها category_id (FK) → موجودة في الـ ERD كـ attribute مباشرة
CREATE TABLE job_labor (
  job_id      INTEGER NOT NULL,
  partial_id  INTEGER NOT NULL,
  amount      REAL,
  description TEXT,
  date        TEXT,
  category_id INTEGER,
  PRIMARY KEY (job_id, partial_id),
  FOREIGN KEY (job_id)      REFERENCES job(id),
  FOREIGN KEY (category_id) REFERENCES category(id)
);


-- ══════════════════════════════════════════════
--  11. JOB OTHER COST
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Job
-- نفس نمط job_labor تماماً
CREATE TABLE job_other_cost (
  job_id      INTEGER NOT NULL,
  partial_id  INTEGER NOT NULL,
  amount      REAL,
  description TEXT,
  date        TEXT,
  category_id INTEGER,
  PRIMARY KEY (job_id, partial_id),
  FOREIGN KEY (job_id)      REFERENCES job(id),
  FOREIGN KEY (category_id) REFERENCES category(id)
);


-- ══════════════════════════════════════════════
--  12. JOB PAYMENT
-- ══════════════════════════════════════════════
-- Weak Entity — تابعة لـ Job
-- الـ PK = (job_id + partial_id)
-- treasury_tx_id = FK لـ TreasuryTransaction (composite FK!)
-- لما العميل يدفع → بنعمل treasury_transaction تلقائي ونحط الـ id هنا
CREATE TABLE job_payment (
  job_id          INTEGER NOT NULL,
  partial_id      INTEGER NOT NULL,
  amount          REAL    NOT NULL,
  description     TEXT,
  date            TEXT    NOT NULL,
  -- FK للـ treasury_transaction (composite: treasury_id + partial_id)
  ttx_treasury_id INTEGER,
  ttx_partial_id  INTEGER,
  PRIMARY KEY (job_id, partial_id),
  FOREIGN KEY (job_id) REFERENCES job(id),
  FOREIGN KEY (ttx_treasury_id, ttx_partial_id)
    REFERENCES treasury_transaction(treasury_id, partial_id)
);
-- 📌 الـ FK هنا composite عشان treasury_transaction نفسها PK مركب