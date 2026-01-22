import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Center")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem("How do I earn points?", "You earn points by completing missions and challenges. The harder the mission, the more points you get!"),
          _buildFaqItem("What are badges?", "Badges are special achievements you unlock by reaching specific milestones in your learning journey."),
          _buildFaqItem("How does the AI Tutor work?", "The AI Tutor uses advanced language models to provide hints and explanations tailored to your current mission."),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [Padding(padding: const EdgeInsets.all(16), child: Text(answer))],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          "Your privacy is important to us. This policy explains how we collect, use, and protect your data...\n\n"
          "1. Data Collection: We collect information you provide during signup and your learning progress.\n\n"
          "2. Data Usage: Your data is used to personalize your learning experience and improve our AI Tutor.\n\n"
          "3. Security: We implement industry-standard security measures to protect your information.",
          style: TextStyle(height: 1.5),
        ),
      ),
    );
  }
}
