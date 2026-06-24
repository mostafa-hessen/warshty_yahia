enum CategoryType {
  expense('مصروف'),
  income('وارد'),
  labor('مصنعية'),
  cost('تكلفة');

  final String dbValue;
  const CategoryType(this.dbValue);
}

extension CategoryTypeX on CategoryType {
  String get displayName => dbValue;

  static CategoryType fromDb(String value) {
    return CategoryType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => CategoryType.expense,
    );
  }
}
