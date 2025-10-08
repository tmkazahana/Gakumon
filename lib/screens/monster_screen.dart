import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'knowledge_input_screen.dart';

class MonsterScreen extends StatelessWidget {
  const MonsterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
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
              const Spacer(),
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
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KnowledgeInputScreen()),
                  );
                },
                child: const Text('知識をあげる'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestKnowledgeDisplay(ThemeData theme) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('knowledge')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'エラーが発生しました',
            style: TextStyle(color: theme.colorScheme.error, fontSize: 20),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'モンスターはまだ空腹だ...',
            style: TextStyle(
              fontSize: 20,
              color: theme.colorScheme.onBackground,
            ),
          );
        }
        final latestKnowledge = snapshot.data!.docs.first;
        
        final text = latestKnowledge['knowledge'] as String? ?? 'データなし';
        final genre = latestKnowledge['genre'] as String? ?? '不明';

        return Text(
          '「$text」($genre) を食べた！',
          style: TextStyle(
            fontSize: 20,
            color: theme.colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}