import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class CustomChatBot extends StatefulWidget {
  const CustomChatBot({super.key});

  @override
  State<CustomChatBot> createState() => _CustomChatBotState();
}


class _CustomChatBotState extends State<CustomChatBot> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> messages = [];

  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyA6u6lPtVxRSAMXWigNUiDDGJLF9NAXOWw";
  final headers = {'Content-Type': 'application/json'};

  bool isLoading = false;

Future<void> sendMessage(String text) async {
  setState(() {
    isLoading = true;
    messages.insert(0, ChatMessage(text: text, isUser: true));
  });

  final body = jsonEncode({
    "contents": [
      {
        "parts": [
          {"text": "$text\nKeep the response short and concise."}
        ]
      }
    ]
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final botReply = result['candidates'][0]['content']['parts'][0]['text'];
      setState(() {
        messages.insert(0, ChatMessage(text: botReply, isUser: false));
      });
    } else {
      setState(() {
        messages.insert(0, ChatMessage(text: "Error: ${response.statusCode}", isUser: false));
      });
    }
  } catch (e) {
    setState(() {
      messages.insert(0, ChatMessage(text: "Error: $e", isUser: false));
    });
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 132, 233, 104),title: const Text("Your assistant")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
             child: isLoading?
   Center(child: CircularProgressIndicator(color: Colors.green,)):
               ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                          msg.isUser ? 64.0 : 16.0,
                          4,
                          msg.isUser ? 16.0 : 64.0,
                          4,
                        ),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color:
                              msg.isUser ? const Color.fromARGB(255, 5, 243, 9) : const Color.fromARGB(255, 132, 233, 104),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: MarkdownBody(
                          data: msg.text,
                          styleSheet:
                              MarkdownStyleSheet.fromTheme(Theme.of(context))
                                  .copyWith(
                            p: TextStyle(
                              color: msg.isUser ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        _controller.clear();
                        sendMessage(text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
