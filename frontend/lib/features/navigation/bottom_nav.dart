import 'package:flutter/material.dart';
import 'package:frontend/features/match/presentation/create_match.dart';
import 'package:frontend/features/match/presentation/my_matches.dart';

import '../home/presentation/home_screen.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int currentIndex = 0;

  final screens = const [
    HomeScreen(),
    CreateMatchScreen(),
    MyMatchesScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: screens[currentIndex],

      bottomNavigationBar:
          BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {

          setState(() {
            currentIndex = index;
          });
        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

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
    );
  }
}