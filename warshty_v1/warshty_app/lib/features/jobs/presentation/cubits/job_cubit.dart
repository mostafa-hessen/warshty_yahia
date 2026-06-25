import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/treasury_tx_type.dart';
import '../../../../core/utils/formatters.dart';
import '../../../treasury/data/models/treasury_transaction_model.dart';
import '../../../treasury/domain/repositories/treasury_repository.dart';
import '../../data/models/job_labor_model.dart';
import '../../data/models/job_material_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_other_cost_model.dart';
import '../../data/models/job_payment_model.dart';
import '../../domain/repositories/job_repository.dart';
import 'job_state.dart';

class JobCubit extends Cubit<JobState> {
  final JobRepository _repository;
  final TreasuryRepository _treasuryRepository;

  JobCubit(this._repository, this._treasuryRepository) : super(JobInitial());

  bool _processing = false;
  bool get isProcessing => _processing;

  Object? _lastDeletedItem;
  String? _lastDeletedType;

  // ── Load ────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(JobLoading());
    try {
      final jobs = await _repository.getAll();
      emit(JobLoaded(jobs));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> loadDetail(int id) async {
    emit(JobDetailLoading());
    try {
      final job = await _repository.getById(id);
      if (job == null) {
        emit(const JobError('لم يتم العثور على الشغلانة'));
        return;
      }
      final results = await Future.wait([
        _repository.getMaterials(id),
        _repository.getLabors(id),
        _repository.getOtherCosts(id),
        _repository.getPayments(id),
      ]);
      emit(JobDetailLoaded(
        job: job,
        materials: results[0] as List<JobMaterialModel>,
        labors: results[1] as List<JobLaborModel>,
        otherCosts: results[2] as List<JobOtherCostModel>,
        payments: results[3] as List<JobPaymentModel>,
      ));
    } catch (e) {
      emit(JobError(e.toString()));
    }
  }

  Future<void> _reloadCurrent() async {
    final current = state;
    if (current is JobDetailLoaded) {
      await loadDetail(current.job.id);
    } else {
      await load();
    }
  }

  // ── Main Job Mutations ──────────────────────────────────────────

  Future<int> add(JobModel job) async {
    if (_processing) return -1;
    _processing = true;
    try {
      final id = await _repository.add(job);
      await _reloadCurrent();
      return id;
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
      await _reloadCurrent();
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
      emit(JobLoading());
      await load();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Material Mutations ─────────────────────────────────────────

  Future<void> addMaterial(JobMaterialModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.addMaterial(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> updateMaterial(JobMaterialModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.updateMaterial(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> deleteMaterial(int jobId, int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      final current = state;
      if (current is JobDetailLoaded) {
        _lastDeletedItem = current.materials.where(
          (m) => m.jobId == jobId && m.partialId == partialId,
        ).firstOrNull;
        _lastDeletedType = 'material';
      }
      await _repository.deleteMaterial(jobId, partialId);
      await _reloadCurrent();
    } catch (e) {
      _lastDeletedItem = null;
      _lastDeletedType = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Labor Mutations ───────────────────────────────────────────

  Future<void> addLabor(JobLaborModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.addLabor(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> updateLabor(JobLaborModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.updateLabor(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> deleteLabor(int jobId, int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      final current = state;
      if (current is JobDetailLoaded) {
        _lastDeletedItem = current.labors.where(
          (l) => l.jobId == jobId && l.partialId == partialId,
        ).firstOrNull;
        _lastDeletedType = 'labor';
      }
      await _repository.deleteLabor(jobId, partialId);
      await _reloadCurrent();
    } catch (e) {
      _lastDeletedItem = null;
      _lastDeletedType = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Other Cost Mutations ──────────────────────────────────────

  Future<void> addOtherCost(JobOtherCostModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.addOtherCost(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> updateOtherCost(JobOtherCostModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.updateOtherCost(item);
      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> deleteOtherCost(int jobId, int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      final current = state;
      if (current is JobDetailLoaded) {
        _lastDeletedItem = current.otherCosts.where(
          (o) => o.jobId == jobId && o.partialId == partialId,
        ).firstOrNull;
        _lastDeletedType = 'otherCost';
      }
      await _repository.deleteOtherCost(jobId, partialId);
      await _reloadCurrent();
    } catch (e) {
      _lastDeletedItem = null;
      _lastDeletedType = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }

  // ── Payment Mutations (with auto treasury tx) ─────────────────

  Future<void> addPayment(JobPaymentModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      int? workshopId;
      final current = state;
      if (current is JobDetailLoaded) {
        workshopId = current.job.workshopId;
      } else {
        final job = await _repository.getById(item.jobId);
        workshopId = job?.workshopId;
      }

      const treasuryId = 1;
      final ttxPartialId = await _treasuryRepository.insert(TreasuryTransactionModel(
        treasuryId: treasuryId,
        partialId: 0,
        type: TreasuryTxType.income,
        amount: item.amount,
        description: item.description != null && item.description!.isNotEmpty
            ? 'دفعة: ${item.description}'
            : null,
        date: AppFormatters.now(),
        source: 'شغلانة',
        workshopId: workshopId,
        jobId: item.jobId,
      ));

      await _repository.addPayment(item.copyWith(
        ttxTreasuryId: treasuryId,
        ttxPartialId: ttxPartialId,
      ));

      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> updatePayment(JobPaymentModel item) async {
    if (_processing) return;
    _processing = true;
    try {
      await _repository.updatePayment(item);

      // نجيب original ttx ids من الـ state مش من الـ form (الفورم مش بتحتفظ بيهم)
      final current = state;
      JobPaymentModel? origPayment;
      if (current is JobDetailLoaded) {
        origPayment = current.payments.where(
          (p) => p.jobId == item.jobId && p.partialId == item.partialId,
        ).firstOrNull;
      }
      if (origPayment?.ttxPartialId == null) {
        // لو مش في الـ state، نجيب من الداتابيز
        final dbItem = await _repository.getPayments(item.jobId);
        origPayment = dbItem.where(
          (p) => p.partialId == item.partialId,
        ).firstOrNull;
      }

      final ttxTreasuryId = origPayment?.ttxTreasuryId;
      final ttxPartialId = origPayment?.ttxPartialId;
      if (ttxPartialId != null && ttxTreasuryId != null) {
        int? workshopId;
        if (current is JobDetailLoaded) {
          workshopId = current.job.workshopId;
        } else {
          final job = await _repository.getById(item.jobId);
          workshopId = job?.workshopId;
        }
        await _treasuryRepository.update(TreasuryTransactionModel(
          treasuryId: ttxTreasuryId,
          partialId: ttxPartialId,
          type: TreasuryTxType.income,
          amount: item.amount,
          description: item.description != null && item.description!.isNotEmpty
              ? 'دفعة: ${item.description}'
              : null,
          date: AppFormatters.now(),
          source: 'شغلانة',
          workshopId: workshopId,
          jobId: item.jobId,
        ));
      }

      await _reloadCurrent();
    } catch (e) {
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> deletePayment(int jobId, int partialId) async {
    if (_processing) return;
    _processing = true;
    try {
      final current = state;
      int? ttxPartialId;
      if (current is JobDetailLoaded) {
        final payment = current.payments.where(
          (p) => p.jobId == jobId && p.partialId == partialId,
        ).firstOrNull;
        ttxPartialId = payment?.ttxPartialId;
        _lastDeletedItem = payment;
        _lastDeletedType = 'payment';
      }

      if (ttxPartialId != null) {
        await _treasuryRepository.delete(ttxPartialId);
      }

      await _repository.deletePayment(jobId, partialId);
      await _reloadCurrent();
    } catch (e) {
      _lastDeletedItem = null;
      _lastDeletedType = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }

  Future<void> undoLastDelete() async {
    if (_lastDeletedItem == null || _lastDeletedType == null || _processing) return;
    _processing = true;
    try {
      switch (_lastDeletedType) {
        case 'material':
          await _repository.addMaterial(_lastDeletedItem as JobMaterialModel);
        case 'labor':
          await _repository.addLabor(_lastDeletedItem as JobLaborModel);
        case 'otherCost':
          await _repository.addOtherCost(_lastDeletedItem as JobOtherCostModel);
        case 'payment':
          final p = _lastDeletedItem as JobPaymentModel;
          await addPayment(p.copyWith(partialId: 0));
      }
      _lastDeletedItem = null;
      _lastDeletedType = null;
      await _reloadCurrent();
    } catch (e) {
      _lastDeletedItem = null;
      _lastDeletedType = null;
      rethrow;
    } finally {
      _processing = false;
    }
  }
}
