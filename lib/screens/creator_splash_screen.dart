import 'dart:async';
import 'package:flutter/material.dart';
import 'splash_screen.dart'; 

class CreatorSplashScreen extends StatefulWidget {
  const CreatorSplashScreen({super.key});

  @override
  State<CreatorSplashScreen> createState() => _CreatorSplashScreenState();
}

class _CreatorSplashScreenState extends State<CreatorSplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SplashScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/team_name2.jpg',
          width: 200,
        ),
      ),
    );
  }
}