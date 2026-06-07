import '../entities/warehouse_item.dart';

abstract class WarehouseRepository {
  Future<List<WarehouseItem>> getItems({String? search});
  Future<void> addItem(WarehouseItem item);
  Future<void> updateItem(WarehouseItem item);
  Future<void> deleteItem(int id);
  Future<void> restockItem(int itemId, double quantity, {double? newCost});
  Future<List<WarehouseItem>> getLowStockItems();
  Future<List<WarehouseItem>> getOutOfStockItems();
}
