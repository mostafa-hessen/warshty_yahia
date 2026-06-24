import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../storage/app_prefs.dart';
import '../theme/theme_cubit.dart';
import '../../features/category/data/datasources/category_local_datasource.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/presentation/cubits/category_cubit.dart';
import '../../features/treasury/data/datasources/treasury_local_datasource.dart';
import '../../features/treasury/data/repositories/treasury_repository_impl.dart';
import '../../features/treasury/domain/repositories/treasury_repository.dart';
import '../../features/treasury/presentation/cubits/treasury_cubit.dart';
import '../../features/workshop/data/datasources/workshop_local_datasource.dart';
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

  final dbHelper = DatabaseHelper.instance;
  sl.registerLazySingleton<DatabaseHelper>(() => dbHelper);
  await dbHelper.ensureSeedData();

  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // ==========================================================
  //  Treasury Feature
  // ==========================================================
  sl.registerLazySingleton(() => TreasuryLocalDataSource(sl()));
  sl.registerLazySingleton<TreasuryRepository>(() => TreasuryRepositoryImpl(sl()));
  sl.registerFactory(() => TreasuryCubit(sl()));

  // ==========================================================
  //  Workshop Feature (read-only seed data)
  // ==========================================================
  sl.registerLazySingleton(() => WorkshopLocalDataSource(sl()));

  // ==========================================================
  //  Category Feature
  // ==========================================================
  sl.registerLazySingleton(() => CategoryLocalDataSource(sl()));
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(sl()));
  sl.registerFactory(() => CategoryCubit(sl()));

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
  sl.registerFactory(() => JobCubit(sl(), sl()));
}
