import 'package:flutter/material.dart';
import 'package:mohit_app/screens/GettingStartedScreen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'screens/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () async {



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GettingStartedScreen()),
      );

    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFF9C27B0), // Purple
              Color(0xFFFF7043), // Orange
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              "assets/logo57.gif",
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
