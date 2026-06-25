import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vocabulary.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Word> _shuffled;
  int _current = 0;
  int _score = 0;
  String? _selected;
  bool _answered = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _shuffled = List.from(wordList)..shuffle(Random());
    _shuffled = _shuffled.take(10).toList();
    _buildOptions();
  }

  void _buildOptions() {
    final correct = _shuffled[_current].uzbek;
    final others = wordList
        .where((w) => w.uzbek != correct)
        .toList()
      ..shuffle(Random());
    _options = [correct, others[0].uzbek, others[1].uzbek, others[2].uzbek]
      ..shuffle(Random());
  }

  void _answer(String chosen) {
    if (_answered) return;
    final correct = _shuffled[_current].uzbek;
    setState(() {
      _selected = chosen;
      _answered = true;
      if (chosen == correct) _score++;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_current + 1 < _shuffled.length) {
        setState(() {
          _current++;
          _selected = null;
          _answered = false;
          _buildOptions();
        });
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _score >= 7 ? '🎉 Ajoyib!' : '📖 Yana o\'qing',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_shuffled.length}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF58CC02)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _score >= 7 ? 'Siz juda yaxshi o\'qidingiz!' : 'Qo\'shimcha mashq qiling!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('Bosh sahifaga qaytish', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _shuffled[_current];
    final correct = word.uzbek;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Savol ${_current + 1} / ${_shuffled.length}'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_current + 1) / _shuffled.length,
              backgroundColor: Colors.grey[200],
              color: const Color(0xFF58CC02),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),
            // Word card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(word.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    word.english,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('O\'zbekcha tarjimasi qaysi?', style: TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Options
            ...(_options.map((opt) {
              Color btnColor = Colors.white;
              Color textColor = Colors.black87;
              if (_answered) {
                if (opt == correct) {
                  btnColor = const Color(0xFF58CC02);
                  textColor = Colors.white;
                } else if (opt == _selected) {
                  btnColor = Colors.red;
                  textColor = Colors.white;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    onPressed: () => _answer(opt),
                    child: Text(opt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            })),
          ],
        ),
      ),
    );
  }
}
