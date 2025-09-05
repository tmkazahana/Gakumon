// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void navigateToHome() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }

    return Scaffold(
      body: InkWell(
        onTap: navigateToHome,
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
    );
  }
}