// lib/main.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:interview_app/InterviewPage.dart';

class PickTopicsPage extends StatefulWidget {
  final String uid;
  final int defaultNumQ;
  const PickTopicsPage({super.key, required this.uid, this.defaultNumQ = 5});
  @override
  State<PickTopicsPage> createState() => _PickTopicsPageState();
}

class _PickTopicsPageState extends State<PickTopicsPage> {
  Set<String> _chosen = {};
  int _numQ = 5;
  late Future<List<String>> _topicsF;

  @override
  void initState() {
    super.initState();
    // pull distinct topics from the student's question bank
    _topicsF = FirebaseFirestore.instance
        .collection('students')
        .doc(widget.uid)
        .collection('questions')
        .get()
        .then((snap) =>
            snap.docs.map((d) => d['topic'] as String).toSet().toList()
              ..sort());
  }

  Future<void> _start() async {
    // count matching docs first
    final countSnap = await FirebaseFirestore.instance
        .collection('students')
        .doc(widget.uid)
        .collection('questions')
        .where('topic', whereIn: _chosen.toList())
        .count()
        .get(); // Firestore count aggregation

    final available = countSnap.count;
    if (available == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No questions for those topics'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
      return;
    }
    final usable = available! < _numQ ? available : _numQ;

    if (available < _numQ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Only $usable question(s) available; starting with $usable.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      );
    }

    if (context.mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => InterviewPage(
                    uid: widget.uid,
                    numQ: usable, // pass trimmed number
                    topics: _chosen.toList(),
                  )));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Choose Topics',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          backgroundColor: Color(0xff48c26e),
        ),
        body: FutureBuilder(
          future: _topicsF,
          builder: (_, snap) {
            if (!snap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Color(0xff48c26e),
              ));
            }
            final topics = snap.data!;
            if (topics.isEmpty) {
              return const Center(
                  child: Text('No topics yet. Add questions first.'));
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: topics
                        .map((t) => FilterChip(
                              checkmarkColor: Color(0xff48c26e),
                              label: Text(t),
                              selected: _chosen.contains(t),
                              onSelected: (v) => setState(
                                  () => v ? _chosen.add(t) : _chosen.remove(t)),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Number of questions selected: $_numQ',
                    style: TextStyle(fontSize: 20),
                  ),
                  Slider(
                    activeColor: Color(0xff48c26e),
                    value: _numQ.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_numQ',
                    onChanged: (v) => setState(() => _numQ = v.toInt()),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff48c26e),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.play_arrow,color: Colors.white,),
                      label: const Text('Start Interview'),
                      onPressed: _chosen.isEmpty
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => InterviewPage(
                                          uid: widget.uid,
                                          numQ: _numQ,
                                          topics: _chosen.toList(),
                                        )),
                              );
                              _start();
                            }),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            );
          },
        ),
      );
}
