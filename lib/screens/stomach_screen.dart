import 'package:flutter/material.dart';

class StomachScreen extends StatelessWidget {
  const StomachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('胃')),
      body: const Center(
        child: Text(
          'ここに胃の内容',//カレンダー表示？
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
