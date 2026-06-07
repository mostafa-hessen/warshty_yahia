import 'package:equatable/equatable.dart';

class WarehouseItem extends Equatable {
  final int? id;
  final String name;
  final String unit;
  final double cost;
  final double quantity;
  final double minQuantity;

  const WarehouseItem({
    this.id,
    required this.name,
    required this.unit,
    required this.cost,
    required this.quantity,
    this.minQuantity = 5,
  });

  double get totalValue => quantity * cost;
  bool get isLowStock => quantity > 0 && quantity <= minQuantity;
  bool get isOutOfStock => quantity <= 0;

  @override
  List<Object?> get props => [id, name, unit, cost, quantity, minQuantity];
}
