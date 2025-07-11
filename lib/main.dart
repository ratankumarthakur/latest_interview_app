// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_app/authpage.dart';
import 'package:interview_app/dashboardpage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyArwn6dKr7ppJkjOE45VfQ9OCRih9nClag",
      appId: "1:61768828498:android:b76f9de2883171f460018b",
      storageBucket: "sems-4c37f.appspot.com",
      authDomain: "sems-4c37f.firebaseapp.com",
      messagingSenderId: "61768828498",
      projectId: "sems-4c37f",
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