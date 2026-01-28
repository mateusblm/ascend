import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // Adicione este import

// Imports do seu projeto
import 'core/theme/app_colors.dart';
import 'features/profile/presentation/home_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/domain/auth_state.dart';

void main() async {
  // Como dev Java, pense nisso como garantir que o Spring Boot inicie o contexto 
  // antes de tentar injetar qualquer Bean.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase (exige as configs do google-services.json)
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: AscendApp(),
    ),
  );
}

// Alterado para ConsumerWidget para acessar o 'ref'
class AscendApp extends ConsumerWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escutando o estado de autenticação
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
      // Lógica de roteamento baseada no estado do Google Auth
      home: authState is AuthSuccess 
          ? const HomeScreen() 
          : const LoginScreen(),
    );
  }
}