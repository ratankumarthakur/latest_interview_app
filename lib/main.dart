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
      apiKey: "",
      appId: "",
      storageBucket: "",
      authDomain: "",
      messagingSenderId: "",
      projectId: "",
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
