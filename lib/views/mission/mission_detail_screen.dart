import 'package:flutter/material.dart';
import '../../models/mission_model.dart';
import '../../theme/app_theme.dart';
import '../chat/ai_tutor_chat.dart';

class MissionDetailScreen extends StatefulWidget {
  final Mission mission;
  const MissionDetailScreen({super.key, required this.mission});

  @override
  State<MissionDetailScreen> createState() => _MissionDetailScreenState();
}

class _MissionDetailScreenState extends State<MissionDetailScreen> {
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.mission.initialCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mission.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: AppTheme.accentColor),
            onPressed: () => _showAITutor(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppTheme.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("MISSION OBJECTIVE",
                      style: TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(widget.mission.description,
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: TextField(
                controller: _codeController,
                maxLines: null,
                style: const TextStyle(
                    fontFamily: 'monospace', color: Colors.greenAccent),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAITutor(context),
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text("Get Hint"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _submitSolution(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Run Code"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAITutor(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: AITutorChat(
              mission: widget.mission, scrollController: controller),
        ),
      ),
    );
  }

  void _submitSolution() {
    // Logic to check solution
    bool isCorrect =
        _codeController.text.trim() == widget.mission.solution.trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? "Mission Accomplished!" : "Not Quite..."),
        content: Text(isCorrect
            ? "Great job! You've earned ${widget.mission.points} XP."
            : "The code didn't pass the tests. Try asking the AI Tutor for a hint!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
