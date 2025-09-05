import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: const Center(
        child: Text(
          'ここに設定項目を表示',//ここで目標設定とかもできたらいいよね
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
