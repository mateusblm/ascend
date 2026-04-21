import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/reveal_block.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const RevealBlock(
                child: Text(
                  "ASCEND",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonBlue,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const RevealBlock(
                delay: Duration(milliseconds: 80),
                child: Text(
                  "ROTINA COM PESO DE JOGO",
                  style: TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ),
              const SizedBox(height: 14),
              const RevealBlock(
                delay: Duration(milliseconds: 140),
                child: Text(
                  "Entre para montar sua primeira semana, acompanhar seu crescimento e dar mais peso ao que voce faz no dia a dia.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white54,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const RevealBlock(
                delay: Duration(milliseconds: 200),
                child: Column(
                  children: [
                    _LoginPoint('Monte um kit inicial de quests.'),
                    SizedBox(height: 8),
                    _LoginPoint('Use quests de rank para subir seu posto.'),
                    SizedBox(height: 8),
                    _LoginPoint('Mantenha seu ritmo semana apos semana.'),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              if (state is AuthLoading)
                const CircularProgressIndicator(color: AppColors.neonBlue)
              else ...[
                RevealBlock(
                  delay: const Duration(milliseconds: 260),
                  child: ElevatedButton.icon(
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
      ),
    );
  }
}

class _LoginPoint extends StatelessWidget {
  const _LoginPoint(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 16, color: AppColors.neonBlue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12.5,
          ),
        ),
      ],
    );
  }
}
