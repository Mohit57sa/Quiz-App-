// 🎨 Decorated and Enhanced Quiz App UI with Styled Dropdown
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mohit_app/ResultHistoryScreen.dart';
import 'package:mohit_app/ResultPage.dart';
import 'package:mohit_app/screens/GettingStartedScreen.dart';
import 'package:mohit_app/screens/LoginScreen.dart';
import 'package:mohit_app/screens/Register.dart';

import 'QuizApp.dart';

class StartScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const StartScreen({required this.userName, required this.userEmail, super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _loading = false;
  String selectedDifficulty = 'easy';

  Future<List<Question>> _loadQuestions() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('difficulty', isEqualTo: selectedDifficulty)
        .get();

    return querySnapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();
  }

  void _startQuiz() async {
    setState(() => _loading = true);

    List<Question> questions = await _loadQuestions();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(
          questions: questions,
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
      ),
    );

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        backgroundColor: Colors.pink.shade100,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.userName),
              accountEmail: Text(widget.userEmail),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.purpleAccent, Colors.pink.shade200]),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo, size: 36),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.purpleAccent),
              title: Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.purpleAccent),
              title: Text('My Results'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultHistoryScreen(userName: widget.userName),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: Colors.indigo),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Quiz App',
                  applicationVersion: '1.0.0',
                  children: [
                    Text('This is a beautifully designed quiz app using Flutter.'),
                  ],
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.white54],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz, size: 100, color: Colors.pink.shade400),
              SizedBox(height: 20),
              Text(
                "Welcome to Quiz App!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDifficulty,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.pink.shade500),
                      iconSize: 28,
                      isExpanded: true,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      onChanged: (value) {
                        setState(() => selectedDifficulty = value!);
                      },
                      items: ['easy', 'medium', 'hard'].map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Row(
                            children: [
                              Icon(Icons.bolt, color: Colors.indigo),
                              SizedBox(width: 10),
                              Text(
                                level.toUpperCase(),
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text("Start Quiz", style: TextStyle(fontSize: 18)),
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final String userName;
  final String userEmail;

  QuizPage({
    required this.questions,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _index = 0;
  int _score = 0;
  List<int?> selectedAnswers = [];
  List<bool> isAnsweredList = [];
  String feedbackMessage = "";

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.questions.length, null);
    isAnsweredList = List.filled(widget.questions.length, false);
  }

  void _selectAnswer(int index) {
    if (isAnsweredList[_index]) return;

    final isCorrect = index == widget.questions[_index].correctIndex;

    setState(() {
      selectedAnswers[_index] = index;
      isAnsweredList[_index] = true;
      if (isCorrect) {
        _score++;
        feedbackMessage = "✅ Correct Answer!";
      } else {
        feedbackMessage = "❌ Wrong Answer!";
      }
    });
  }

  void _nextQuestion() {
    if (_index < widget.questions.length - 1) {
      setState(() {
        _index++;
        feedbackMessage = "";
      });
    }
  }

  void _previousQuestion() {
    if (_index > 0) {
      setState(() {
        _index--;
        feedbackMessage = "";
      });
    }
  }

  void _submitQuiz() async {
    await FirebaseFirestore.instance.collection('results').add({
      'userName': widget.userName,
      'score': _score,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(score: _score, total: widget.questions.length),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Leave Exam?"),
        content: Text("Are you sure you want to leave the exam? Your progress will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Leave"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_index];
    final selected = selectedAnswers[_index];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Question ${_index + 1} of ${widget.questions.length}"),
          backgroundColor: Colors.indigo,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.blue.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (feedbackMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      feedbackMessage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: feedbackMessage.contains("Correct") ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      question.text,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question.options.length, (i) {
                  bool isSelected = selected == i;
                  bool isCorrect = i == question.correctIndex;

                  Color? color;
                  if (selected != null) {
                    if (i == selected && isCorrect) {
                      color = Colors.green;
                    } else if (i == selected && !isCorrect) {
                      color = Colors.red;
                    } else if (i == question.correctIndex) {
                      color = Colors.green[200];
                    } else {
                      color = Colors.grey.shade200;
                    }
                  } else {
                    color = Colors.white;
                  }

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        backgroundColor: color,
                        foregroundColor: Colors.black,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _selectAnswer(i),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          question.options[i],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_index > 0)
                      ElevatedButton.icon(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _previousQuestion,
                        label: Text("Previous"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                        ),
                      ),
                    if (_index < widget.questions.length - 1)
                      ElevatedButton.icon(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: isAnsweredList[_index] ? _nextQuestion : null,
                        label: Text("Next"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAnsweredList[_index] ? Colors.indigo : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                        ),
                      ),
                    if (_index == widget.questions.length - 1)
                      ElevatedButton.icon(
                        icon: Icon(Icons.check_circle),
                        onPressed: isAnsweredList[_index] ? _submitQuiz : null,
                        label: Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAnsweredList[_index] ? Colors.green : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
