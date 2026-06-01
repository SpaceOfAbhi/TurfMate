import 'package:flutter/material.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:frontend/features/navigation/bottom_nav.dart';
import 'package:frontend/services/auth_services.dart';
import 'package:frontend/services/location_services.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:geocoding/geocoding.dart';

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
  final locationController = TextEditingController();

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
        if (success) {
          try {
            await NotificationService().saveFcmToken();
          } catch (e) {
            print("Error saving FCM token: $e");
          }

          try {
            await LocationService().getCurrentLocation();
          } catch (e) {
            print(e);
          }
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
      } else {
        if (locationController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select your location")),
          );

          setState(() {
            isLoading = false;
          });

          return;
        }
        try {
          List<Location> locations = await locationFromAddress(
            locationController.text.trim(),
          );

          latitude = locations.first.latitude;
          longitude = locations.first.longitude;
        } catch (e) {
          ScaffoldMessenger.of(
            // ignore: use_build_context_synchronously
            context,
          ).showSnackBar(const SnackBar(content: Text("Invalid location")));
        }
        success = await authService.signup(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,

          latitude: latitude,
          longitude: longitude,
          locationName: locationController.text.trim(),
        );
      }
      if (success) {
        try {
          await NotificationService().saveFcmToken();
        } catch (e) {
          print("Error saving FCM token: $e");
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        if (!mounted) return;
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
    locationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        body: Padding(
          padding: const EdgeInsets.all(20),

          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                SizedBox(
                  height: isLogin
                      ? MediaQuery.of(context).size.height * .25
                      : MediaQuery.of(context).size.height * .15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [const AppTitle()],
                ),
                const WelcomeText(),
                const SizedBox(height: 30),

                if (!isLogin)
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                    ),
                  ),

                if (!isLogin) const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hoverColor: AppColors.focusColor,
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,

                  obscureText: true,

                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                  ),
                ),

                if (!isLogin) const SizedBox(height: 16),

                if (!isLogin)
                  TextField(
                    controller: locationController,

                    decoration: InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,

                      suffixIcon: IconButton(
                        icon: isFetchingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),

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

                              locationController.text = locationName!;

                              isFetchingLocation = false;
                            });
                          } catch (e) {
                            setState(() {
                              isFetchingLocation = false;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    ),

                    onChanged: (value) {
                      locationName = value;

                      latitude = null;
                      longitude = null;
                    },
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.borderColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: isLoading ? null : submit,

                    child: isLoading
                        ? const SizedBox(
                            height: 30,
                            width: 20,
                            child: CircularProgressIndicator(),
                          )
                        : Text(isLogin ? "Login ⚽" : "Sign Up ⚽"),
                  ),
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
        ),
      ),
    );
  }
}
