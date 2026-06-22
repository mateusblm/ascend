import 'dart:async';

import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/awakening_onboarding_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/profile/presentation/rank_progression_provider.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile/presentation/home_screen.dart';
import 'profile/presentation/rank_screen.dart';
import 'quests/presentation/quests_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with WidgetsBindingObserver {
  Timer? _syncDebounce;
  static const _destinations = <_NavigationDestination>[
    _NavigationDestination(
      label: 'Base',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      accent: AppColors.neonBlue,
    ),
    _NavigationDestination(
      label: 'Quests',
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt_rounded,
      accent: AppColors.questAccent,
    ),
    _NavigationDestination(
      label: 'Arena',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      accent: AppColors.arenaAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Mantem a sync competitiva desacoplada da avaliacao de providers e evita
    // chamadas redundantes ao Firestore durante sequencias rapidas de rebuild.
    ref.listenManual(playerProvider, (_, next) {
      _scheduleCompetitiveSync(next);
    });
    ref.listenManual(questProvider, (_, __) {
      _scheduleCompetitiveSync(ref.read(playerProvider));
    });
    ref.listenManual(authProvider, (previous, next) {
      if (previous is AuthSuccess && next is! AuthSuccess) {
        _syncDebounce?.cancel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questProvider.notifier).ensureDailyReset();
      _scheduleCompetitiveSync(ref.read(playerProvider), delay: Duration.zero);
    });
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(authProvider.notifier).refreshActiveSession());
      ref.read(questProvider.notifier).ensureDailyReset();
      _scheduleCompetitiveSync(ref.read(playerProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final requiresOnboarding = _requiresOnboarding(player, quests.isNotEmpty);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final screens = <Widget>[
      const HomeScreen(),
      const QuestsScreen(),
      const RankScreen(),
    ];
    final safeIndex = currentIndex.clamp(0, screens.length - 1);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.backgroundElevated,
            Color(0xFF050A0F),
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _SystemAtmosphere()),
          Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: requiresOnboarding
                ? const AwakeningOnboardingScreen()
                : IndexedStack(index: safeIndex, children: screens),
            bottomNavigationBar: requiresOnboarding || keyboardOpen
                ? null
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: _FloatingBottomDock(
                      currentIndex: safeIndex,
                      destinations: _destinations,
                      onTap: (index) =>
                          ref.read(navigationProvider.notifier).state = index,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool _requiresOnboarding(Player player, bool hasExistingQuests) {
    if (player.hasCompletedOnboarding) return false;

    final hasProgress =
        player.level > 1 ||
        player.xp > 0 ||
        player.currentStreak > 0 ||
        player.bestStreak > 0 ||
        player.activityHistory.isNotEmpty ||
        hasExistingQuests;

    return !hasProgress;
  }

  void _scheduleCompetitiveSync(
    Player player, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    if (ref.read(authProvider) is! AuthSuccess) {
      _syncDebounce?.cancel();
      return;
    }

    _syncDebounce?.cancel();
    _syncDebounce = Timer(delay, () {
      if (!mounted || ref.read(authProvider) is! AuthSuccess) {
        return;
      }

      final repository = ref.read(rankProgressionRepositoryProvider);
      final quests = ref.read(questProvider);
      repository.syncCompetitiveState(player);
      repository.syncCompetitiveIntegrity(player: player, quests: quests);
    });
  }
}

class _FloatingBottomDock extends StatelessWidget {
  const _FloatingBottomDock({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavigationDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.surfaceStrong.withValues(alpha: 0.90),
          border: Border.all(color: AppColors.borderStrong),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.03),
                Colors.white.withValues(alpha: 0.01),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              for (var index = 0; index < destinations.length; index++)
                Expanded(
                  child: _DockItem(
                    destination: destinations[index],
                    selected: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = destination.accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.surfaceMuted
                      : Colors.white.withValues(alpha: 0.03),
                  border: Border.all(
                    color: selected
                        ? accent.withValues(alpha: 0.26)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Icon(
                  selected ? destination.activeIcon : destination.icon,
                  color: selected ? accent : AppColors.textMuted,
                  size: 20,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: 0.2,
                  color: selected ? Colors.white : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemAtmosphere extends StatelessWidget {
  const _SystemAtmosphere();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _SystemAtmospherePainter()),
    );
  }
}

class _SystemAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundWash = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF070A10), Color(0xFF0B111A), Color(0xFF07080D)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, backgroundWash);

    final riftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.neonBlue.withValues(alpha: 0.075);
    final amberPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = AppColors.arenaAccent.withValues(alpha: 0.052);
    final veilPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.neonPurple.withValues(alpha: 0.032);

    final leftRift = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width * 0.40, size.height * 0.26)
      ..lineTo(size.width * 0.24, size.height * 0.53)
      ..lineTo(size.width * 0.56, size.height * 0.84);
    canvas.drawPath(leftRift, riftPaint);

    final rightRift = Path()
      ..moveTo(size.width * 0.96, size.height * 0.10)
      ..lineTo(size.width * 0.64, size.height * 0.32)
      ..lineTo(size.width * 0.83, size.height * 0.58)
      ..lineTo(size.width * 0.58, size.height);
    canvas.drawPath(rightRift, amberPaint);

    final veil = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.64)
      ..lineTo(size.width * 0.78, size.height * 0.46)
      ..lineTo(size.width * 0.90, size.height * 0.18)
      ..close();
    canvas.drawPath(veil, veilPaint);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = AppColors.borderSubtle.withValues(alpha: 0.50);
    for (var y = size.height * 0.18; y < size.height; y += 86) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + size.width * 0.18),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NavigationDestination {
  const _NavigationDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color accent;
}
