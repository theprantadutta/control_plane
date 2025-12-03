import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'presentation/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Starting Freeway Control Panel...', 'App');

  try {
    await dotenv.load(fileName: '.env');
    AppLogger.info('Environment loaded successfully', 'App');
  } catch (e) {
    AppLogger.warning('Failed to load .env file: $e', 'App');
  }

  runApp(
    const ProviderScope(
      child: FreewayControlPanel(),
    ),
  );
}

class FreewayControlPanel extends ConsumerWidget {
  const FreewayControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Freeway Control Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
