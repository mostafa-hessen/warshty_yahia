import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/treasury_tx_type.dart';
import '../../../jobs/data/datasources/job_local_datasource.dart';
import '../../../persons/data/datasources/person_local_datasource.dart';
import '../../../treasury/data/datasources/treasury_local_datasource.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TreasuryLocalDataSource _treasuryDataSource;
  final JobLocalDataSource _jobDataSource;
  final PersonLocalDataSource _personDataSource;

  HomeCubit({
    required TreasuryLocalDataSource treasuryDataSource,
    required JobLocalDataSource jobDataSource,
    required PersonLocalDataSource personDataSource,
  }) : _treasuryDataSource = treasuryDataSource,
       _jobDataSource = jobDataSource,
       _personDataSource = personDataSource,
       super(HomeInitial());

  Future<void> load() async {
    emit(HomeLoading());
    try {
      final allTxs = await _treasuryDataSource.getAll();
      double income = 0, expense = 0;
      for (final tx in allTxs) {
        if (tx.type.isIncome) {
          income += tx.amount;
        } else {
          expense += tx.amount;
        }
      }
      final treasuryBalance = income - expense;

      final allJobs = await _jobDataSource.getAll();
      final jobsInProgress = allJobs.where((j) => j.status == 'قيد').length;
      final jobsCompleted = allJobs.where((j) => j.status == 'مكتملة').length;

      final allPersons = await _personDataSource.getAll();
      final totalPersons = allPersons.length;

      emit(HomeLoaded(
        treasuryBalance: treasuryBalance,
        jobsInProgress: jobsInProgress,
        jobsCompleted: jobsCompleted,
        totalPersons: totalPersons,
      ));
    } catch (e) {
      emit(HomeError('$e'));
    }
  }
}
