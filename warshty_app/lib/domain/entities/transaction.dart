import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int? id;
  final String type; // 'income' | 'expense'
  final String date;
  final double amount;
  final String description;
  final String categoryId;
  final String workshopId;
  final int? jobId;

  const Transaction({
    this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.description,
    required this.categoryId,
    this.workshopId = 'all',
    this.jobId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        date,
        amount,
        description,
        categoryId,
        workshopId,
        jobId,
      ];
}
