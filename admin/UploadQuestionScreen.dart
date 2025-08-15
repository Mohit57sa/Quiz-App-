import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upload Quiz Question',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: UploadQuestionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UploadQuestionScreen extends StatefulWidget {
  @override
  _UploadQuestionScreenState createState() => _UploadQuestionScreenState();
}

class _UploadQuestionScreenState extends State<UploadQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController questionController = TextEditingController();
  final TextEditingController optionAController = TextEditingController();
  final TextEditingController optionBController = TextEditingController();
  final TextEditingController optionCController = TextEditingController();
  final TextEditingController optionDController = TextEditingController();
  final TextEditingController correctAnswerController = TextEditingController();

  String? selectedDifficulty;

  Future<void> uploadQuestion() async {
    if (_formKey.currentState!.validate()) {
      if (selectedDifficulty == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a difficulty level.")),
        );
        return;
      }

      final questionText = questionController.text.trim();
      final optionA = optionAController.text.trim();
      final optionB = optionBController.text.trim();
      final optionC = optionCController.text.trim();
      final optionD = optionDController.text.trim();
      final correctAnswer = correctAnswerController.text.trim().toLowerCase();

      final query = await FirebaseFirestore.instance
          .collection('questions')
          .where('question', isEqualTo: questionText)
          .get();

      if (query.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This question already exists.")),
        );
        return;
      }

      String? correctOption;
      if (optionA.toLowerCase() == correctAnswer) {
        correctOption = 'A';
      } else if (optionB.toLowerCase() == correctAnswer) {
        correctOption = 'B';
      } else if (optionC.toLowerCase() == correctAnswer) {
        correctOption = 'C';
      } else if (optionD.toLowerCase() == correctAnswer) {
        correctOption = 'D';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Correct answer does not match any option.")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('questions').add({
        'question': questionText,
        'optionA': optionA,
        'optionB': optionB,
        'optionC': optionC,
        'optionD': optionD,
        'correctAnswer': correctOption,
        'difficulty': selectedDifficulty, // 🔥 NEW FIELD
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Question uploaded successfully")),
      );

      _formKey.currentState!.reset();
      questionController.clear();
      optionAController.clear();
      optionBController.clear();
      optionCController.clear();
      optionDController.clear();
      correctAnswerController.clear();
      setState(() => selectedDifficulty = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[500],
      appBar: AppBar(
        title: Text("Upload Quiz Question"),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    "Enter Question Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  buildTextField(questionController, 'Question'),
                  SizedBox(height: 12),
                  buildTextField(optionAController, 'Option A'),
                  SizedBox(height: 12),
                  buildTextField(optionBController, 'Option B'),
                  SizedBox(height: 12),
                  buildTextField(optionCController, 'Option C'),
                  SizedBox(height: 12),
                  buildTextField(optionDController, 'Option D'),
                  SizedBox(height: 12),
                  buildTextField(correctAnswerController, 'Correct Answer (text match of one option)'),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    decoration: InputDecoration(labelText: 'Select Difficulty'),
                    items: ['easy', 'medium', 'hard']
                        .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level.toUpperCase()),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDifficulty = value;
                      });
                    },
                    validator: (value) => value == null ? 'Please select difficulty' : null,
                  ),
                  SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: uploadQuestion,
                      icon: Icon(Icons.cloud_upload_rounded),
                      label: Text('Upload Question'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
