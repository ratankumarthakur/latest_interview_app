import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionPage extends StatefulWidget {
  final String uid;
  const AddQuestionPage({super.key, required this.uid});

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _topic = TextEditingController();
  final _q = TextEditingController();
  final _a = TextEditingController();
  String? _msg;

  Future<void> _save() async {
    if (_topic.text.trim().isEmpty || _q.text.trim().isEmpty || _a.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please fill out all fields'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.uid)
        .collection('questions')
        .add({
      'topic': _topic.text.trim(),
      'question': _q.text.trim(),
      'answer': _a.text.trim(),
    });

    _topic.clear();
    _q.clear();
    _a.clear();
    setState(() => _msg = 'Saved!');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Question saved successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }

  Widget _buildInput(String emoji, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(emoji, style: const TextStyle(fontSize: 20)),
        ),
        labelText: label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(255, 179, 244, 199)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color:Color(0xff48c26e), width: 2),
        ),
      ),
      keyboardType: TextInputType.multiline,
      maxLines: null,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
            leading:IconButton(onPressed:() => Navigator.pop(context), icon: Icon(Icons.arrow_back,color: Colors.white,)),

      title: const Text('Add New Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Color(0xff48c26e),
      centerTitle: true,
      elevation: 4,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildInput("📚", "Topic", _topic),
                const SizedBox(height: 12),
                _buildInput("❓", "Question", _q),
                const SizedBox(height: 12),
                _buildInput("✅", "Answer", _a),
              ],
            ),
          ),
          if (_msg != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _msg!,
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff48c26e),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}