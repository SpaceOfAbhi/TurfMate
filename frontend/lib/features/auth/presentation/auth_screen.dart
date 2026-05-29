import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/bottom_nav.dart';
import 'package:frontend/services/auth_services.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;

  final AuthService authService = AuthService();

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  Future<void> submit() async {
    setState(() {
      isLoading = true;
    });

    bool success = false;

    try {
      if (isLogin) {
        success = await authService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        success = await authService.signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,

          // Temporary values
          latitude: 9.9312,
          longitude: 76.2673,
          locationName: "Kochi",
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Authentication Failed")));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Create Account")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 30),

            if (!isLogin)
              TextField(
                controller: nameController,

                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),

            if (!isLogin) const SizedBox(height: 16),

            TextField(
              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isLoading ? null : submit,

              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    )
                  : Text(isLogin ? "Login" : "Sign Up"),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },

              child: Text(
                isLogin
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Login",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
