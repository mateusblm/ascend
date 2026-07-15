import 'dart:async';

import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:ascend/features/auth/domain/auth_state.dart';
import 'package:ascend/features/auth/presentation/auth_controller.dart';
import 'package:ascend/features/profile/domain/player_model.dart';
import 'package:ascend/features/profile/presentation/awakening_onboarding_screen.dart';
import 'package:ascend/features/profile/presentation/player_controller.dart';
import 'package:ascend/features/quests/presentation/quest_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile/presentation/home_screen.dart';
import 'jornadas/presentation/jornadas_screen.dart';
import 'quests/presentation/quests_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with WidgetsBindingObserver {
  static const _destinations = <_NavigationDestination>[
    _NavigationDestination(
      label: 'Base',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      accent: AppColors.ascension,
    ),
    _NavigationDestination(
      label: 'Missões',
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt_rounded,
      accent: AppColors.ascension,
    ),
    _NavigationDestination(
      label: 'Jornadas',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      accent: AppColors.ascension,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ref.listenManual(authProvider, (previous, next) {
      if (previous is AuthSuccess && next is! AuthSuccess) {}
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questProvider.notifier).ensureDailyReset();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(authProvider.notifier).refreshActiveSession());
      ref.read(questProvider.notifier).ensureDailyReset();
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
      const JornadasScreen(),
    ];
    final safeIndex = currentIndex.clamp(0, screens.length - 1);

    return Container(
      decoration: BoxDecoration(color: AppColors.background),
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
                : _FloatingBottomDock(
                    currentIndex: safeIndex,
                    destinations: _destinations,
                    onTap: (index) =>
                        ref.read(navigationProvider.notifier).state = index,
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
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderStrong)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        borderRadius: BorderRadius.zero,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: selected ? accent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.activeIcon : destination.icon,
                color: selected ? accent : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: 0,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
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
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.background);

    final contorno = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .8
      ..color = AppColors.textPrimary.withValues(alpha: .055);
    _desenharIlhaDeRelevo(
      canvas,
      size,
      centro: Offset(size.width * .78, size.height * .12),
      raio: size.width * .42,
      tinta: contorno,
    );
    _desenharIlhaDeRelevo(
      canvas,
      size,
      centro: Offset(size.width * .02, size.height * .62),
      raio: size.width * .50,
      tinta: contorno,
    );
  }

  void _desenharIlhaDeRelevo(
    Canvas canvas,
    Size size, {
    required Offset centro,
    required double raio,
    required Paint tinta,
  }) {
    for (var indice = 0; indice < 4; indice++) {
      final escala = 1 - (indice * .16);
      final caminho = Path()
        ..moveTo(centro.dx - raio * escala, centro.dy)
        ..cubicTo(
          centro.dx - raio * escala,
          centro.dy - raio * .58 * escala,
          centro.dx - raio * .24 * escala,
          centro.dy - raio * .76 * escala,
          centro.dx + raio * .34 * escala,
          centro.dy - raio * .58 * escala,
        )
        ..cubicTo(
          centro.dx + raio * .86 * escala,
          centro.dy - raio * .30 * escala,
          centro.dx + raio * .82 * escala,
          centro.dy + raio * .43 * escala,
          centro.dx + raio * .18 * escala,
          centro.dy + raio * .66 * escala,
        )
        ..cubicTo(
          centro.dx - raio * .50 * escala,
          centro.dy + raio * .68 * escala,
          centro.dx - raio * .90 * escala,
          centro.dy + raio * .28 * escala,
          centro.dx - raio * escala,
          centro.dy,
        );
      canvas.drawPath(caminho, tinta);
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
