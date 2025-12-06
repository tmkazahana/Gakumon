import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// キャラクターデータモデル
class Character {
  final int id;
  final String name;
  final String description;
  final String imagePath;

  Character({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });
}

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  // 獲得済みキャラクターのIDリスト
  List<String> _unlockedIds = [];

  // 図鑑のマスターデータ（全キャラクターのリスト）
  // ※画像はすべて 'assets/images/logo1.gif' を仮置き
  final List<Character> _allCharacters = [
    // --- 1. 幼年期 ---
    Character(
      id: 1,
      name: 'がくモン',
      description: '勉強を始めたばかりのばけもの。',
      imagePath: 'assets/images/logo1.gif',
    ),
    
    // --- 2. 陸タイプへの進化 ---
    Character(
      id: 2,
      name: 'ランド(陸)',
      description: '大地のようなたくましい体を手に入れた。',
      imagePath: 'assets/images/logo1.gif', 
    ),

    // --- 3. 海タイプへの進化 ---
    Character(
      id: 3,
      name: 'マリン (海)',
      description: '深い海のような知性を持ったばけもの。',
      imagePath: 'assets/images/logo1.gif', 
    ),

    // --- 4. 空タイプへの進化 ---
    Character(
      id: 4,
      name: 'スカイ (空)',
      description: '空高くから全てを見通すばけもの。',
      imagePath: 'assets/images/logo1.gif', 
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 画面が開かれたら、保存されているデータを読み込む
    _loadUnlockedData();
  }

  // --- 保存データの読み込み ---
  Future<void> _loadUnlockedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 保存されているIDリストを取得（なければ空リスト）
      // 初期状態で '1' (がくモン) だけは解放しておく設定
      _unlockedIds = prefs.getStringList('unlocked_characters') ?? ['1']; 
    });
  }

  // --- デバッグ用：図鑑をリセット or 全開放する機能 ---
  Future<void> _debugToggleUnlockAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_unlockedIds.length < _allCharacters.length) {
      // 全開放する
      final allIds = _allCharacters.map((c) => c.id.toString()).toList();
      await prefs.setStringList('unlocked_characters', allIds);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('デバッグ：図鑑を全開放しました！')));
    } else {
      // リセットする（初期状態に戻す）
      await prefs.setStringList('unlocked_characters', ['1']);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('デバッグ：図鑑をリセットしました')));
    }
    
    // 画面を再読み込み
    _loadUnlockedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('モンスター図鑑'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // デバッグ用ボタン（右上の工具アイコン）
          IconButton(
            icon: const Icon(Icons.build_circle_outlined),
            onPressed: _debugToggleUnlockAll,
            tooltip: 'デバッグ：全開放/リセット',
          ),
        ],
      ),
      body: _unlockedIds.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 読み込み中
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2列表示
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // カードの縦横比
              ),
              itemCount: _allCharacters.length,
              itemBuilder: (context, index) {
                final chara = _allCharacters[index];
                // IDが保存リストに含まれているかチェック
                final isUnlocked = _unlockedIds.contains(chara.id.toString());
                
                return _buildCharacterCard(chara, isUnlocked);
              },
            ),
    );
  }

  // カードの作成
  Widget _buildCharacterCard(Character chara, bool isUnlocked) {
    // ロック中（未獲得）
    if (!isUnlocked) {
      return Card(
        color: Colors.grey[300],
        elevation: 2,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 40, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              '???',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // 解放済み（獲得済み）
    return GestureDetector(
      onTap: () => _showDetailDialog(chara),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  chara.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                chara.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 詳細ダイアログ
  void _showDetailDialog(Character chara) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(chara.name, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset(chara.imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              Text(chara.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('とじる'),
            ),
          ],
        );
      },
    );
  }
}