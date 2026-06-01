import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/features/match/presentation/create_match.dart';
import 'package:frontend/features/match/presentation/my_matches.dart';

import '../home/presentation/home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late TabController _tabController;

  final screens = const [HomeScreen(), CreateMatchScreen(), MyMatchesScreen()];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget navItem(IconData icon, String label, {required bool selected}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? AppColors.focusColor : Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: selected ? 14 : 12,
              color: selected ? AppColors.focusColor : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: AppColors.focusColor.withOpacity(0.4), blurRadius: 35),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide.none,
            ),
            dividerColor: Colors.transparent,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            tabs: [
              navItem(Icons.home, "Home", selected: currentIndex == 0),
              navItem(
                Icons.add_circle,
                "Create",
                selected: currentIndex == 1,
              ),
              navItem(
                Icons.sports_soccer,
                "Matches",
                selected: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
