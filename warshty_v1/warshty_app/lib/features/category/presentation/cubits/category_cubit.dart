import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/category_type.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  bool _processing = false;
  bool get isProcessing => _processing;

  CategoryType? _typeFilter;
  CategoryType? get typeFilter => _typeFilter;

  void setTypeFilter(CategoryType? type) {
    _typeFilter = type;
    load();
  }

  Future<void> load() async {
    emit(CategoryLoading());
    try {
      final categories = _typeFilter != null
          ? await _repository.getByType(_typeFilter!)
          : await _repository.getAll();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> add(CategoryModel category) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.add(category);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> update(CategoryModel category) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.update(category);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> softDelete(int id) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.softDelete(id);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }
}
