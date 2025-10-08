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

  Stream<QuerySnapshot> _getTodaysEntriesStream() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('knowledge') 
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日の胃の記録')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTodaysEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '今日の記録はまだありません',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final entries = snapshot.data!.docs;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              var data = entries[index].data() as Map<String, dynamic>;
              String content = data['knowledge'] ?? '内容がありません'; 
              // timestampが存在し、nullでない場合のみ日時を表示
              String formattedTime = '';
              if (data['timestamp'] != null) {
                  formattedTime = DateFormat('HH:mm').format((data['timestamp'] as Timestamp).toDate());
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(content),
                  subtitle: Text(formattedTime),
                ),
              );
            },
          );
        },
      ),
    );
  }
}