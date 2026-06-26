import 'package:go_router/go_router.dart';

import '../../features/category/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/persons/presentation/screens/persons_screen.dart';
import '../../features/persons/presentation/screens/person_detail_screen.dart';
import '../../features/treasury/presentation/screens/treasury_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/password_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../presentation/app_shell.dart';
import 'route_paths.dart';

final router = GoRouter(
  initialLocation: RoutePaths.splash,
  routes: [
    GoRoute(
      path: RoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RoutePaths.password,
      builder: (context, state) => const PasswordScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.persons,
              builder: (context, state) => const PersonsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.jobs,
              builder: (context, state) => const JobsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.treasury,
              builder: (context, state) => const TreasuryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: RoutePaths.reports,
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
    // ── Detail Routes (full screen, بدون bottom nav) ─────
    GoRoute(
      path: '/person/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return PersonDetailScreen(personId: id);
      },
    ),
    GoRoute(
      path: '/job/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return JobDetailScreen(jobId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.categories,
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
