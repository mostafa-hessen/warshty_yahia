enum TransactionType { take, give }

extension TransactionTypeX on TransactionType {
  String get dbValue => this == TransactionType.take ? 'أخذت' : 'عطيت';

  static TransactionType fromDb(String s) {
    return s == 'أخذت' ? TransactionType.take : TransactionType.give;
  }
}
