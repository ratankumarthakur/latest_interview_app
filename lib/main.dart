// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_app/authpage.dart';
import 'package:interview_app/dashboardpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //sems 
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyArwn6dKr7ppJkjOE45VfQ9OCRih9nClag",
      authDomain: "sems-4c37f.firebaseapp.com",
      projectId: "sems-4c37f",
      storageBucket: "sems-4c37f.appspot.com",
      messagingSenderId: "61768828498",
      appId: "1:61768828498:web:9bbe93dbe4ebc19a60018b"
    ),
  );
  runApp(const InterviewApp());
}

class InterviewApp extends StatelessWidget {
  const InterviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: FirebaseAuth.instance.currentUser == null
            ? const AuthPage()
            : const DashboardPage(),
      );
}
