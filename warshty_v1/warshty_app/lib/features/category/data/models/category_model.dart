import 'package:equatable/equatable.dart';

import '../../../../core/enums/category_type.dart';

class CategoryModel extends Equatable {
  final int? id;
  final String name;
  final CategoryType type;
  final bool isActive;

  const CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.isActive = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: CategoryTypeX.fromDb(map['type'] as String),
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type.dbValue,
      'is_active': isActive ? 1 : 0,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    CategoryType? type,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, type, isActive];
}
