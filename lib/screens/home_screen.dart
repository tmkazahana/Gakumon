// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'monster_screen.dart';

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
                Navigator.pop(context); // ドロワーを閉じる
                // TODO: 図鑑ページへ遷移
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant), // 仮の胃アイコン
              title: const Text('胃'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 胃ページへ遷移
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 設定ページへ遷移
              },
            ),
          ],
        ),
      ),
      // --- AppBar ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
       
        iconTheme: IconThemeData(
          size: 36, 
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      // --- Body ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo1.gif',
              width: 200,
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
