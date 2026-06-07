import 'package:equatable/equatable.dart';

class JobMaterial extends Equatable {
  final int? id;
  final int jobId;
  final String description;
  final double costPerUnit;
  final double quantity;
  final int? warehouseItemId;

  const JobMaterial({
    this.id,
    required this.jobId,
    required this.description,
    required this.costPerUnit,
    required this.quantity,
    this.warehouseItemId,
  });

  double get totalCost => costPerUnit * quantity;

  @override
  List<Object?> get props =>
      [id, jobId, description, costPerUnit, quantity, warehouseItemId];
}
