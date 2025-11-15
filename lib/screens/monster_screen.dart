// monster_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'knowledge_input_screen.dart';
import 'genre_select_screen.dart'; // 新しく作成した画面をインポート

class MonsterScreen extends StatefulWidget {
  const MonsterScreen({super.key});

  @override
  State<MonsterScreen> createState() => _MonsterScreenState();
}

class _MonsterScreenState extends State<MonsterScreen> {
  // Firestoreから登録済みのジャンルリストを取得するメソッド
  Future<List<String>> _fetchGenres() async {
    // 'monsters'コレクションから、ドキュメントをすべて取得
    final querySnapshot = await FirebaseFirestore.instance
        .collection('monsters') 
        .get();

    List<String> fetchedGenres = [];
    for (var doc in querySnapshot.docs) {
      doc.data();
      // 'genre'フィールドを持つドキュメントからジャンル名を取得（ドキュメントIDでも良いが、汎用性のためフィールドを使用）
      // monster_screen.dart (L.24-29付近)
// monstersコレクションでは、ドキュメントIDをジャンル名として使用するのが自然です
// 知識入力画面（KnowledgeInputScreen）の成長ロジックもドキュメントIDを使用しているため、統一します。
fetchedGenres.add(doc.id);
// (注: 元々あったフィールドチェックは不要になります)
    }
    // 空のジャンル名や重複を排除
    return fetchedGenres.where((g) => g.isNotEmpty).toSet().toList();
  }

  // 知識をあげるボタンの処理
  void _onFeedMonsterPressed() async {
    // ロード中UIを一時的に表示
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('ジャンル情報を確認中...'), duration: Duration(seconds: 1)),
    );
    
    final genres = await _fetchGenres();
    
    // ロード中UIを非表示
    scaffoldMessenger.hideCurrentSnackBar();

    if (context.mounted) {
      if (genres.isEmpty) {
        // ジャンルが登録されていない場合は、ジャンル選択画面へ
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenreSelectScreen()),
        );
      } else {
        // ジャンルが登録されている場合は、知識入力画面へジャンルリストを渡して遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KnowledgeInputScreen(
              genres: genres,
              initialGenre: genres.first, // 最初のジャンルを初期値として渡す
            ),
          ),
        );
      }
    }
  }

  // 既存のメソッドはState内に移動または保持
  Widget _buildLatestKnowledgeDisplay(ThemeData theme) {
    // ... 既存のロジック (知識の最新表示 StreamBuilder) ...
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('knowledge')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'エラーが発生しました',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 20),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'モンスターはまだ空腹だ...',
            style: TextStyle(
              fontSize: 20,
              color: theme.colorScheme.onBackground,
            ),
          );
        }
        final latestKnowledge = snapshot.data!.docs.first;
        
        // monster_screen.dart (L.90-93付近)
        // ドキュメントデータをMapとして取得し、安全にアクセスします
        final data = latestKnowledge.data() as Map<String, dynamic>?;

        // nullチェックとフィールドの存在チェックを安全に行う
        final text = data?['knowledge'] as String? ?? 'データなし';
        final genre = data?['genre'] as String? ?? '不明';
        return Text(
          '「$text」($genre) を食べた！',
          style: TextStyle(
            fontSize: 20,
            color: theme.colorScheme.onBackground,
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: SafeArea(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo1.gif',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                _buildLatestKnowledgeDisplay(theme),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 30.0,
                    ),
                    textStyle: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _onFeedMonsterPressed,
                  child: const Text('知識をあげる'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),

    );
  }
}

