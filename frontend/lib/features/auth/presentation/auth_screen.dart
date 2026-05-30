import 'package:flutter/material.dart';
import 'package:frontend/features/navigation/bottom_nav.dart';
import 'package:frontend/services/auth_services.dart';
import 'package:frontend/services/location_services.dart';

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
  double? latitude;
  double? longitude;
  String? locationName;

  bool isFetchingLocation = false;

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
        if (latitude == null || longitude == null || locationName == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select your location")),
          );

          setState(() {
            isLoading = false;
          });

          return;
        }
        success = await authService.signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,

          latitude: latitude!,
          longitude: longitude!,
          locationName: locationName!,
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

            if (!isLogin) const SizedBox(height: 16),

            if (!isLogin)
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    setState(() {
                      isFetchingLocation = true;
                    });

                    final location = await LocationService()
                        .getCurrentLocation();

                    setState(() {
                      latitude = location["latitude"];

                      longitude = location["longitude"];

                      locationName = location["locationName"];

                      isFetchingLocation = false;
                    });
                  } catch (e) {
                    setState(() {
                      isFetchingLocation = false;
                    });

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },

                icon: const Icon(Icons.location_on),

                label: Text(
                  isFetchingLocation ? "Fetching..." : "Use Current Location",
                ),
              ),

            if (locationName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),

                child: Text(
                  "📍 $locationName",
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
