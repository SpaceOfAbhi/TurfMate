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

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  final screens = const [HomeScreen(), CreateMatchScreen(), MyMatchesScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[currentIndex],

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
    
        decoration: BoxDecoration(
          color:AppColors.backgroundColor,

          borderRadius: BorderRadius.circular(30),

          boxShadow: [
            BoxShadow(
              color: AppColors.focusColor.withOpacity(0.5),

              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          
          backgroundColor:Colors.transparent,
          unselectedItemColor: Colors.white,
          selectedItemColor: AppColors.focusColor,
          currentIndex: currentIndex,
          iconSize: 30,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: "Create",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: "My Matches",
            ),
          ],
        ),
      ),
    );
  }
}
