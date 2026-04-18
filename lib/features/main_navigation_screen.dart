// lib/features/main_navigation_screen.dart
import 'package:ascend/core/navigation/navigation_provider.dart';
import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile/presentation/home_screen.dart';
import 'quests/presentation/quests_screen.dart';
import 'profile/presentation/stats_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const QuestsScreen(),
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
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(navigationProvider.notifier).state = index,
          backgroundColor: Colors.black.withOpacity(0.8),
          selectedItemColor: AppColors.neonBlue,
          unselectedItemColor: Colors.white24,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), 
              activeIcon: Icon(Icons.person),
              label: "STATUS"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_outlined), // Raio combina com "Quest/Energia"
              activeIcon: Icon(Icons.bolt),
              label: "QUESTS"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), 
              activeIcon: Icon(Icons.bar_chart),
              label: "STATS"
            ),
          ],
        ),
      ),
    );
  }
}
