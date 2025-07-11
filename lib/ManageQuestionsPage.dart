/* ───────  MANAGE QUESTIONS PAGE  ─────── */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageQuestionsPage extends StatelessWidget {
  final String uid;
  const ManageQuestionsPage({super.key, required this.uid});

  @override
Widget build(BuildContext context) {
  final qCol = FirebaseFirestore.instance
      .collection('students')
      .doc(uid)
      .collection('questions')
      .orderBy('topic');

  return Scaffold(
    appBar: AppBar(
      leading:IconButton(onPressed:() => Navigator.pop(context), icon: Icon(Icons.arrow_back,color: Colors.white,)),
      title: const Text('📝 My Questions',style: TextStyle(color: Colors.white),),
      centerTitle: true,
      backgroundColor: Color(0xff48c26e),
      elevation: 4,
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: qCol.snapshots(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xff48c26e),));
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No questions yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return Card(
              color: Color.fromARGB(255, 190, 247, 208),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                //tileColor: Color.fromARGB(255, 170, 236, 191),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Text('Topic: ${data['topic']}',style: TextStyle(fontSize: 25,color: Color(0xff48c26e)),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  data['question'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                    Text('${data['answer']}'),
                  ],
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xff48c26e)),
                      tooltip: 'Edit',
                      onPressed: () => _editDialog(context, docs[i].reference, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: 'Delete',
                      onPressed: () => docs[i].reference.delete(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ),
  );
}}
Future<void> _editDialog(BuildContext ctx, DocumentReference ref, Map<String, dynamic> data) async {
  final topic = TextEditingController(text: data['topic']);
  final q = TextEditingController(text: data['question']);
  final a = TextEditingController(text: data['answer']);

  await showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: const Text('✏️ Update Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _styledField(topic, 'Topic'),
          _styledField(q, 'Question'),
          _styledField(a, 'Answer'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Save'),
          onPressed: () async {
            await ref.update({
              'topic': topic.text.trim(),
              'question': q.text.trim(),
              'answer': a.text.trim(),
            });
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ],
    ),
  );
}

Widget _styledField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xff48c26e), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}