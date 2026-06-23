import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/job_model.dart';
import '../../domain/repositories/job_repository.dart';
import 'job_state.dart';

class JobCubit extends Cubit<JobState> {
  final JobRepository _repository;

  JobCubit(this._repository) : super(JobInitial());

  bool _processing = false;
  bool get isProcessing => _processing;

  Future<void> load() async {
    emit(JobLoading());
    try {
      final jobs = await _repository.getAll();
      emit(JobLoaded(jobs));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> add(JobModel job) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.add(job);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> update(JobModel job) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.update(job);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> delete(int id) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.delete(id);
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }
}
