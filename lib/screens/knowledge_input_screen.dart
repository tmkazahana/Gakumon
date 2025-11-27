// lib/screens/knowledge_input_screen.dart (または該当パス)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class KnowledgeInputScreen extends StatefulWidget {
  final List<String> genres; 
  final String initialGenre; 
  
  const KnowledgeInputScreen({
    super.key, 
    required this.genres, 
    required this.initialGenre,
  });

  @override
  State<KnowledgeInputScreen> createState() => _KnowledgeInputScreenState();
}

class _KnowledgeInputScreenState extends State<KnowledgeInputScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedGenre; 

  @override
  void initState() {
    super.initState();
    _selectedGenre = widget.initialGenre; 
  }

  Future<void> _feedMonster() async {
    final text = _textController.text.trim();
    final genre = _selectedGenre; 

    if (text.isEmpty || genre == null) { 
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('学んだ内容とジャンルを選択してください')),
          );
      }
      return;
    }

    // 1. 知識の記録
    await FirebaseFirestore.instance.collection('knowledge').add({
      'knowledge': text, 
      'genre': genre,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. モンスターの成長ロジック
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final monsterRef = FirebaseFirestore.instance.collection('monsters').doc(genre);
        final monsterSnapshot = await transaction.get(monsterRef);

        if (!monsterSnapshot.exists) {
            return;
        }

        int currentExp = (monsterSnapshot.data()?['experience'] as int? ?? 0);
        int currentLevel = (monsterSnapshot.data()?['level'] as int? ?? 0);
        
        currentExp += 10; 
        
        if (currentExp >= 100) { 
          currentLevel += 1;
          currentExp = 0;
        }

        transaction.update(monsterRef, {
          'experience': currentExp,
          'level': currentLevel,
          'last_fed': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('モンスターの成長記録に失敗しました: $e')),
        );
      }
      return;
    }


    if (mounted) {
      // 成功時に true を返して画面を閉じる (このロジックは変更なし)
      Navigator.pop(context, true); 
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
        child: SingleChildScrollView( 
          child: Column(
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
                items: widget.genres.map((String genre) { 
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
                  minimumSize: const Size(400, 48), 
                ),
                onPressed: _feedMonster,
                child: const Text('モンスターに食べさせる！'),
              ),
            ],
          ),
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