import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List categories = [];
  String selectedCategory = '9'; // Default category: General Knowledge
  String selectedDifficulty = 'easy';
  String selectedType = 'multiple';
  int selectedQuestions = 5;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['trivia_categories'];
      });
    }
  }

  void startQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          numberOfQuestions: selectedQuestions,
          category: selectedCategory,
          difficulty: selectedDifficulty,
          type: selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Number of Questions:'),
            DropdownButton<int>(
              value: selectedQuestions,
              items: [5, 10, 15].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedQuestions = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Category:'),
            DropdownButton<String>(
              value: selectedCategory,
              items: categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Difficulty:'),
            DropdownButton<String>(
              value: selectedDifficulty,
              items: ['easy', 'medium', 'hard'].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value!;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Type:'),
            DropdownButton<String>(
              value: selectedType,
              items: ['multiple', 'boolean'].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                      value == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: startQuiz,
              child: Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
