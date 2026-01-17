import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:serve_ease_new/screens/auth/customer_login_screen.dart';
import 'package:serve_ease_new/screens/auth/customer_register_screen.dart';
import 'package:serve_ease_new/screens/dashboards/customer_dashboard_screen.dart';
import 'package:serve_ease_new/screens/onboarding/onboarding_screen.dart';
import 'package:serve_ease_new/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBPdETbDdPsx7hkETmqhyV7zHESCyI8zmE",
      appId: "1:694730753179:android:5264a0845fc666a232f23e",
      messagingSenderId: "694730753179",
      projectId: "serveease-4cb36",
      storageBucket: "serveease-4cb36.firebasestorage.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServeEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF185ADB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185ADB)),
        useMaterial3: true,
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF185ADB)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF185ADB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const CustomerLoginScreen(),
        '/register': (context) => const CustomerRegisterScreen(),
        '/dashboard': (context) => const CustomerDashboardScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
      },
    );
  }
}