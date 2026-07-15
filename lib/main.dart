import 'dart:async';
import 'dart:ui';

import 'package:ascend/core/widgets/system/ascend_system_catalog_screen.dart';

import 'package:ascend/core/analytics/analytics_service.dart';
import 'package:ascend/core/crash/crash_reporting_service.dart';
import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/core/theme/app_theme.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/auth/presentation/login_screen.dart';
import 'package:ascend/features/main_navigation_screen.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  AppCrashReporter crashReporter = const NoopAppCrashReporter();

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      crashReporter = buildAppCrashReporter();
      await crashReporter.initialize();

      final dir = await getApplicationDocumentsDirectory();
      final isar = await Isar.open([
        PlayerSchema,
        QuestSchema,
      ], directory: dir.path);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        unawaited(crashReporter.recordFlutterFatal(details));
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          crashReporter.recordError(
            error,
            stack,
            reason: 'platform_dispatcher',
            fatal: true,
          ),
        );
        return true;
      };

      runApp(
        ProviderScope(
          overrides: [
            isarProvider.overrideWithValue(isar),
            crashReportingProvider.overrideWithValue(crashReporter),
          ],
          observers: [CrashReportingObserver(crashReporter)],
          child: const AscendApp(),
        ),
      );
    },
    (error, stack) {
      unawaited(
        crashReporter.recordError(
          error,
          stack,
          reason: 'run_zoned_guarded',
          fatal: true,
        ),
      );
    },
  );
}

class AscendApp extends ConsumerWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final analyticsObserver = ref.watch(analyticsNavigationObserverProvider);

    return MaterialApp(
      title: 'Ascend RPG',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [if (analyticsObserver != null) analyticsObserver],
      routes: {
        if (const bool.fromEnvironment('dart.vm.product') == false)
          '/system-catalog': (_) => const AscendSystemCatalogScreen(),
      },
      theme: AppTheme.dark(),
      home: authState is AuthSuccess
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}
