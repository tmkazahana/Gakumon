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

    // monster_screen.dart (L.80付近)
Widget _buildLatestKnowledgeDisplay(ThemeData theme) {
  // 今日の日付を取得
  DateTime today = DateTime.now();
  DateTime start = DateTime(today.year, today.month, today.day);
  DateTime end = start.add(const Duration(days: 1));

  // knowledgeコレクションの全データをチェックするStreamBuilder
  return StreamBuilder<QuerySnapshot>(
    // 全期間のknowledgeデータがあるかチェック (1件取得できればOK)
    stream: FirebaseFirestore.instance
        .collection('knowledge')
        .limit(1) // 存在チェックのため1件のみ
        .snapshots(),
    builder: (context, allTimeSnapshot) {
      // 最初のロード中（全体チェック）
      if (allTimeSnapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        );
      }
      
      // 全期間でデータが**全くない**場合（アプリ初回起動時相当）
      if (!allTimeSnapshot.hasData || allTimeSnapshot.data!.docs.isEmpty) {
        return Text(
          'モンスターと出会ったばかり！\n何か知識をあげてみよう！', // 👈 初回起動時のメッセージ
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: theme.colorScheme.onBackground,
          ),
        );
      }

      // 全期間でデータが**ある**場合は、今日の最新データを表示するロジックを実行
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('knowledge')
            .where('timestamp', isGreaterThanOrEqualTo: start)
            .where('timestamp', isLessThan: end)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, todaySnapshot) {
          // 今日のデータチェックのロード中
          if (todaySnapshot.connectionState == ConnectionState.waiting) {
             return CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            );
          }

          // エラー
          if (todaySnapshot.hasError) {
            return Text(
              'エラーが発生しました',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 20),
            );
          }

          // 今日のデータが無い（＝過去には食べたが、今日はまだ食べていない）
          if (!todaySnapshot.hasData || todaySnapshot.data!.docs.isEmpty) {
            return Text(
              '今日はまだモンスターは何も食べていないよ！', 
              style: TextStyle(
                fontSize: 20,
                color: theme.colorScheme.onBackground,
              ),
            );
          }

          // 今日の最新データを表示
          final latestKnowledge = todaySnapshot.data!.docs.first;
          final data = latestKnowledge.data() as Map<String, dynamic>?;

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

