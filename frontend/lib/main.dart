import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/network/dio_provider.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/features/auth/presentation/auth_wrapper.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  setupDio();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.focusColor,
          secondary: AppColors.borderColor,
          surface: AppColors.backgroundColor,
        ),

        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF39FF14),
          selectionColor: Color(0x5539FF14),
          selectionHandleColor: Color(0xFF39FF14),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
