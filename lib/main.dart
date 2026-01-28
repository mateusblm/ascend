import 'package:ascend/features/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:isar/isar.dart'; // Import do Isar
import 'package:path_provider/path_provider.dart'; // Para o caminho do DB

// Importe seus modelos para o Isar conhecer os Schemas
import 'features/profile/domain/player_model.dart';
import 'features/quests/domain/quest_model.dart';

import 'core/theme/app_colors.dart';
import 'features/profile/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/domain/auth_state.dart';

// 1. DECLARAÇÃO GLOBAL (Onde o erro morre)
// Isso permite que qualquer arquivo use 'isar' após o import do main.dart
late Isar isar;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  // 2. INICIALIZAÇÃO DO BANCO
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [PlayerSchema, QuestSchema], // Se der erro aqui, rode o build_runner
    directory: dir.path,
  );

  runApp(
    const ProviderScope(
      child: AscendApp(),
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
      home: authState is AuthSuccess 
          ? const MainNavigationScreen()
          : const LoginScreen(),
    );
  }
}