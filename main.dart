import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mohit_app/QuizApp.dart';
import 'package:mohit_app/SplashScreen.dart';
import 'package:mohit_app/StartScreen.dart';
import 'package:mohit_app/screens/GettingStartedScreen.dart';
import 'package:mohit_app/screens/LoginScreen.dart';
import 'package:mohit_app/screens/Register.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyDTF8u9G0NA7aI_3uUtcci71GtQtxU09X8",
        authDomain: "mohit-app-f75f6.firebaseapp.com",
        projectId: "mohit-app-f75f6",
        storageBucket: "mohit-app-f75f6.firebasestorage.app",
        messagingSenderId: "147831141305",
        appId: "1:147831141305:web:615778e6607fa9f5467c68",
        measurementId: "G-HTXTYSDMSZ"));
  }
  else{
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExamApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      routes: {
        LoginScreen.routeName: (ctx) => LoginScreen(),
        Register.routeName: (ctx) => Register(),
      },
    );
  }
}
