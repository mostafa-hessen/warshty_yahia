enum TreasuryTxType {
  income('وارد'),
  expense('مصروف');

  final String dbValue;
  const TreasuryTxType(this.dbValue);
}

extension TreasuryTxTypeX on TreasuryTxType {
  String get displayName => dbValue;
  bool get isIncome => this == TreasuryTxType.income;

  static TreasuryTxType fromDb(String value) {
    return TreasuryTxType.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => TreasuryTxType.expense,
    );
  }
}
