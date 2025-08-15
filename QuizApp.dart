import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mohit_app/StartScreen.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String correct = data['correctAnswer']; // A/B/C/D
    List<String> options = [
      data['optionA'],
      data['optionB'],
      data['optionC'],
      data['optionD'],
    ];

    int correctIndex;
    switch (correct) {
      case 'A':
        correctIndex = 0;
        break;
      case 'B':
        correctIndex = 1;
        break;
      case 'C':
        correctIndex = 2;
        break;
      case 'D':
        correctIndex = 3;
        break;
      default:
        correctIndex = -1; // handle edge case
    }

    return Question(
      text: data['question'],
      options: options,
      correctIndex: correctIndex,
    );
  }
}


class QuizApp extends StatelessWidget {
  final String userName;
  final String userEmail;

  const QuizApp({super.key, required this.userName, required this.userEmail});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(userName: userName, userEmail: userEmail),
      debugShowCheckedModeBanner: false,
    );
  }
}