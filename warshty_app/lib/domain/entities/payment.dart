import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int? id;
  final int jobId;
  final double amount;
  final String date;

  const Payment({
    this.id,
    required this.jobId,
    required this.amount,
    required this.date,
  });

  @override
  List<Object?> get props => [id, jobId, amount, date];
}
