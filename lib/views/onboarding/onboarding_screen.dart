import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/onboarding_model.dart';
import '../dashboard/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _SmartOnboardingScreenState();
}

class _SmartOnboardingScreenState extends State<OnboardingScreen> {
  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      id: 'goal_beg',
      question: "Quel est votre objectif principal ?",
      options: [
        OnboardingOption(
            id: 'bases', label: "Apprendre les bases", nextQuestionId: 'level'),
        OnboardingOption(
            id: 'hobby', label: "Préparer un examen", nextQuestionId: 'level'),
        OnboardingOption(
            id: 'hobby',
            label: "Améliorer tes compétences",
            nextQuestionId: 'level'),
      ],
    ),
    OnboardingQuestion(
      id: 'level',
      question: "Quel est ton niveau d'étude ?",
      options: [
        OnboardingOption(id: 'lycee', label: "Lycée", nextQuestionId: 'lang'),
        OnboardingOption(
            id: 'licence', label: "Licence", nextQuestionId: 'lang'),
        OnboardingOption(id: 'master', label: "Master", nextQuestionId: 'lang'),
        OnboardingOption(id: 'autre', label: "Autre", nextQuestionId: 'rythme'),
      ],
    ),
    OnboardingQuestion(
      id: 'lang',
      question: "Quel langage vous est la plus familière ?",
      options: [
        OnboardingOption(id: 'py', label: "Python", nextQuestionId: 'rythme'),
        OnboardingOption(id: 'java', label: "Java", nextQuestionId: 'rythme'),
        OnboardingOption(id: 'dart', label: "Dart", nextQuestionId: 'rythme'),
        OnboardingOption(id: 'C', label: "C / C++", nextQuestionId: 'rythme'),
      ],
    ),
    OnboardingQuestion(
      id: 'rythme',
      question: "Quel rythme d'apprentissage préférez-vous ?",
      options: [
        OnboardingOption(id: 'casual', label: "Occasionnel (15 min/jour)"),
        OnboardingOption(id: 'serious', label: "Sérieux (1h/jour)"),
        OnboardingOption(id: 'intense', label: "Intensif (3h+/jour)"),
      ],
    ),
  ];

  late String _currentQuesId;
  final List<String> _history = [];
  @override
  void initState() {
    super.initState();
    _currentQuesId = _questions.first.id;
  }

  void _handleOptionSelect(OnboardingOption op) {
    setState(() {
      _history.add(_currentQuesId);
      if (op.nextQuestionId != null) {
        _currentQuesId = op.nextQuestionId!;
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    });
  }

  OnboardingQuestion get _currentQuestion =>
      _questions.firstWhere((q) => q.id == _currentQuesId);

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _currentQuesId = _history.removeLast();
      });
    }
  }

  void _skip() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final progress = _history.length / (_questions.length - 1);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_history.isNotEmpty)
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  GestureDetector(
                    onTap: _skip,
                    child: const Text("Skip"),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              LinearProgressIndicator(
                value: progress,
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                key: ValueKey(_currentQuestion.id),
                children: [
                  Text(
                    _currentQuestion.question,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentQuestion.options.length,
                      itemBuilder: (context, idx) {
                        return _buildOptionCard(_currentQuestion.options[idx]);
                      })
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(OnboardingOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => _handleOptionSelect(option),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option.label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
