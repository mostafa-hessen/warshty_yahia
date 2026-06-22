/// ثوابت قاعدة البيانات — أسماء الـ Tables والمفاتيح
abstract final class DatabaseConstants {
  // ── Table Names ──────────────────────────────────────────
  static const String userTable = 'user';
  static const String workshopTable = 'workshop';
  static const String personTable = 'person';
  static const String categoryTable = 'category';
  static const String treasuryTable = 'treasury';
  static const String jobTable = 'job';

  // Weak Entities
  static const String treasuryTransactionTable = 'treasury_transaction';
  static const String personTransactionTable = 'person_transaction';
  static const String jobMaterialTable = 'job_material';
  static const String jobLaborTable = 'job_labor';
  static const String jobOtherCostTable = 'job_other_cost';
  static const String jobPaymentTable = 'job_payment';

  // ── Column Names ─────────────────────────────────────────
  static const String id = 'id';
  static const String partialId = 'partial_id';
  static const String ownerId = 'owner_id';
  static const String isActive = 'is_active';
  static const String createdAt = 'created_at';
}
