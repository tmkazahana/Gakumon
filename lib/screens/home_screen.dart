//home_screen.dart
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
  // late final で initState 内での初期化を保証
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // 表示する画面のリストを定義
    _widgetOptions = <Widget>[
      _buildMainContent(), // 0: ホーム画面のコンテンツ
      const BookScreen(),    // 1: ずかん画面
      const TimerScreen(),   // 2: タイマー画面
      const SettingsScreen(),// 3: 設定画面
    ];
  }

  // タブがタップされたときに呼ばれる関数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 選択されたタブのインデックスを更新
    });
  }

  // ホームタブ（最初の画面）のコンテンツ部分
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
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
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonsterScreen()),
              );
            },
            child: const Text('育成', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Center(
        // 選択されたインデックスに応じて表示する画面を切り替える
        child: _widgetOptions.elementAt(_selectedIndex),
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
        onTap: _onItemTapped,         // タップ時の処理
        
        // --- デザイン調整 ---
        type: BottomNavigationBarType.fixed, // ボタンが4つ以上でもレイアウトを固定
        selectedItemColor: Theme.of(context).colorScheme.primary, // 選択中の色
        unselectedItemColor: Colors.grey, // 選択されていないときの色
        showUnselectedLabels: true, // 選択されていなくてもラベルを表示
      ),     
    );
  }
}




