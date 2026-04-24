import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/core/widgets/reveal_block.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.backgroundElevated,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RevealBlock(
                      child: Container(
                        key: const ValueKey('login-hero'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.neonBlue.withValues(alpha: 0.12),
                              AppColors.surface.withValues(alpha: 0.96),
                              AppColors.surfaceMuted.withValues(alpha: 0.98),
                            ],
                          ),
                          border: Border.all(color: AppColors.borderStrong),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ascend',
                              style: textTheme.labelMedium?.copyWith(
                                color: AppColors.neonBlue,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Rotina com peso de jogo',
                              style: textTheme.headlineLarge?.copyWith(
                                fontSize: 34,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Entre, escolha um foco e comece sua primeira semana sem enrolacao.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                _HeroChip(
                                  label: 'Monte sua primeira semana',
                                  accent: AppColors.neonBlue,
                                ),
                                _HeroChip(
                                  label: 'Acompanhe seu ritmo',
                                  accent: AppColors.questAccent,
                                ),
                                _HeroChip(
                                  label: 'Suba quando a arena abrir',
                                  accent: AppColors.arenaAccent,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    RevealBlock(
                      delay: const Duration(milliseconds: 90),
                      child: Container(
                        key: const ValueKey('login-auth-panel'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceStrong.withValues(
                            alpha: 0.82,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderStrong),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Primeiro passo',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Use sua conta Google para salvar progresso, continuar em outro aparelho e manter sua conta protegida.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 18),
                            if (state is AuthLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: CircularProgressIndicator(
                                    color: AppColors.neonBlue,
                                  ),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  key: const ValueKey('login-google-button'),
                                  onPressed: () => ref
                                      .read(authProvider.notifier)
                                      .signInWithGoogle(),
                                  icon: const Icon(Icons.login_rounded),
                                  label: const Text('Continuar com Google'),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              'A configuracao inicial leva poucos segundos.',
                              style: textTheme.bodySmall,
                            ),
                            if (state is AuthFailure) ...[
                              const SizedBox(height: 14),
                              Container(
                                key: const ValueKey('login-error-panel'),
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.danger.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  state.message,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceStrong.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
