import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class KnowledgeInputScreen extends StatefulWidget {
  const KnowledgeInputScreen({super.key});

  @override
  State<KnowledgeInputScreen> createState() => _KnowledgeInputScreenState();
}

class _KnowledgeInputScreenState extends State<KnowledgeInputScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedGenre = 'プログラミング';
  final List<String> _genres = ['プログラミング', 'デザイン', 'マーケティング', '語学', 'その他'];

  Future<void> _feedMonster() async {
    final text = _textController.text;
    final genre = _selectedGenre ?? 'その他';

    if (text.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance.collection('knowledge').add({
      'knowledge': text, 
      'genre': genre,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('知識の入力'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: _feedMonster,
              child: const Text('モンスターに食べさせる！'),
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