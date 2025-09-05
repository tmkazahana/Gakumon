import 'package:flutter/material.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('図鑑')),
      body: const Center(
        child: Text(
          'ここに図鑑の内容を表示',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
