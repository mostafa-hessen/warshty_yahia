import '../../domain/entities/payment.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    super.id,
    required super.jobId,
    required super.amount,
    required super.date,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as int?,
      jobId: map['job_id'] as int,
      amount: (map['amount'] as num).toDouble(),
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'job_id': jobId,
      'amount': amount,
      'date': date,
    };
  }
}
