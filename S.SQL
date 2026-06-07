cat > /home/claude/schema.sql << 'EOF'
-- ============================================================
-- Carpentry Workshop Management System
-- Database: SQFlite
-- Version: 1.0
-- ============================================================

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

-- ============================================================
-- 1. WORKSHOPS — الورش
-- Strong Entity — أساس كل البيانات
-- ============================================================
CREATE TABLE IF NOT EXISTS workshops (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,

    name        TEXT    NOT NULL,               -- اسم الورشة
    address     TEXT,                           -- العنوان
    phone       TEXT,                           -- التليفون
    notes       TEXT,                           -- ملاحظات

    is_deleted  INTEGER NOT NULL DEFAULT 0,     -- Soft Delete
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- 2. TRANSACTION CATEGORIES — فئات المعاملات
-- Strong Entity — مستويين فقط Parent/Child
-- System categories لا تُحذف
-- ============================================================
CREATE TABLE IF NOT EXISTS transaction_categories (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,

    parent_id   INTEGER,                        -- NULL = فئة رئيسية
    name        TEXT    NOT NULL,               -- اسم الفئة
    type        TEXT    NOT NULL                -- 'income' | 'expense'
                CHECK (type IN ('income','expense')),

    is_system   INTEGER NOT NULL DEFAULT 0,     -- 1 = لا يُحذف ولا يُعدَّل
    is_deleted  INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now')),

    -- Parent لازم يكون فئة رئيسية (parent_id IS NULL)
    -- القاعدة دي بتتطبق من الكود مش SQL
    FOREIGN KEY (parent_id) REFERENCES transaction_categories(id)
);

-- Seed: الفئات الأساسية System
INSERT OR IGNORE INTO transaction_categories (id, parent_id, name, type, is_system)
VALUES
-- فئات رئيسية
(1,  NULL, 'إيرادات العملاء',    'income',  1),
(2,  NULL, 'إيداعات متنوعة',     'income',  0),
(3,  NULL, 'تكاليف الإنتاج',     'expense', 1),
(4,  NULL, 'مصنعية الصنايعية',   'expense', 1),
(5,  NULL, 'مصاريف تشغيل',       'expense', 0),
-- فئات فرعية
(10, 1,   'مدفوعات العملاء',     'income',  1),
(11, 1,   'رد مبالغ ملغية',      'income',  1),
(12, 2,   'رأس مال',             'income',  0),
(13, 2,   'قرض',                 'income',  0),
(14, 2,   'دخل متنوع',           'income',  0),
(20, 3,   'خامات',               'expense', 1),
(21, 3,   'نقل',                 'expense', 1),
(22, 3,   'تكاليف مباشرة أخرى', 'expense', 0),
(30, 4,   'مصنعية صنايعي',       'expense', 1),
(40, 5,   'إيجار',               'expense', 0),
(41, 5,   'كهرباء',              'expense', 0),
(42, 5,   'صيانة معدات',         'expense', 0),
(43, 5,   'مصاريف عامة أخرى',   'expense', 0);

-- ============================================================
-- 3. CASHBOX — الخزنة
-- Strong Entity — واحدة لكل ورشة
-- الرصيد يُحسب دائماً من الحركات — مش حقل ثابت
-- ============================================================
CREATE TABLE IF NOT EXISTS cashboxes (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    workshop_id  INTEGER NOT NULL,

    name         TEXT    NOT NULL DEFAULT 'الخزنة الرئيسية',
    notes        TEXT,

    is_deleted   INTEGER NOT NULL DEFAULT 0,
    created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (workshop_id) REFERENCES workshops(id)
    -- لماذا workshop_id هنا؟
    -- لأن الخزنة تابعة للورشة مش للعميل ولا للشغلانة
    -- لو حطيناه في مكان تاني هنفقد العزل بين الورش
);

-- ============================================================
-- 4. CASHBOX TRANSACTIONS — حركات الخزنة
-- Weak Entity — Audit Trail لا يُحذف أبداً
-- كل عملية مالية = سطر إجباري هنا
-- ============================================================
CREATE TABLE IF NOT EXISTS cashbox_transactions (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    cashbox_id      INTEGER NOT NULL,
    category_id     INTEGER NOT NULL,

    type            TEXT    NOT NULL                 -- 'in' | 'out'
                    CHECK (type IN ('in','out')),

    amount          REAL    NOT NULL
                    CHECK (amount > 0),              -- دايماً موجب

    -- مصدر الحركة — واحد بس بيكون NOT NULL
    -- الباقي NULL
    source_type     TEXT,                            -- 'customer_payment' | 'job_cost'
                                                     -- 'worker_payment' | 'manual'
                                                     -- 'cancellation_refund'
    source_id       INTEGER,                         -- id من الجدول المصدر

    reference_note  TEXT,                            -- وصف الحركة
    transaction_date TEXT   NOT NULL DEFAULT (date('now')),

    -- Storno: لو الحركة اترجعت
    is_reversed     INTEGER NOT NULL DEFAULT 0,
    reversed_by_id  INTEGER,                         -- id الحركة العكسية

    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    -- لا soft delete هنا — الحركات لا تُحذف أبداً
    FOREIGN KEY (cashbox_id)     REFERENCES cashboxes(id),
    FOREIGN KEY (category_id)    REFERENCES transaction_categories(id),
    FOREIGN KEY (reversed_by_id) REFERENCES cashbox_transactions(id)
);

-- ============================================================
-- 5. CUSTOMERS — العملاء
-- Strong Entity — مستقل عن الشغلانات
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    workshop_id  INTEGER NOT NULL,

    name         TEXT    NOT NULL,
    phone        TEXT,
    address      TEXT,
    notes        TEXT,

    is_deleted   INTEGER NOT NULL DEFAULT 0,
    created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (workshop_id) REFERENCES workshops(id)
    -- لماذا workshop_id هنا؟
    -- العميل تابع للورشة — عميل ورشة 1 مش عميل ورشة 2
);

-- ============================================================
-- 6. WORKERS — الصنايعية
-- Strong Entity — ثابت أو خارجي
-- باب مفتوح للـ Payroll مستقبلاً عبر worker_type
-- ============================================================
CREATE TABLE IF NOT EXISTS workers (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    workshop_id  INTEGER NOT NULL,

    name         TEXT    NOT NULL,
    phone        TEXT,
    worker_type  TEXT    NOT NULL DEFAULT 'external'
                 CHECK (worker_type IN ('permanent','external')),
                 -- permanent = ثابت (مستقبلاً له Payroll)
                 -- external  = خارجي (بالشغلانة)

    notes        TEXT,

    is_deleted   INTEGER NOT NULL DEFAULT 0,
    created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at   TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (workshop_id) REFERENCES workshops(id)
);

-- ============================================================
-- 7. JOBS — الشغلانات
-- Strong Entity — قلب النظام
-- ============================================================
CREATE TABLE IF NOT EXISTS jobs (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    workshop_id     INTEGER NOT NULL,
    customer_id     INTEGER NOT NULL,

    title           TEXT    NOT NULL,           -- وصف مختصر للشغلانة
    description     TEXT,                       -- وصف تفصيلي

    total_price     REAL    NOT NULL DEFAULT 0
                    CHECK (total_price >= 0),   -- السعر الإجمالي المتفق عليه

    status          TEXT    NOT NULL DEFAULT 'new'
                    CHECK (status IN (
                        'new',          -- جديدة
                        'in_progress',  -- شغالة
                        'completed',    -- خلصت
                        'delivered',    -- اتسلمت
                        'closed',       -- مغلقة
                        'cancelled'     -- ملغية
                    )),

    -- تواريخ المراحل
    started_at      TEXT,
    completed_at    TEXT,
    delivered_at    TEXT,
    closed_at       TEXT,
    cancelled_at    TEXT,

    -- بيانات الإلغاء
    cancel_reason   TEXT,
    cancel_action   TEXT                        -- 'refund' | 'transfer'
                    CHECK (cancel_action IN ('refund','transfer', NULL)),
    transfer_to_job_id INTEGER,                 -- لو الإلغاء بتحويل رصيد

    notes           TEXT,

    is_deleted      INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (workshop_id)        REFERENCES workshops(id),
    FOREIGN KEY (customer_id)        REFERENCES customers(id),
    FOREIGN KEY (transfer_to_job_id) REFERENCES jobs(id)
    -- لماذا customer_id هنا؟
    -- الشغلانة لازم يكون ليها عميل دايماً
    -- لو حطينا customer_id في جدول تاني هنفقد العلاقة المباشرة
);

-- ============================================================
-- 8. JOB ITEMS — قطع الشغلانة
-- Weak Entity — وصف نصي بدون أسعار
-- لا معنى لها بدون الشغلانة
-- ============================================================
CREATE TABLE IF NOT EXISTS job_items (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id      INTEGER NOT NULL,

    name        TEXT    NOT NULL,               -- اسم القطعة: "سرير - دولاب"
    description TEXT,                           -- وصف إضافي
    sort_order  INTEGER NOT NULL DEFAULT 0,     -- ترتيب العرض

    is_deleted  INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at  TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (job_id) REFERENCES jobs(id)
    -- لماذا job_id هنا؟
    -- القطعة تابعة للشغلانة — Weak Entity
    -- لو حذفنا الشغلانة القطع مش ليها معنى
);

-- ============================================================
-- 9. CUSTOMER PAYMENTS — مدفوعات العملاء
-- Weak Entity — مرتبطة بشغلانة معينة
-- كل دفعة تُنشئ حركة في الخزنة تلقائياً من الكود
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_payments (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id          INTEGER NOT NULL,
    cashbox_id      INTEGER NOT NULL,

    amount          REAL    NOT NULL
                    CHECK (amount > 0),

    payment_date    TEXT    NOT NULL DEFAULT (date('now')),
    notes           TEXT,

    -- ربط بحركة الخزنة المقابلة
    cashbox_transaction_id INTEGER,

    is_deleted      INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (job_id)                  REFERENCES jobs(id),
    FOREIGN KEY (cashbox_id)              REFERENCES cashboxes(id),
    FOREIGN KEY (cashbox_transaction_id)  REFERENCES cashbox_transactions(id)
    -- لماذا job_id هنا؟
    -- الدفعة مربوطة بشغلانة معينة لحساب ربح الشغلانة
    -- لو حطيناها على العميل بس هنفقد تفصيل كل شغلانة
);

-- ============================================================
-- 10. JOB COSTS — تكاليف الشغلانة
-- Weak Entity — خامات / نقل / مصاريف
-- job_id اختياري: لو NULL = مصروف عام على الورشة
-- ============================================================
CREATE TABLE IF NOT EXISTS job_costs (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    workshop_id     INTEGER NOT NULL,
    job_id          INTEGER,                    -- NULL = مصروف عام
    category_id     INTEGER NOT NULL,
    cashbox_id      INTEGER NOT NULL,

    description     TEXT    NOT NULL,           -- وصف التكلفة
    amount          REAL    NOT NULL
                    CHECK (amount > 0),

    cost_date       TEXT    NOT NULL DEFAULT (date('now')),
    notes           TEXT,

    -- ربط بحركة الخزنة المقابلة
    cashbox_transaction_id INTEGER,

    is_deleted      INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (workshop_id)             REFERENCES workshops(id),
    FOREIGN KEY (job_id)                  REFERENCES jobs(id),
    FOREIGN KEY (category_id)             REFERENCES transaction_categories(id),
    FOREIGN KEY (cashbox_id)              REFERENCES cashboxes(id),
    FOREIGN KEY (cashbox_transaction_id)  REFERENCES cashbox_transactions(id)
    -- لماذا job_id اختياري؟
    -- أحياناً المصروف على الورشة مش على شغلانة معينة
    -- زي الإيجار والكهرباء
);

-- ============================================================
-- 11. JOB WORKERS — شغلانة / صنايعي
-- Junction Entity — Many-to-Many
-- صنايعي واحد على أكتر من شغلانة والعكس
-- ============================================================
CREATE TABLE IF NOT EXISTS job_workers (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id          INTEGER NOT NULL,
    worker_id       INTEGER NOT NULL,

    agreed_amount   REAL    NOT NULL DEFAULT 0
                    CHECK (agreed_amount >= 0), -- المصنعية المتفق عليها

    notes           TEXT,

    is_deleted      INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    -- صنايعي مرة واحدة بس على نفس الشغلانة
    UNIQUE (job_id, worker_id),

    FOREIGN KEY (job_id)    REFERENCES jobs(id),
    FOREIGN KEY (worker_id) REFERENCES workers(id)
    -- لماذا الجدول ده منفصل؟
    -- علاقة Many-to-Many تحتاج Junction Table
    -- لأن الصنايعي ممكن يكون على أكتر من شغلانة
    -- ولأن كل ارتباط ليه agreed_amount خاصة بيه
);

-- ============================================================
-- 12. WORKER PAYMENTS — مدفوعات الصنايعية
-- Weak Entity — أكتر من دفعة لكل ارتباط
-- كل دفعة تُنشئ حركة في الخزنة تلقائياً من الكود
-- ============================================================
CREATE TABLE IF NOT EXISTS worker_payments (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    job_worker_id   INTEGER NOT NULL,
    cashbox_id      INTEGER NOT NULL,

    amount          REAL    NOT NULL
                    CHECK (amount > 0),

    payment_date    TEXT    NOT NULL DEFAULT (date('now')),
    notes           TEXT,

    -- ربط بحركة الخزنة المقابلة
    cashbox_transaction_id INTEGER,

    is_deleted      INTEGER NOT NULL DEFAULT 0,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now')),

    FOREIGN KEY (job_worker_id)           REFERENCES job_workers(id),
    FOREIGN KEY (cashbox_id)              REFERENCES cashboxes(id),
    FOREIGN KEY (cashbox_transaction_id)  REFERENCES cashbox_transactions(id)
    -- لماذا job_worker_id وليس worker_id مباشرة؟
    -- لأن الدفعة مرتبطة بالصنايعي على شغلانة معينة
    -- مش بالصنايعي بشكل عام
    -- ده اللي بيخلينا نحسب المتبقي لكل ارتباط
);

-- ============================================================
-- INDEXES — لتسريع الاستعلامات الأكثر استخداماً
-- ============================================================

-- الشغلانات
CREATE INDEX IF NOT EXISTS idx_jobs_workshop    ON jobs(workshop_id);
CREATE INDEX IF NOT EXISTS idx_jobs_customer    ON jobs(customer_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status      ON jobs(status);

-- العملاء
CREATE INDEX IF NOT EXISTS idx_customers_workshop ON customers(workshop_id);

-- الصنايعية
CREATE INDEX IF NOT EXISTS idx_workers_workshop   ON workers(workshop_id);

-- تكاليف الشغلانات
CREATE INDEX IF NOT EXISTS idx_job_costs_job      ON job_costs(job_id);
CREATE INDEX IF NOT EXISTS idx_job_costs_workshop ON job_costs(workshop_id);

-- مدفوعات العملاء
CREATE INDEX IF NOT EXISTS idx_customer_payments_job ON customer_payments(job_id);

-- حركات الخزنة
CREATE INDEX IF NOT EXISTS idx_cashbox_tx_cashbox ON cashbox_transactions(cashbox_id);
CREATE INDEX IF NOT EXISTS idx_cashbox_tx_date    ON cashbox_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_cashbox_tx_source  ON cashbox_transactions(source_type, source_id);

-- ربط الصنايعي بالشغلانة
CREATE INDEX IF NOT EXISTS idx_job_workers_job    ON job_workers(job_id);
CREATE INDEX IF NOT EXISTS idx_job_workers_worker ON job_workers(worker_id);

-- مدفوعات الصنايعية
CREATE INDEX IF NOT EXISTS idx_worker_payments_jw ON worker_payments(job_worker_id);

-- ============================================================
-- VIEWS — استعلامات جاهزة للتقارير
-- ============================================================

-- رصيد الخزنة الحالي
CREATE VIEW IF NOT EXISTS v_cashbox_balance AS
SELECT
    c.id            AS cashbox_id,
    c.workshop_id,
    c.name          AS cashbox_name,
    COALESCE(SUM(
        CASE
            WHEN ct.type = 'in'  AND ct.is_reversed = 0 THEN  ct.amount
            WHEN ct.type = 'out' AND ct.is_reversed = 0 THEN -ct.amount
            ELSE 0
        END
    ), 0)           AS current_balance
FROM cashboxes c
LEFT JOIN cashbox_transactions ct ON ct.cashbox_id = c.id
WHERE c.is_deleted = 0
GROUP BY c.id;

-- ملخص الشغلانة المالي
CREATE VIEW IF NOT EXISTS v_job_summary AS
SELECT
    j.id                AS job_id,
    j.workshop_id,
    j.title,
    j.status,
    j.total_price,

    -- إجمالي المحصَّل من العميل
    COALESCE((
        SELECT SUM(cp.amount)
        FROM customer_payments cp
        WHERE cp.job_id = j.id AND cp.is_deleted = 0
    ), 0)               AS total_collected,

    -- إجمالي التكاليف المباشرة
    COALESCE((
        SELECT SUM(jc.amount)
        FROM job_costs jc
        WHERE jc.job_id = j.id AND jc.is_deleted = 0
    ), 0)               AS total_direct_costs,

    -- إجمالي مدفوعات الصنايعية
    COALESCE((
        SELECT SUM(wp.amount)
        FROM worker_payments wp
        JOIN job_workers jw ON jw.id = wp.job_worker_id
        WHERE jw.job_id = j.id
          AND wp.is_deleted = 0
          AND jw.is_deleted = 0
    ), 0)               AS total_worker_payments,

    -- الحسابات النهائية
    j.total_price - COALESCE((
        SELECT SUM(cp.amount)
        FROM customer_payments cp
        WHERE cp.job_id = j.id AND cp.is_deleted = 0
    ), 0)               AS customer_balance,    -- المتبقي على العميل

    j.total_price
    - COALESCE((
        SELECT SUM(jc.amount)
        FROM job_costs jc
        WHERE jc.job_id = j.id AND jc.is_deleted = 0
    ), 0)
    - COALESCE((
        SELECT SUM(wp.amount)
        FROM worker_payments wp
        JOIN job_workers jw ON jw.id = wp.job_worker_id
        WHERE jw.job_id = j.id
          AND wp.is_deleted = 0
          AND jw.is_deleted = 0
    ), 0)               AS net_profit            -- صافي الربح

FROM jobs j
WHERE j.is_deleted = 0;

-- ملخص الصنايعي على كل شغلانة
CREATE VIEW IF NOT EXISTS v_worker_job_summary AS
SELECT
    jw.id               AS job_worker_id,
    jw.job_id,
    jw.worker_id,
    w.name              AS worker_name,
    j.title             AS job_title,
    jw.agreed_amount,
    COALESCE(SUM(wp.amount), 0)                         AS total_paid,
    jw.agreed_amount - COALESCE(SUM(wp.amount), 0)      AS remaining
FROM job_workers jw
JOIN workers w  ON w.id  = jw.worker_id
JOIN jobs    j  ON j.id  = jw.job_id
LEFT JOIN worker_payments wp
       ON wp.job_worker_id = jw.id AND wp.is_deleted = 0
WHERE jw.is_deleted = 0
GROUP BY jw.id;

-- ديون العملاء
CREATE VIEW IF NOT EXISTS v_customer_balance AS
SELECT
    c.id            AS customer_id,
    c.workshop_id,
    c.name          AS customer_name,
    COALESCE(SUM(j.total_price), 0)         AS total_jobs_value,
    COALESCE(SUM(cp_sum.paid), 0)           AS total_paid,
    COALESCE(SUM(j.total_price), 0)
    - COALESCE(SUM(cp_sum.paid), 0)         AS total_balance
FROM customers c
LEFT JOIN jobs j
       ON j.customer_id = c.id AND j.is_deleted = 0
       AND j.status NOT IN ('cancelled')
LEFT JOIN (
    SELECT job_id, SUM(amount) AS paid
    FROM customer_payments
    WHERE is_deleted = 0
    GROUP BY job_id
) cp_sum ON cp_sum.job_id = j.id
WHERE c.is_deleted = 0
GROUP BY c.id;

EOF
echo "Schema written successfully"
Output

Schema written successfully
