
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_cloud_functions_service.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/widgets/choice_challenge.dart';
import 'package:pfe_test/widgets/ordering_challenge.dart';
import 'package:provider/provider.dart';
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
  // ignore: prefer_typing_uninitialized_variables
  var _currentAnswer;
  
  @override
  void initState() {
    super.initState();
    _codeController =
        TextEditingController(text: widget.mission.initialCode ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mission.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: AppTheme.accentColor),
            onPressed: () {
              return _showAITutor(context);
            },
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
              child: SingleChildScrollView(
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
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildChallengeInterface(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.mission.solution = _codeController.text.trim();
                      _showAITutor(context);
                    },
                    icon: const Icon(Icons.lightbulb_outline),
                    label: const Text("Ask me"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _checkAnswer();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeInterface() {
    switch (widget.mission.type) {
      case MissionType.debug:
      case MissionType.complete:
      case MissionType.test:
        return Container(
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
        );
      case MissionType.multipleChoice:
      case MissionType.singleChoice:
        return ChoiceChallenge(
            mission: widget.mission,
            onAnswerChanged: (answer) {
              return _currentAnswer = answer;
            });
      case MissionType.ordering:
        return OrderingChallenge(
            mission: widget.mission,
            onOrderChanged: (order) {
              return _currentAnswer = order;
            });
    }
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

  Future<void> _checkAnswer() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    final ai =
        Provider.of<AppwritecloudfunctionsService>(context, listen: false);
    bool isCorrect = false;
    double rate=0.0 ;
    switch (widget.mission.type) {
      case MissionType.debug:
      case MissionType.complete:
      case MissionType.test:

        showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return Center(
                      child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        color: AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        ),
                    child: const Column(
                      children: [
                        Padding(padding: EdgeInsets.only(top: 40,left:50,right: 50),child: CircularProgressIndicator(),),
                        SizedBox(height: 15,),
                        Text("Checking...",style: TextStyle(fontSize: 13,color: Colors.white),),
                      ],
                    ),
                  ));
                },
              );
        final List<dynamic> check = await ai.checkAnwser(
        authService.progress, widget.mission, _codeController.text.trim());
        Navigator.pop(context);
        isCorrect = check[0];
        rate=check[1];

        break;
      case MissionType.singleChoice:
        isCorrect = _currentAnswer == widget.mission.solution;
        break;
      case MissionType.multipleChoice:
        if (_currentAnswer is List<String>) {
          final correctAnswers = widget.mission.solution?.split(',') ?? [];
          isCorrect = _currentAnswer.length == correctAnswers.length &&
              _currentAnswer.every((item) => correctAnswers.contains(item));
        }
        break;
      case MissionType.ordering:
        if (_currentAnswer is List<String>) {
          final correctOrder = widget.mission.correctOrder ?? [];
          isCorrect = _currentAnswer.length == correctOrder.length &&
              equals(_currentAnswer, correctOrder);
        }
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? "Mission Accomplished!" : "Not Quite..."),
        content: Text(isCorrect
            ? "Great job! You've earned ${widget.mission.points} XP."
            : "That's not the right answer. Try asking the AI Tutor for a hint!"),
        actions: [
          TextButton(
            onPressed: () async {
              //debugPrint("XP = ${authService.progress.experience}");
              if (isCorrect) {
                await authService.updateXp(widget.mission.points);
                await authService.updateMissionStatus(widget.mission.id,rate);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                    (Route<dynamic> route) => false);
              } else {
                await authService.updateFailedNb(widget.mission.id);
                Navigator.pop(context);
              }
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

bool equals(List l1, List l2) {
  if (l1.length != l2.length) return false;
  for (int i = 0; i < l1.length; i++) {
    if (l1[i] != l2[i]) return false;
  }
  return true;
}
