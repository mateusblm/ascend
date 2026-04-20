import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'auth_controller.dart';
import '../domain/auth_state.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ASCEND",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.neonBlue,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "PROGRESSAO PESSOAL EM MODO RPG",
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Entre para acompanhar suas quests, proteger seu rank e evoluir semana apos semana.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white54,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 60),
            
            if (state is AuthLoading)
              const CircularProgressIndicator(color: AppColors.neonBlue)
            else ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  side: const BorderSide(color: AppColors.neonBlue),
                ),
                onPressed: () => ref.read(authProvider.notifier).signInWithGoogle(),
                icon: const Icon(Icons.login, color: AppColors.neonBlue),
                label: const Text("ENTRAR COM GOOGLE"),
              ),
              if (state is AuthFailure)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(state.message, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
