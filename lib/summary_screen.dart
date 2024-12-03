import 'package:flutter/material.dart';
import 'setup_screen.dart';

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  SummaryScreen({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Summary')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your Score: $score/$totalQuestions',
                style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SetupScreen())),
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
