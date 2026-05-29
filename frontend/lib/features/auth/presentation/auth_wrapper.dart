import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/bottom_nav.dart';
import 'package:frontend/services/auth_services.dart';
import 'auth_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() =>
      _AuthWrapperState();
}

class _AuthWrapperState
    extends State<AuthWrapper> {

  final AuthService authService =
      AuthService();

  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {

    final isLoggedIn =
        await authService.isLoggedIn();

    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (loggedIn == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return loggedIn!
        ? const MainNavigationScreen()
        : const AuthScreen();
  }
}