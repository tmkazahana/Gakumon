// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../main.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // 選択できるカラーパレットの定義（メイン色とサブ色のペア）
  final List<Map<String, Color>> _colorPalettes = const [
    {
      // デフォルト（ブルー系）
      'primary': Color(0xFFAEC6CF), 
      'secondary': Color(0xFFFFB6C1), 
    },
    {
      // ピンク系
      'primary': Color(0xFFFFB7B2),
      'secondary': Color(0xFFB5EAD7),
    },
    {
      // グリーン系
      'primary': Color(0xFFB5EAD7),
      'secondary': Color(0xFFFFDAC1),
    },
    {
      // イエロー/オレンジ系
      'primary': Color(0xFFFFDAC1),
      'secondary': Color(0xFFE2F0CB),
    },
    {
      // パープル系
      'primary': Color(0xFFC7CEEA),
      'secondary': Color(0xFFFF9AA2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'テーマカラー変更',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _colorPalettes.map((palette) {
              final pColor = palette['primary']!;
              final sColor = palette['secondary']!;
              
              // 現在選択されている色かどうか判定
              final isSelected = themeController.primaryColor == pColor;

              return GestureDetector(
                onTap: () {
                  // メインの色を変更！
                  themeController.changeThemeColor(pColor, sColor);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: pColor,
                    shape: BoxShape.circle,
                    border: isSelected 
                        ? Border.all(color: Colors.black54, width: 3) 
                        : Border.all(color: Colors.black12, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  // 右下にサブカラーを小さく表示しておしゃれに
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: sColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Divider(height: 40),
          const ListTile(
            leading: Icon(Icons.flag),
            title: Text('目標設定'),
            subtitle: Text('（今後の実装予定）'),
          ),
        ],
      ),
    );
  }
}