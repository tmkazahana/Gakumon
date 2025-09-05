import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreの機能を追加

// 知識入力画面のウィジェット
class KnowledgeInputScreen extends StatefulWidget {
  const KnowledgeInputScreen({super.key});

  @override
  State<KnowledgeInputScreen> createState() => _KnowledgeInputScreenState();
}

class _KnowledgeInputScreenState extends State<KnowledgeInputScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedGenre = 'プログラミング';
  final List<String> _genres = ['プログラミング', 'デザイン', 'マーケティング', '語学', 'その他'];

  // ★ ボタンが押されたときの処理をasyncに変更
  Future<void> _feedMonster() async {
    final text = _textController.text;
    final genre = _selectedGenre ?? 'その他';

    if (text.isEmpty) {
      return; // テキストが空なら何もしない
    }

    // ★ ここでFirestoreにデータを保存する
    await FirebaseFirestore.instance.collection('knowledge').add({
      'text': text, // 入力された知識
      'genre': genre, // 選択されたジャンル
      'timestamp': FieldValue.serverTimestamp(), // 保存した日時
    });

    // 保存が終わったら、ホーム画面に戻る
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知識の入力'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '学んだことを入力',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              decoration: const InputDecoration(
                labelText: 'ジャンル',
                border: OutlineInputBorder(),
              ),
              items: _genres.map((String genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGenre = newValue;
                });
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              // ★ ボタンが押されたら_feedMonsterを実行
              onPressed: _feedMonster,
              child: const Text(
                'モンスターに食べさせる！',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}