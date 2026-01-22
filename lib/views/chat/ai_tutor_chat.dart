import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';

class AITutorChat extends StatefulWidget {
  final Mission mission;
  final ScrollController scrollController;

  const AITutorChat({super.key, required this.mission, required this.scrollController});

  @override
  State<AITutorChat> createState() => _AITutorChatState();
}

class _AITutorChatState extends State<AITutorChat> {
  final List<Map<String, String>> _messages = [
    {"role": "ai", "content": "Hello! I'm your AI Tutor. Stuck on this mission? I can give you a hint or explain the concepts involved."}
  ];
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              const Text("AI Tutor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isAI = msg["role"] == "ai";
              return Align(
                alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isAI ? AppTheme.cardColor : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(15).copyWith(
                      bottomLeft: isAI ? Radius.zero : const Radius.circular(15),
                      bottomRight: isAI ? const Radius.circular(15) : Radius.zero,
                    ),
                  ),
                  child: Text(msg["content"]!, style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Ask for a hint...",
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    
    setState(() {
      _messages.add({"role": "user", "content": _messageController.text});
      // Mock AI response
      _messages.add({"role": "ai", "content": "That's a great question! In software engineering, this concept is called encapsulation. Try looking at how the variables are accessed..."});
    });
    _messageController.clear();
  }
}
