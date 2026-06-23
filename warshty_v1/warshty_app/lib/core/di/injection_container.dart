import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../storage/app_prefs.dart';
import '../theme/theme_cubit.dart';
import '../../features/jobs/data/datasources/job_local_datasource.dart';
import '../../features/jobs/data/repositories/job_repository_impl.dart';
import '../../features/jobs/domain/repositories/job_repository.dart';
import '../../features/jobs/presentation/cubits/job_cubit.dart';
import '../../features/persons/data/datasources/person_local_datasource.dart';
import '../../features/persons/data/repositories/person_repository_impl.dart';
import '../../features/persons/domain/repositories/person_repository.dart';
import '../../features/persons/presentation/cubits/person_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  sl.registerLazySingleton(() => AppPrefs(sl()));

  sl.registerLazySingleton(() => DatabaseHelper.instance);

  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // ==========================================================
  //  Person Feature
  // ==========================================================
  sl.registerLazySingleton(() => PersonLocalDataSource(sl()));
  sl.registerLazySingleton<PersonRepository>(() => PersonRepositoryImpl(sl()));
  sl.registerFactory(() => PersonCubit(sl()));

  // ==========================================================
  //  Job Feature
  // ==========================================================
  sl.registerLazySingleton(() => JobLocalDataSource(sl()));
  sl.registerLazySingleton<JobRepository>(() => JobRepositoryImpl(sl()));
  sl.registerFactory(() => JobCubit(sl()));
}
