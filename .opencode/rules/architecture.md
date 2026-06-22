# Architecture Rules — ورشتي

## Clean Architecture — Feature First

```
features/
└── workshop/
    ├── data/
    │   ├── models/
    │   │   └── workshop_model.dart             ← Equatable + fromMap/toMap
    │   └── datasources/
    │       └── workshop_local_datasource.dart  ← sqflite CRUD
    ├── domain/
    │   └── repositories/
    │       └── workshop_repository.dart        ← abstract class
    └── presentation/
        ├── cubits/
        │   ├── workshop_cubit.dart             ← Cubit
        │   └── workshop_state.dart             ← State classes
        ├── screens/
        │   ├── workshops_screen.dart
        │   └── workshop_detail_screen.dart
        └── widgets/
            ├── workshop_card.dart
            └── add_workshop_form.dart
```

## Theme Cubit (في core مش في features)

```
core/
└── theme/
    ├── app_colors.dart
    ├── app_text_styles.dart
    ├── app_theme.dart
    └── theme_cubit.dart   ← ThemeCubit + shared_preferences
```

---

## طبقات المشروع

```
UI (screens/widgets)
      ↓ BlocBuilder / BlocListener
Cubit
      ↓ استدعاء
Repository (abstract)
      ↓ تنفيذ
DataSource (sqflite)
      ↓ قراءة/كتابة
SQLite Database
```

---

## State Pattern

```dart
// workshop_state.dart
abstract class WorkshopState extends Equatable {
  const WorkshopState();

  @override
  List<Object?> get props => [];
}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopLoaded extends WorkshopState {
  final List<Workshop> workshops;
  const WorkshopLoaded(this.workshops);

  @override
  List<Object?> get props => [workshops];
}

class WorkshopError extends WorkshopState {
  final String message;
  const WorkshopError(this.message);

  @override
  List<Object?> get props => [message];
}
```

---

## Cubit Pattern

```dart
// workshop_cubit.dart
class WorkshopCubit extends Cubit<WorkshopState> {
  final WorkshopRepository _repository;

  WorkshopCubit(this._repository) : super(WorkshopInitial());

  Future<void> load() async {
    emit(WorkshopLoading());
    try {
      final workshops = await _repository.getAll();
      emit(WorkshopLoaded(workshops));
    } on AppDatabaseException catch (e) {
      emit(WorkshopError(e.message));
    }
  }

  Future<void> add(Workshop workshop) async {
    try {
      await _repository.add(workshop);
      await load(); // reload بعد الإضافة
    } on AppDatabaseException catch (e) {
      emit(WorkshopError(e.message));
    }
  }

  Future<void> toggleActive(int id, bool isActive) async {
    try {
      await _repository.toggleActive(id, isActive);
      await load();
    } on AppDatabaseException catch (e) {
      emit(WorkshopError(e.message));
    }
  }
}
```

---

## Theme Cubit (shared_preferences)

```dart
// theme_cubit.dart
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(
    _prefs.getString('theme_mode') == 'light'
      ? ThemeMode.light
      : ThemeMode.dark,
  );

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs.setString(_key, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }
}
```

```dart
// main.dart — استخدام ThemeCubit
BlocBuilder<ThemeCubit, ThemeMode>(
  builder: (context, themeMode) {
    return MaterialApp.router(
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  },
)
```

---

## BlocBuilder في الـ UI

```dart
// workshops_screen.dart
class WorkshopsScreen extends StatelessWidget {
  const WorkshopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<WorkshopCubit>()..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('الورش')),
        body: BlocBuilder<WorkshopCubit, WorkshopState>(
          builder: (context, state) {
            if (state is WorkshopLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WorkshopError) {
              return Center(child: Text(state.message));
            }
            if (state is WorkshopLoaded) {
              if (state.workshops.isEmpty) return const _EmptyState();
              return ListView.builder(
                itemCount: state.workshops.length,
                itemBuilder: (_, i) => WorkshopCard(workshop: state.workshops[i]),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddModal(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
```

---

## Dependency Injection (get_it)

```dart
// injection_container.dart
final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Theme
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // Database
  sl.registerLazySingleton(() => DatabaseHelper.instance);

  // Workshop
  sl.registerLazySingleton(() => WorkshopLocalDataSource(sl()));
  sl.registerLazySingleton<WorkshopRepository>(
    () => WorkshopRepositoryImpl(sl()),
  );
  sl.registerFactory(() => WorkshopCubit(sl()));

  // Person, Job, Treasury... نفس الـ pattern
}
```

---

## Repository Pattern

```dart
// abstract
abstract class WorkshopRepository {
  Future<List<Workshop>> getAll();
  Future<Workshop?> getById(int id);
  Future<int> add(Workshop workshop);
  Future<void> update(Workshop workshop);
  Future<void> toggleActive(int id, bool isActive);
}

// implementation
class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopLocalDataSource _dataSource;
  WorkshopRepositoryImpl(this._dataSource);

  @override
  Future<List<Workshop>> getAll() => _dataSource.getAll();

  @override
  Future<int> add(Workshop workshop) => _dataSource.insert(workshop);

  @override
  Future<void> toggleActive(int id, bool isActive) =>
      _dataSource.softDelete(id);
}
```

---

## Naming Conventions

| النوع | الاسم |
|---|---|
| Model | `Workshop` |
| DataSource | `WorkshopLocalDataSource` |
| Repository (abstract) | `WorkshopRepository` |
| Repository (impl) | `WorkshopRepositoryImpl` |
| Cubit | `WorkshopCubit` |
| State | `WorkshopState` / `WorkshopLoaded` / `WorkshopError` |
| Screen | `WorkshopsScreen` / `WorkshopDetailScreen` |
| Widget | `WorkshopCard` / `AddWorkshopForm` |
| File | `workshop_card.dart` (snake_case) |

---

## قواعد عامة

- مش تحط business logic في الـ UI
- مش تستدعي DatabaseHelper مباشرة من الـ Cubit — لازم يمر على Repository
- كل Cubit عنده states: `Initial`, `Loading`, `Loaded`, `Error`
- `BlocProvider` بيعمل `..load()` في نفس السطر
- `BlocBuilder` للـ UI، `BlocListener` للـ side effects (SnackBar, Navigation)
- `ThemeCubit` بيتحط فوق الـ `MaterialApp` في main.dart