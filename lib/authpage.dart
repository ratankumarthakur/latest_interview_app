import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_app/dashboardpage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _email = TextEditingController(),
      _pw = TextEditingController(),
      _name = TextEditingController();
  bool signUp = false;
  String? _err;

  Future<void> _go() async {
    try {
      if (signUp) {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _pw.text.trim());

        await FirebaseFirestore.instance
            .collection('students')
            .doc(cred.user!.uid)
            .set({
          'name': _name.text.trim(),
          'email': _email.text.trim(),
          'uid': cred.user!.uid,
        }, SetOptions(merge: true));
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email.text.trim(), password: _pw.text.trim());
      }
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _err = e.message);
    }
  }

  @override
Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    title: Text(signUp ? '🔐 Sign Up' : '🔓 Login'),
    centerTitle: true,
    backgroundColor: Color(0xff48c26e),
    elevation: 4,
  ),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(height: 300,width: double.infinity,"assets/login.avif"),
        if (signUp)
          _buildInputField(_name, '👤 Name'),

        const SizedBox(height: 12),
        _buildInputField(_email, '📧 Email'),
        const SizedBox(height: 12),
        _buildInputField(_pw, '🔑 Password', obscure: true),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _go,
            icon: Icon(signUp ? Icons.person_add : Icons.login,color: Colors.white,),
            label: Text(signUp ? 'Create Account' : 'Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff48c26e),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => signUp = !signUp),
          child: Text(
            signUp ? 'Already have an account? Log in' : 'No account? Sign up',
            style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
        ),
        if (_err != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _err!,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    ),
  ),
);

// Reusable input field widget
Widget _buildInputField(TextEditingController controller, String label, {bool obscure = false}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff48c26e), width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}}