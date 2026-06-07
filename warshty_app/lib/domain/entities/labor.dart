import 'package:equatable/equatable.dart';

class Labor extends Equatable {
  final int? id;
  final int jobId;
  final String description;
  final double amount;
  final String categoryId;

  const Labor({
    this.id,
    required this.jobId,
    required this.description,
    required this.amount,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, jobId, description, amount, categoryId];
}
