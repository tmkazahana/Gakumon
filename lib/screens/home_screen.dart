// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

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

  // 各タブで表示する画面のリスト
  final List<Widget> _widgetOptions = const <Widget>[
    // 0: ホーム画面（Placeholderを一時的に入れるか、空のコンテナ）
    // 実際のウィジェットの切り替えは build メソッドで行います
    SizedBox.shrink(), 
    const BookScreen(), // 1: ずかん画面
    const TimerScreen(),// 2: タイマー画面
    const SettingsScreen(),// 3: 設定画面
  ];

  @override
  void initState() {
    super.initState();
    // 初期化は不要
  }

  // タブがタップされたときに呼ばれる関数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 選択されたタブのインデックスを更新
    });
  }

  // ホームタブ（最初の画面）のコンテンツ部分としてメソッドを復活
  Widget _buildMainContent() {
    return Stack(
      children: [
        // --- 上部リボン（ヘッダー） ---
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
                      // ヘルプダイアログの表示
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("ヘルプ"),
                          content: const Text("何歳なん？"),
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

        // --- 中央のGIFロゴ ---
        // Stack内でCenterを使うと、リボン下の領域の中央にロゴが配置されます
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

        // --- 右下の知識UPボタン（Floating Action Button） ---
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
            // 育成ボタンのデザインを調整
            //icon: const Icon(Icons.school, size: 24),
            label: const Text('育成', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  //ScaffoldとBottomNavigationBarを含む本来のbuildメソッド
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
        
        // --- デザイン調整 ---
        type: BottomNavigationBarType.fixed, // ボタンが4つ以上でもレイアウトを固定
        selectedItemColor: Theme.of(context).colorScheme.primary, // 選択中の色
        unselectedItemColor: Colors.grey, // 選択されていないときの色
        showUnselectedLabels: true, // 選択されていなくてもラベルを表示
      ), 
    );
  }
}