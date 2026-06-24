import 'package:equatable/equatable.dart';

class WorkshopModel extends Equatable {
  final int? id;
  final String name;
  final bool isActive;

  const WorkshopModel({
    this.id,
    required this.name,
    this.isActive = true,
  });

  factory WorkshopModel.fromMap(Map<String, dynamic> map) {
    return WorkshopModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      isActive: (map['is_active'] as int?) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'is_active': isActive ? 1 : 0,
    };
  }

  @override
  List<Object?> get props => [id, name, isActive];
}
