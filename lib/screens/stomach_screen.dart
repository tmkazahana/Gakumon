// lib/screens/stomach_screen.dart
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

  List<String> _availableGenres = []; 
  String? _selectedGenre; 
  bool _isLoadingGenres = true; 
  
  DateTime _selectedDate = DateTime.now(); 

  @override
  void initState() {
    super.initState();
    _fetchGenres(); 
  }

  // monstersコレクションからジャンルをロードするメソッド
  Future<void> _fetchGenres() async {
    try {
      final querySnapshot = await _firestore.collection('monsters').get();
      List<String> fetchedGenres = [];
      for (var doc in querySnapshot.docs) {
        fetchedGenres.add(doc.id);
      }
      
      if (mounted) {
        setState(() {
          _availableGenres = ['全て', ...fetchedGenres]; 
          _selectedGenre = _availableGenres.isNotEmpty ? _availableGenres[0] : null; 
          _isLoadingGenres = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGenres = false;
        });
        print('ジャンルロードエラー: $e');
      }
    }
  }

  // 選択された日付とジャンルに基づいてFirestoreクエリを構築
  Stream<QuerySnapshot> _getSelectedDateEntriesStream() {
    DateTime startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    Query query = _firestore
        .collection('knowledge') 
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay);
        
    if (_selectedGenre != null && _selectedGenre != '全て') {
      query = query.where('genre', isEqualTo: _selectedGenre);
    }

    return query
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
  // 日付ピッカーを表示するメソッド
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000), 
      lastDate: DateTime.now(),   
      locale: const Locale('ja', 'JP'), 
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; 
      });
    }
  }
  
  // 日付選択UIを構築するメソッド
  Widget _buildDateSelector() {
    // intl のロケール設定により、このフォーマットが可能
    String formattedDate = DateFormat('MM月dd日(E)', 'ja').format(_selectedDate);
    
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final canGoForward = selectedDay.isBefore(today);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 20),
                onPressed: () => _pickDate(context),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: canGoForward
                    ? () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 1));
                        });
                      } 
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoadingGenres) {
      return Scaffold(
        appBar: AppBar(title: const Text('胃の記録')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('胃の記録')),
      body: Column(
        children: [
          _buildDateSelector(),
          const Divider(height: 1, color: Colors.grey),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '表示ジャンル',
                border: OutlineInputBorder(),
              ),
              value: _selectedGenre,
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
                  });
                }
              },
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getSelectedDateEntriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'データの読み込みに失敗しました。Firestoreの複合インデックス（genre:昇順, timestamp:降順）が有効になっているか確認してください。',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                final entries = snapshot.data!.docs;
                final entryCount = entries.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                      child: Text(
                        '${DateFormat('MM月dd日').format(_selectedDate)}の${_selectedGenre == '全て' ? '記録' : '${_selectedGenre}ジャンルの記録'}: ${entryCount}件',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                                child: Text(
                                  '${DateFormat('MM月dd日').format(_selectedDate)}の記録はまだありません',
                                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              )
                          : ListView.builder(
                                itemCount: entryCount,
                                itemBuilder: (context, index) {
                                  var data = entries[index].data() as Map<String, dynamic>;
                                  String content = data['knowledge'] ?? '内容がありません';
                                  String genre = data['genre'] ?? '不明'; 
                                  
                                  String formattedTime = '';
                                  if (data['timestamp'] != null) {
                                    formattedTime = DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate());
                                  }

                                  // タイムライン風のレイアウト
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 50, 
                                          child: Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        Expanded(
                                          child: Card(
                                            margin: EdgeInsets.zero, 
                                            elevation: 1, 
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(content, style: const TextStyle(fontSize: 16)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '#$genre',
                                                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 記録追加画面への遷移処理などを実装
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}