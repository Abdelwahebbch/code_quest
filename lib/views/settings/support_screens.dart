import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:provider/provider.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Help Center")),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFaqItem("How do I earn points?",
                "You earn points by completing missions and challenges. The harder the mission, the more points you get!"),
            _buildFaqItem("What are badges?",
                "Badges are special achievements you unlock by reaching specific milestones in your learning journey."),
            _buildFaqItem("How does the AI Tutor work?",
                "The AI Tutor uses advanced Large Language Models to provide hints and explanations tailored to your current mission."),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(padding: const EdgeInsets.all(16), child: Text(answer))
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Privacy Policy")),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Text(
            "Your privacy is important to us. This policy explains how we collect, use, and protect your data...\n\n"
            "1. Data Collection: We collect information you provide during signup and your learning progress.\n\n"
            "2. Data Usage: Your data is used to personalize your learning experience and improve our AI Tutor.\n\n"
            "3. Security: We implement industry-standard security measures to protect your information.",
            style: TextStyle(height: 1.5),
          ),
        ),
      ),
    );
  }
}

class FeedbackBox extends StatefulWidget {
  const FeedbackBox({super.key});

  @override
  State<FeedbackBox> createState() => _FeedbackBoxState();
}

class _FeedbackBoxState extends State<FeedbackBox> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSending = false;

  Future<void> _submitFeedback() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    if (_feedbackController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    authService.database.createRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: 'feedbacks',
        rowId: ID.unique(),
        data: {
          'feedback': _feedbackController.text,
          'username': authService.user!.name,
          'userid': authService.user!.$id
        });

    setState(() => _isSending = false);
    _feedbackController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text("Feedback sent! Thanks for helping CodeQuest grow <3 ")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: const Text("Feedback")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Send Feedback",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText:
                              "How can we improve your learning experience?",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: Colors.black12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _submitFeedback,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text("Submit"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Help us patch the system ! \n \n" 
                  "Use this field to : \n\n"
                  "- Report any bugs you've encountered \n \n"
                  "- Suggest new coding topics you'd like to master \n \n"
                  "- Tell us if a mission's difficulty felt off.\n\n"
                  "Whether it's a technical glitch or a brilliant idea for a new feature, your intel helps us build a better experience for all users <3",
                 style: TextStyle(height: 1.5),
                )
              ],
            ),
          )),
    );
  }
}
