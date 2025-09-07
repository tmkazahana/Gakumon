import 'package:flutter/material.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タイマー')),
      body: const Center(
        child: Text(
          'ばけもの散歩＆タイマー機能',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
