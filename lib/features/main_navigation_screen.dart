// lib/features/main_navigation_screen.dart
import 'dart:async';

import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
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
import 'profile/presentation/stats_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  Timer? _syncDebounce;

  @override
  void initState() {
    super.initState();

    // Sync competitiva com debounce — evita chamadas redundantes ao Firestore
    // durante rebuilds rápidos.
    ref.listenManual(playerProvider, (_, next) {
      _syncDebounce?.cancel();
      _syncDebounce = Timer(const Duration(milliseconds: 500), () {
        ref.read(rankProgressionRepositoryProvider).syncCompetitiveState(next);
      });
    });
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);
    final player = ref.watch(playerProvider);
    final quests = ref.watch(questProvider);
    final requiresOnboarding = _requiresOnboarding(player, quests.isNotEmpty);

    final List<Widget> screens = [
      const HomeScreen(),
      const QuestsScreen(),
      const RankScreen(),
      const StatsScreen(),
    ];

    return Container(
      // O Gradiente de fundo fica aqui, fixo para todas as telas
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.5,
          colors: [AppColors.background, Colors.black],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Importante!
        body: requiresOnboarding
            ? const AwakeningOnboardingScreen()
            : IndexedStack(
                index: currentIndex,
                children: screens,
              ),
        bottomNavigationBar: requiresOnboarding
            ? null
            : BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) => ref.read(navigationProvider.notifier).state = index,
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                selectedItemColor: AppColors.neonBlue,
                unselectedItemColor: Colors.white24,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: "STATUS",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bolt_outlined),
                    activeIcon: Icon(Icons.bolt),
                    label: "QUESTS",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart_outlined),
                    activeIcon: Icon(Icons.bar_chart),
                    label: "RANK",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined),
                    activeIcon: Icon(Icons.analytics),
                    label: "STATS",
                  ),
                ],
              ),
      ),
    );
  }

  bool _requiresOnboarding(Player player, bool hasExistingQuests) {
    if (player.hasCompletedOnboarding) return false;

    final hasProgress = player.level > 1 ||
        player.xp > 0 ||
        player.currentStreak > 0 ||
        player.bestStreak > 0 ||
        player.activityHistory.isNotEmpty ||
        hasExistingQuests;

    return !hasProgress;
  }
}
