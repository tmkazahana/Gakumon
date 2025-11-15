// genre_select_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gakumon_app_01/screens/home_screen.dart';

class GenreSelectScreen extends StatefulWidget {
  const GenreSelectScreen({Key? key}) : super(key: key);

  @override
  State<GenreSelectScreen> createState() => _GenreSelectScreenState();
}

class _GenreSelectScreenState extends State<GenreSelectScreen> {
  // 最大4つのジャンル入力用コントローラ
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  bool _isLoading = false;
  
  get monstersRef => null;

  @override
  void initState() {
    super.initState();
    // 最初のTextFieldだけに初期値をセット
    _controllers[0].text = 'プログラミング';
  }

  // Firestoreにジャンルを保存し、初期モンスターを作成/更新するメソッド
  Future<void> _saveGenres() async {
  setState(() {
    _isLoading = true;
  });

  // 入力されたジャンル名を取得（空白は除外）
  final genres = _controllers
      .map((c) => c.text.trim())
      .where((text) => text.isNotEmpty)
      .toSet()
      .toList(); // 重複排除

  if (genres.isEmpty) {
    setState(() { _isLoading = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ジャンルを1つ以上入力してください')),
    );
    return;
  }

  try {
    final monstersRef = FirebaseFirestore.instance.collection('monsters');

    // --- 既存のジャンルを全て削除 ---
    // 1. 現在の全ドキュメントを取得
    final existingDocs = await monstersRef.get();
    
    // 2. 削除用のバッチを作成
    final deleteBatch = FirebaseFirestore.instance.batch();
    
    // 3. 既存のドキュメントを全て削除キューに追加
    for (var doc in existingDocs.docs) {
      deleteBatch.delete(doc.reference);
    }
    
    // 4. 既存ジャンルを一括削除を実行
    await deleteBatch.commit(); 

    // --- 新しいジャンルを保存 ---
    final writeBatch = FirebaseFirestore.instance.batch();
    for (var genre in genres) {
      final docRef = monstersRef.doc(genre);
      writeBatch.set(docRef, {
        'genre': genre,
        'level': 0,
        'experience': 0,
        'last_fed': FieldValue.serverTimestamp(),
      });
    }
    await writeBatch.commit();

    if (mounted) {
      // 保存成功後、ホーム画面へ遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習ジャンルを選択')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '育てたいジャンルを4つまで入力してください',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    TextField(
                      controller: _controllers[i],
                      decoration: InputDecoration(
                          labelText: i == 0 
                          ? 'ジャンル ${i + 1} (例: プログラミング)' // 1つ目には例を表示
                          : 'ジャンル ${i + 1}', // 2つ目以降は例なし
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveGenres,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('保存して育てる', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
