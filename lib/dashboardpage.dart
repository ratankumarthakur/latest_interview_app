// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_app/ManageQuestionsPage.dart';
import 'package:interview_app/addquestion.dart';
import 'package:interview_app/authpage.dart';
import 'package:interview_app/picktopic.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final results = FirebaseFirestore.instance
        .collection('students')
        .doc(uid)
        .collection('results')
        .orderBy('finishedAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('students')
              .doc(uid)
              .snapshots(),
          builder: (_, snap) {
            if (!snap.hasData)
              return const Text(
                'Dashboard',
                style: TextStyle(color: Colors.white),
              );
            final data = snap.data!.data() as Map<String, dynamic>?;
            final name = data?['name'] ?? 'Dashboard';
            return Row(
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '$name',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            );
          },
        ),
        backgroundColor: Color(0xff48c26e),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: results,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(0xff48c26e),
            ));
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return Center(
                child: Image.network(
                    height: 300,
                    "https://img.freepik.com/free-vector/no-data-concept-illustration_114360-616.jpg"));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final finished = data['finishedAt'] != null
                  ? (data['finishedAt'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                      .split('.')
                      .first
                  : 'Interview not finished';

              return Card(
                //color: Colors.green,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    // image: DecorationImage(
                    //   image: NetworkImage(
                    //       'https://png.pngtree.com/thumb_back/fh260/background/20210706/pngtree-abstract-green-color-background-hd-free-dowunlode-pngtree-image_736896.jpg'), // Replace with your image path
                    //   fit: BoxFit.fill, 
                    //   //opacity: .2// Adjusts how the image fills the container
                    // ),
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff48c26e),
                        const Color.fromARGB(255, 173, 244, 190),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: const Color.fromARGB(255, 173, 244, 190),
                    ),
                    title: Text('Score: ${data['score']}%',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'Number of questions attempted: ${data['questionsAttempted']}'),
                    trailing: Text(finished,
                        style: const TextStyle(
                          fontSize: 12,
                        )),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildFAB(
              label: 'Manage Q&A',
              icon: Icons.list,
              tag: 'manage',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ManageQuestionsPage(uid: uid)),
              ),
            ),
            const SizedBox(height: 12),
            _buildFAB(
              label: 'New Interview',
              icon: Icons.play_arrow,
              tag: 'interview',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PickTopicsPage(uid: uid)),
              ),
            ),
            const SizedBox(height: 12),
            _buildFAB(
              label: 'Add Question',
              icon: Icons.add,
              tag: 'addq',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddQuestionPage(uid: uid)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB({
    required String label,
    required IconData icon,
    required String tag,
    required VoidCallback onTap,
  }) {
    return FloatingActionButton.extended(
      heroTag: tag,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color(0xff48c26e),
      onPressed: onTap,
    );
  }
}
