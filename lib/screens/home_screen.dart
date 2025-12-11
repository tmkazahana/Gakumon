// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:intl/intl.dart'; 

import 'monster_screen.dart';
import 'book_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'stomach_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 現在選択されているタブのインデックス（0が最初のタブ）
  int _selectedIndex = 0;
  
  
  String _birthDate = '';

  // 各タブで表示する画面のリスト
  final List<Widget> _widgetOptions = const <Widget>[
    // 0: ホーム画面（Stackで構築するためここは空）
    SizedBox.shrink(), 
    BookScreen(), // 1: ずかん画面
    TimerScreen(),// 2: タイマー画面
    SettingsScreen(),// 3: 設定画面
  ];

  @override
  void initState() {
    super.initState();
    // 起動時に誕生日を読み込む（なければ今日を保存）
    _initBirthDate();
  }

  // 誕生日の初期化・読み込み処理
  Future<void> _initBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    // 保存されている誕生日を取得
    String? savedDate = prefs.getString('monster_birthday');

    if (savedDate == null) {
      // データがない場合（＝アプリ初回起動時）、今日の日付を保存
      final now = DateTime.now();
      savedDate = DateFormat('yyyy年MM月dd日').format(now);
      await prefs.setString('monster_birthday', savedDate);
    }

    // 画面に反映
    if (mounted) {
      setState(() {
        _birthDate = savedDate!;
      });
    }
  }

  // タブがタップされたときに呼ばれる関数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 選択されたタブのインデックスを更新
    });
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        // 上部リボン（ヘッダー）
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          // SafeAreaでノッチ領域を回避
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // リボンを際立たせるために色を調整
                color: Theme.of(context).colorScheme.primary.withOpacity(0.15), 
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "がくモン", // アプリ名を表示
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline), // ヘルプマーク
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("がくモン情報"), // タイトルも少し変更
                          // ここに読み込んだ誕生日を表示
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("この子が生まれた日"),
                              const SizedBox(height: 8),
                              Text(
                                _birthDate, // 保存された日付を表示
                                style: const TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("閉じる")),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),

        // 中央のGIFロゴ
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StomachScreen()),
              );
            },
            child: Image.asset(
              'assets/images/logo1.gif',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 右下の育成ボタン
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonsterScreen()),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            label: const Text('育成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 選択されたインデックスに応じて表示する画面を切り替えるウィジェットを決定
    final Widget currentWidget = _selectedIndex == 0 
        ? _buildMainContent() // 0番目のときはカスタムのホーム画面（Stack）を表示
        : _widgetOptions.elementAt(_selectedIndex); // それ以外のときはリストから取得

    return Scaffold(
      body: Center(
        // 選択されたインデックスに応じて表示する画面を切り替える
        child: currentWidget,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 各ボタンの設定
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'ずかん',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'タイマー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'せってい',
          ),
        ],
        currentIndex: _selectedIndex, // 現在選択されているタブ
        onTap: _onItemTapped,// タップ時の処理
        
        // デザイン調整 
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Theme.of(context).colorScheme.primary, 
        unselectedItemColor: Colors.grey, 
        showUnselectedLabels: true, 
      ), 
    );
  }
}