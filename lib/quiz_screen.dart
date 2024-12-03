import 'package:flutter/material.dart';
import 'summary_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizScreen extends StatefulWidget {
  final int numberOfQuestions;
  final String category;
  final String difficulty;
  final String type;

  QuizScreen(
      {required this.numberOfQuestions,
      required this.category,
      required this.difficulty,
      required this.type});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int remainingTime = 15;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=${widget.type}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        questions =
            (json.decode(response.body)['results'] as List).map((question) {
          final incorrectAnswers =
              (question['incorrect_answers'] as List).cast<String>();
          final correctAnswer = question['correct_answer'] as String;

          return {
            ...question,
            'incorrect_answers': incorrectAnswers,
            'correct_answer': correctAnswer,
          };
        }).toList();
      });
      startTimer();
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        nextQuestion();
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void nextQuestion([bool answered = false]) {
    stopTimer();
    if (!answered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Time's up! Correct answer: ${questions[currentQuestionIndex]['correct_answer']}")),
      );
    }
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        remainingTime = 15;
        startTimer();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(
                score: score, totalQuestions: widget.numberOfQuestions),
          ),
        );
      }
    });
  }

  void answerQuestion(String answer) {
    stopTimer();
    if (answer == questions[currentQuestionIndex]['correct_answer']) {
      setState(() {
        score++;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Correct!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Incorrect! Correct answer: ${questions[currentQuestionIndex]['correct_answer']}')),
      );
    }
    nextQuestion(true);
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              questions[currentQuestionIndex]['question'],
              style: TextStyle(fontSize: 18),
            ),
          ),
          ...(questions[currentQuestionIndex]['incorrect_answers']
                  as List<String>)
              .map((answer) => ElevatedButton(
                    onPressed: () => answerQuestion(answer),
                    child: Text(answer),
                  )),
          ElevatedButton(
            onPressed: () => answerQuestion(
                questions[currentQuestionIndex]['correct_answer']),
            child: Text(questions[currentQuestionIndex]['correct_answer']),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Time remaining: $remainingTime seconds'),
          ),
        ],
      ),
    );
  }
}
