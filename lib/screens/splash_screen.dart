//splash_screen.dart
// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:gakumon_app_01/screens/genre_select_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
 
    _controller = AnimationController(
      duration: const Duration(seconds: 2), 
      vsync: this,
    );

   
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // アニメーションを開始
    _controller.forward();
  }

  @override
  void dispose() {    
    _controller.dispose();
    super.dispose();
  }

  void navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GenreSelectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: navigateToHome,       
        child: FadeTransition(
          opacity: _animation, 
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'がくモン',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Image.asset('assets/images/logo1.gif', width: 150),
                const SizedBox(height: 48),
                Text(
                  'タップしてはじめる',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
