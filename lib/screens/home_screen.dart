// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'monster_screen.dart';
import 'book_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'stomach_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'メニュー',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('図鑑'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('タイマー'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          size: 36,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. タップできるばけもの画像
            GestureDetector(
              onTap: () {
                // タップしたら胃の画面（StomachScreen）に移動
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StomachScreen()),
                );
              },
              child: Image.asset(
                'assets/images/logo1.gif', 
                width: 250,
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 40), 

            // 2. 育成画面に行くボタン
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