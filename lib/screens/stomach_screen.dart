//stomach_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StomachScreen extends StatefulWidget {
  const StomachScreen({super.key});

  @override
  State<StomachScreen> createState() => _StomachScreenState();
}

class _StomachScreenState extends State<StomachScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 利用可能なジャンルリスト (Firestoreから取得)
  List<String> _availableGenres = []; 
  // 現在選択中のジャンル ('全て'の場合は全表示)
  String? _selectedGenre; 
  // ジャンルロード中フラグ
  bool _isLoadingGenres = true; 

  @override
  void initState() {
    super.initState();
    _fetchGenres(); // 画面起動時にジャンルをロード
  }

  // monstersコレクションからジャンルをロードするメソッド
  Future<void> _fetchGenres() async {
    try {
      final querySnapshot = await _firestore.collection('monsters').get();
      List<String> fetchedGenres = [];
      for (var doc in querySnapshot.docs) {
        fetchedGenres.add(doc.id);
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGenres = false;
        });
        // エラーハンドリング
      }
    }
  }

  // 選択されたジャンルに基づいてFirestoreクエリを構築
  Stream<QuerySnapshot> _getTodaysEntriesStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    Query query = _firestore
        .collection('knowledge') 
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay);
        
    // 【修正・追加】「全て」以外のジャンルが選択されている場合、フィルタリング条件を追加
    if (_selectedGenre != null && _selectedGenre != '全て') {
      query = query.where('genre', isEqualTo: _selectedGenre);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // 【修正】ジャンルロード中の場合はローディング表示
    if (_isLoadingGenres) {
      return Scaffold(
        appBar: AppBar(title: const Text('今日の胃の記録')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    // ジャンルがロードされた後のメインUI
    return Scaffold(
      appBar: AppBar(title: const Text('今日の胃の記録')),
      body: Column(
        children: [
          // 【追加】ジャンル選択ドロップダウン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '表示ジャンル',
                border: OutlineInputBorder(),
              ),
              value: _selectedGenre,
              // _availableGenresをドロップダウンの項目として使用
              items: _availableGenres.map((String genre) {
                return DropdownMenuItem<String>(
                  value: genre,
                  child: Text(genre),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedGenre = newValue;
                    // StreamBuilderが新しいクエリで自動的にリビルドされます
                  });
                }
              },
            ),
          ),
          
          // StreamBuilderをExpandedで囲み、残りスペースを占有させる
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTodaysEntriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
                }

                final entries = snapshot.data!.docs;
                final entryCount = entries.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 【追加】今日の件数サマリー
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        '${_selectedGenre == '全て' ? '今日' : '今日の${_selectedGenre}ジャンル'}の記録: ${entryCount}件',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    Expanded(
                      child: entries.isEmpty
                          ? const Center(
                              child: Text(
                                '今日の記録はまだありません',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: entryCount,
                              itemBuilder: (context, index) {
                                var data = entries[index].data() as Map<String, dynamic>;
                                String content = data['knowledge'] ?? '内容がありません';
                                String genre = data['genre'] ?? '不明'; // 記録されたジャンル
                                
                                String formattedTime = '';
                                if (data['timestamp'] != null) {
                                  formattedTime = DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate());
                                }

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(content),
                                    // サブタイトルに時刻とジャンルを表示
                                    subtitle: Text('$formattedTime | ジャンル: $genre'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}