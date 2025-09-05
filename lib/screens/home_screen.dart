// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'monster_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo1.gif',
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'メニュー',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MonsterScreen()),
                );
              },
              child: const Text('育成をはじめる', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}