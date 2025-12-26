import 'dart:async';
import 'package:flutter/material.dart';
import 'package:policy_dukaan/utils/app_colors.dart';
import '../session_manager.dart';
import 'login_screen.dart';
import 'tab_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    print('🔍 Checking login status...');

    // Check if user is logged in
    final isLoggedIn = await _sessionManager.isLoggedIn();

    if (isLoggedIn) {
      // Get user data for logging
      final userData = await _sessionManager.getUserData();
      final token = await _sessionManager.getToken();

      print('✅ User is already logged in!');
      print('👤 User: ${userData?['name']} (${userData?['email']})');
      print('🔑 Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');

      // Navigate to TabScreen (Home)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const TabScreen(initialIndex: 0),
          ),
        );
      }
    } else {
      print('❌ User is not logged in, redirecting to login...');

      // Navigate to LoginScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/PDlogo.png',
                height: 40,
                width: 40,
              ),
            ),

            const SizedBox(height: 20),

            // App Name
            const Text(
              'Policy Dukaan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Loader
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}