import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/features/dashboard/dashboard_screen.dart';
import '../../presentation/features/models/models_screen.dart';
import '../../presentation/features/projects/projects_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/shared/widgets/app_scaffold.dart';

/// Navigation shell key
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App routes
class AppRoutes {
  static const dashboard = '/';
  static const models = '/models';
  static const projects = '/projects';
  static const settings = '/settings';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.models,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ModelsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.projects,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProjectsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
