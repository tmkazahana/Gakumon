// lib/screens/timer_screen.dart (または該当パス)

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'knowledge_input_screen.dart'; 
// import 'stomach_screen.dart'; // 💡 修正: 不要になったためコメントアウトまたは削除

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _seconds = 60;
  bool _isRunning = false;
  bool _isCountdown = true;
  int _initialCountdownSeconds = 60;
  
  // 仮のジャンルリストと初期ジャンル
  final List<String> _genres = ['プログラミング', 'デザイン', 'ビジネス', 'その他'];
  final String _initialGenre = 'プログラミング';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  String _formatTime(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_isCountdown) {
            if (_seconds > 0) {
              _seconds--;
            } else {
              _timer?.cancel();
              _isRunning = false;
            }
          } else {
            _seconds++;
          }
        });
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _seconds = _isCountdown ? _initialCountdownSeconds : 0;
    });
  }

  void _switchTimerMode() {
    setState(() {
      _isCountdown = !_isCountdown;
    });
    _resetTimer();
  }
  
  Future<void> _showSetTimeDialog() async {
    final initialDuration = Duration(seconds: _initialCountdownSeconds);
    final hController = TextEditingController(text: initialDuration.inHours.toString());
    final mController = TextEditingController(text: initialDuration.inMinutes.remainder(60).toString());
    final sController = TextEditingController(text: initialDuration.inSeconds.remainder(60).toString());

    final newTime = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('カウントダウン設定'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimeInput(hController, "時"),
              _buildTimeInput(mController, "分"),
              _buildTimeInput(sController, "秒"),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('決定'),
              onPressed: () {
                final hours = int.tryParse(hController.text) ?? 0;
                final minutes = int.tryParse(mController.text) ?? 0;
                final seconds = int.tryParse(sController.text) ?? 0;
                
                final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;

                if (totalSeconds > 0) {
                  Navigator.of(context).pop(totalSeconds);
                }
              },
            ),
          ],
        );
      },
    );

    if (newTime != null) {
      setState(() {
        _initialCountdownSeconds = newTime;
      });
      _resetTimer();
    }
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
  
  // 知識の入力画面を表示し、タイマー再開と成功メッセージの表示を行う
  void _showKnowledgeInput() async { 
    final wasRunning = _isRunning;

    if (wasRunning) {
        _toggleTimer(); 
    }
    
    // ボトムシートの戻り値 (true/false) を受け取る
    final result = await showModalBottomSheet( 
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
           height: MediaQuery.of(context).size.height * 0.9, 
           child: KnowledgeInputScreen(
            genres: _genres,
            initialGenre: _initialGenre,
          ),
        );
      },
    );

    // ボトムシートが閉じた後、元々動作していたなら再開する
    if (wasRunning) {
      _toggleTimer();
    }
    
    // 💡 修正: 知識入力が成功した（resultが true）場合のみ、SnackBarでメッセージを表示
    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 知識を記録しました！'), duration: Duration(seconds: 2)),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマー'),
        actions: [
          if (_isCountdown)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSetTimeDialog,
              tooltip: '時間を設定',
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(_seconds),
              style: const TextStyle(
                fontSize: 80, 
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
                ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 70,
                  ),
                  onPressed: _toggleTimer,
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: const Icon(Icons.replay_circle_filled, size: 70),
                  onPressed: _resetTimer,
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _switchTimerMode,
              child: Text(
                _isCountdown ? 'カウントアップに切替' : 'カウントダウンに切替',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showKnowledgeInput,
        icon: const Icon(Icons.add),
        label: const Text('知識を記録'),
      ),
    );
  }
}