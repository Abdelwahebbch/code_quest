import 'package:flutter/material.dart';
import 'package:pfe_test/models/message_model.dart';
import 'package:pfe_test/services/appwrite_cloud_functions_service.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';

class AITutorChat extends StatefulWidget {
  final Mission mission;
  final ScrollController scrollController;

  const AITutorChat(
      {super.key, required this.mission, required this.scrollController});

  @override
  State<AITutorChat> createState() => _AITutorChatState();
}

class _AITutorChatState extends State<AITutorChat> {
  final List<Message> _messages = [Message(role: "bot", message: "Bonjour")];
  final TextEditingController _messageController = TextEditingController();
  int missionIndex = 0;

  @override
  void initState() {
    super.initState();
    final authservice = Provider.of<AppwriteService>(context, listen: false);

    for (int i = 0; i < authservice.progress.missions.length; i++) {
      if (authservice.progress.missions[i].id == widget.mission.id) {
        missionIndex = i;
      }
    }
    for (int i = 0;
        i < authservice.progress.missions[missionIndex].conversation.length;
        i++) {
      String role = "";
      if (i % 2 == 1) {
        role = "bot";
      } else {
        role = "user";
      }
      Message msg = Message(
          role: role,
          message: authservice.progress.missions[missionIndex].conversation[i]);
      _messages.add(msg);
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(
            children: [
              const Icon(Icons.psychology, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              const Text("AI Tutor",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
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
              final isAI = msg.role == "bot";
              return Align(
                alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  decoration: BoxDecoration(
                    color: isAI ? AppTheme.cardColor : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(15).copyWith(
                      bottomLeft:
                          isAI ? Radius.zero : const Radius.circular(15),
                      bottomRight:
                          isAI ? const Radius.circular(15) : Radius.zero,
                    ),
                  ),
                  child: Text(msg.message,
                      style: const TextStyle(color: Colors.white)),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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

  void _sendMessage() async {
    // ignore: unused_local_variable
    final authservice = Provider.of<AppwriteService>(context, listen: false);
    // ignore: unused_local_variable
    final ai =
        Provider.of<AppwritecloudfunctionsService>(context, listen: false);
    if (_messageController.text.isEmpty) return;
    Message m = Message(
        userInfo: authservice.progress,
        role: "user",
        message: _messageController.text,
        mission: widget.mission);
    setState(() {
      _messages.add(m);
    });
    _messageController.clear();
      _scrollToBottom();
    await authservice.addToConversation(
        missionIndex, widget.mission.id, m.message);
    final data = await ai.sendMessage(m);
    setState(() {
      // Mock AI response
      _messages.add(Message(role: "bot", message: data["response"]));
    });
    _scrollToBottom();
    await authservice.addToConversation(
        missionIndex, widget.mission.id, data["response"]?.toString() ?? "");
    await authservice.updateMissionAiPoints(widget.mission.id);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
