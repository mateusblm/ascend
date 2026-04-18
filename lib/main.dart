import 'package:ascend/core/database/isar_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/auth/presentation/login_screen.dart';
import 'package:ascend/features/main_navigation_screen.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/quests/domain/quest_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [PlayerSchema, QuestSchema],
    directory: dir.path,
  );

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const AscendApp(),
    ),
  );
}

class AscendApp extends ConsumerWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'Ascend RPG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.orbitronTextTheme(
          ThemeData.dark().textTheme.apply(bodyColor: AppColors.systemText),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonBlue,
          secondary: AppColors.neonPurple,
          surface: AppColors.surface,
        ),
      ),
      home: authState is AuthSuccess ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
