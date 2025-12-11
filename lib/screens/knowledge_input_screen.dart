import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; 

class KnowledgeInputScreen extends StatefulWidget {
  final List<String> genres;

  const KnowledgeInputScreen({
    super.key,
    required this.genres,
  });

  static String? savedGenre;

  @override
  State<KnowledgeInputScreen> createState() => _KnowledgeInputScreenState();
}

class _KnowledgeInputScreenState extends State<KnowledgeInputScreen> {
  final TextEditingController _textController = TextEditingController();
  String? _selectedGenre;
  
 
  bool _isEating = false;

  @override
  void initState() {
    super.initState();

    // ホーム画面やタイマー画面と同期
    if (KnowledgeInputScreen.savedGenre != null &&
        widget.genres.contains(KnowledgeInputScreen.savedGenre)) {
      _selectedGenre = KnowledgeInputScreen.savedGenre;
    } else if (widget.genres.isNotEmpty) {
      _selectedGenre = widget.genres.first;
    }
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

    
    FocusScope.of(context).unfocus();

    // 食事モードを開始（画像を表示）
    setState(() {
      _isEating = true;
    });

    try {
     
      await Future.wait([
        // 1. Firestore処理
        _saveToFirestore(text, genre),
        // 2. アニメーション用ウェイト(2s)
        Future.delayed(const Duration(seconds: 2)),
      ]);
      
    } catch (e) {
      if (mounted) {
        // エラー時は食事モードを解除してメッセージ表示
        setState(() {
          _isEating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // Firestoreへの保存処理を分離
  Future<void> _saveToFirestore(String text, String genre) async {
    // 1. 知識の記録
    await FirebaseFirestore.instance.collection('knowledge').add({
      'knowledge': text,
      'genre': genre,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // 2. モンスターの成長ロジック
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final monsterRef =
          FirebaseFirestore.instance.collection('monsters').doc(genre);
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
    
      body: Stack(
        children: [
          // --- 1. 通常の入力フォーム ---
          Padding(
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
                   
                    enabled: !_isEating, 
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
                    onChanged: _isEating ? null : (String? newValue) { // 食事中は変更不可
                      setState(() {
                        _selectedGenre = newValue;
                        KnowledgeInputScreen.savedGenre = newValue;
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
                    // 食事中はボタンを押せないようにする
                    onPressed: _isEating ? null : _feedMonster,
                    child: const Text('モンスターに食べさせる！'),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. 食事中のアニメーションオーバーレイ ---
          if (_isEating)
            Container(
              color: const Color.fromARGB(255, 227, 221, 221).withOpacity(0.5), 
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Image.asset(
                      'assets/images/eatingLogo.png', 
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'もぐもぐ...',
                      style: TextStyle(
                        color: Color.fromARGB(255, 108, 73, 73),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}