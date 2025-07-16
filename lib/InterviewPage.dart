import 'dart:async';
import 'dart:math' as math;
import 'package:interview_app/chatbot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class InterviewPage extends StatefulWidget {
  final String uid;
  final int numQ;
  final List<String> topics;
  const InterviewPage({
    super.key,
    required this.uid,
    required this.numQ,
    required this.topics,
  });
  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();
  late final TextEditingController _tc;

  bool _disposed = false;
  bool _listening = false;
  int _idx = 0, _total = 0, _cumScore = 0;
  Duration _timeLeft = const Duration(minutes: 5);

  Timer? _countTimer, _autoSubmitTimer;
  List<String> _qs = [], _ans = [];

  @override
  void initState() {
  super.initState();
  _tc = TextEditingController();
  _requestMicPermission(); // 🔁
  _fetchQuestions();
}

Future<void> _requestMicPermission() async {
  final status = await Permission.microphone.request();
  if (!status.isGranted) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      Navigator.pop(context);
    }
  }
}

  /* ─────────  Fetch & start first Q ───────── */
  Future<void> _fetchQuestions() async {
    final docs = await FirebaseFirestore.instance
        .collection('students').doc(widget.uid)
        .collection('questions')
        .where('topic', whereIn: widget.topics)
        .get();

    if (docs.docs.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No questions for chosen topics.')));
      Navigator.pop(context);
      return;
    }

    docs.docs.shuffle();
    final usable = math.min(docs.docs.length, widget.numQ);
    _qs  = docs.docs.take(usable).map((d) => d['question'] as String).toList();
    _ans = docs.docs.take(usable).map((d) => d['answer']   as String).toList();
    _total = usable;

    if (mounted) setState(() {});     // draw first question
    _startRound();                    // kick off timer + TTS + STT
  }

  /* ─────────  Start TTS, timer, STT ───────── */
  Future<void> _startRound() async {
    _timeLeft = const Duration(minutes: 5);
    _startTimers();

    await _tts.speak(_qs[_idx]);
    await _tts.awaitSpeakCompletion(true);

    await _beginListening();
  }

  void _startTimers() {
    _countTimer?.cancel();
    _autoSubmitTimer?.cancel();

    _countTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _timeLeft -= const Duration(seconds: 1));
    });

    _autoSubmitTimer =
        Timer(const Duration(minutes: 5), () => mounted ? _submit() : null);
  }

  Future<void> _beginListening() async {
    if (!await _speech.initialize()) return;
    if (!mounted) return;
    setState(() => _listening = true);

    _speech.listen(
      onResult: (r) {
        if (!mounted || _disposed) return;
        final old = _tc.value;
        final txt = r.recognizedWords;
        final caret = math.min(old.selection.baseOffset, txt.length);
        _tc.value = old.copyWith(
          text: txt,
          selection: TextSelection.collapsed(offset: caret),
        );
      },
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
      listenFor: const Duration(minutes: 5),
      pauseFor:  const Duration(minutes: 5),
    );
  }

  /* ─────────  Pause / resume mic only ───────── */
  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      await _speech.cancel();
      if (mounted) setState(() => _listening = false);
    } else {
      await _beginListening();
    }
  }

  /* ─────────  Score helper ───────── */
  int _score(String a, String t) {
    final w = (String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').split(RegExp(r'\s+'));
    final s1 = w(a).toSet(), s2 = w(t).toSet();
    return s1.isEmpty ? 0 : ((s1.intersection(s2).length / s1.length) * 100).round();
  }

  /* ─────────  Submit current Q ───────── */
  Future<void> _submit() async {
    await _speech.stop();
    await _speech.cancel();
    _countTimer?.cancel();
    _autoSubmitTimer?.cancel();

    if (!mounted) return;

    final scr = _score(_ans[_idx], _tc.text);
    _cumScore += scr;

    await FirebaseFirestore.instance
        .collection('students').doc(widget.uid)
        .collection('results').doc('interview_temp')
        .collection('answers')
        .add({'question': _qs[_idx], 'transcript': _tc.text, 'score': scr});

    if (!mounted) return;

    if (_idx + 1 == _total) {
      await FirebaseFirestore.instance
          .collection('students').doc(widget.uid)
          .collection('results')
          .add({
        'score': (_cumScore / _total).round(),
        'questionsAttempted': _total,
        'finishedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _idx++;
        _tc.clear();
        _listening = false;
      });
      _startRound();
    }
  }
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  /* ─────────  UI  ───────── */
  @override
  Widget build(BuildContext context) => Scaffold(
    key: _scaffoldKey,

    
        appBar: AppBar(
          actions: [
            IconButton(
              
          icon: const Icon(Icons.chat,color:Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer(); // Opens the drawer
          },
        ),


          ],
          backgroundColor: const Color(0xff48c26e),
          leading: BackButton(color: Colors.white),
          title: Text('Question ${_idx + 1}/$_total',
              style: const TextStyle(color: Colors.white)),
        ),
        endDrawer: Drawer(
          child: CustomChatBot(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _qs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_qs[_idx],
                        style: const TextStyle(
                            color: Color(0xff48c26e), fontSize: 20)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tc,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText:
                            _listening ? '👂🏻 Listening…' : 'Tap mic to resume',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor:
                            const Color.fromARGB(255, 216, 248, 223),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_timeLeft.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
                      '${_timeLeft.inSeconds.remainder(60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xff48c26e)),
                            icon: Icon(
                                _listening ? Icons.pause : Icons.mic),
                            label: Text(style:TextStyle(color:Colors.white),
                                _listening ? 'Pause Listening' : 'Resume Mic'),
                            onPressed: _toggleListening,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xff48c26e),
                              foregroundColor: Colors.white),
                          onPressed: _submit,
                          child: const Text('Submit'),
                        ),
                        const SizedBox(width: 10),
                        

                      ],
                    ),
                  ],
                ),
        ),
      );

  /* ─────────  CLEANUP  ───────── */
  @override
  void dispose() {
    _disposed = true;
    _speech.cancel();
    _tts.stop();
    _countTimer?.cancel();
    _autoSubmitTimer?.cancel();
    _tc.dispose();
    super.dispose();
  }
}
