import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // firebase_coreをインポート
import 'firebase_options.dart'; // flutterfire configureで自動作成されたファイル
import 'knowledge_input_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// main関数を、非同期処理ができるように async を付ける
void main() async {
  // Flutterアプリの初期化を保証するもの
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseの初期化処理
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'がくモン',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const HomeScreen(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('がくモン ホーム'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: ここにモンスターの画像などを表示
            
            // ここが新しいリアルタイム表示エリア
            StreamBuilder<QuerySnapshot>(
              // ここが「ライブ監視」の設定
              stream: FirebaseFirestore.instance
                  .collection('knowledge') // 'knowledge'という保管場所を監視
                  .orderBy('timestamp', descending: true) // 日時が新しい順に並び替え
                  .limit(1) // 最新の1件だけを取得
                  .snapshots(), // データに変更があれば自動でお知らせ
              
              // データストリームの状態に応じて表示を切り替える部分
              builder: (context, snapshot) {
                // データ待機中は、くるくる回るアイコンを表示
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                // エラーが発生した場合
                if (snapshot.hasError) {
                  return const Text('エラーが発生しました');
                }
                // データがまだ一つもない場合
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    'モンスターはまだ空腹だ...',
                    style: TextStyle(fontSize: 20),
                  );
                }

                // データがあれば、最新の「知識」を表示
                final latestKnowledge = snapshot.data!.docs.first;
                final text = latestKnowledge['text'];
                final genre = latestKnowledge['genre'];

                return Text(
                  '「$text」($genre) を食べた！',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                );
              },
            ),

            const SizedBox(height: 40),

            // 入力画面に移動するためのボタン
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KnowledgeInputScreen()),
                );
              },
              child: const Text('知識をあげる'),
            ),
          ],
        ),
      ),
    );
  }
}