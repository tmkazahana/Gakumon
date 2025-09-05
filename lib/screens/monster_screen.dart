// lib/screens/monster_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'knowledge_input_screen.dart';

class MonsterScreen extends StatelessWidget {
  const MonsterScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ★戻るボタン
              Align(
                alignment: Alignment.topLeft,
                child: SafeArea( // ステータスバーと被らないように
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // 前の画面（メニュー）に戻る
                    },
                  ),
                ),
              ),
              const Spacer(), // 中央寄せのスペース

              Image.asset(
                'assets/images/logo1.gif',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),

              _buildLatestKnowledgeDisplay(),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const KnowledgeInputScreen()),
                  );
                },
                child: const Text('知識をあげる'),
              ),
              const Spacer(), // 中央寄せのスペース
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestKnowledgeDisplay() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('knowledge')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text('エラーが発生しました');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            'モンスターはまだ空腹だ...',
            style: TextStyle(fontSize: 20),
          );
        }
        final latestKnowledge = snapshot.data!.docs.first;
        final text = latestKnowledge['text'] as String? ?? 'データなし';
        final genre = latestKnowledge['genre'] as String? ?? '不明';

        return Text(
          '「$text」($genre) を食べた！',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}