import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
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
    // --- GATEKEEPER ---
    OnboardingQuestion(
      id: 'persona',
      question: "Comment décririez-vous votre profil ?",
      options: [
        OnboardingOption(
            id: 'student',
            label: "Étudiant (Exams/Cours)",
            nextQuestionId: 'level'),
        OnboardingOption(
            id: 'dev_pro',
            label: "Développeur (Maîtriser un langage)",
            nextQuestionId: 'lang_goal'),
        OnboardingOption(
            id: 'curious',
            label: "Débutant (Découvrir les concepts)",
            nextQuestionId: 'curiosity_path'),
      ],
    ),

    // --- PATH: STUDENT ---
    OnboardingQuestion(
      id: 'level',
      question: "Quel est votre niveau actuel ?",
      options: [
        OnboardingOption(
            id: 'lycee', label: "Lycée / Bac", nextQuestionId: 'exam_deadline'),
        OnboardingOption(
            id: 'licence',
            label: "Licence / Prépa",
            nextQuestionId: 'exam_deadline'),
        OnboardingOption(
            id: 'master',
            label: "Master / Ingénieur",
            nextQuestionId: 'exam_deadline'),
      ],
    ),
    OnboardingQuestion(
      id: 'exam_deadline',
      question: "Quand est votre prochain examen important ?",
      options: [
        OnboardingOption(
            id: 'urgent',
            label: "Moins de 2 semaines",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'chill',
            label: "Dans plus d'un mois",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'none', label: "Juste pour réviser", nextQuestionId: 'rythme'),
      ],
    ),

    // --- PATH: LANGUAGE MASTER ---
    OnboardingQuestion(
      id: 'lang_goal',
      question: "Quel langage souhaitez-vous maîtriser ?",
      options: [
        OnboardingOption(
            id: 'py', label: "Python (Data/AI)", nextQuestionId: 'current_exp'),
        OnboardingOption(
            id: 'dart',
            label: "Dart (Flutter/Mobile)",
            nextQuestionId: 'current_exp'),
        OnboardingOption(
            id: 'java',
            label: "Java (Enterprise/Backend)",
            nextQuestionId: 'current_exp'),
        OnboardingOption(
            id: 'js', label: "JavaScript (Web)", nextQuestionId: 'current_exp'),
      ],
    ),
    OnboardingQuestion(
      id: 'current_exp',
      question: "Quelle est votre expérience avec ce langage ?",
      options: [
        OnboardingOption(
            id: 'none',
            label: "Zéro (Je pars de rien)",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'inter',
            label: "Intermédiaire (Je connais la syntaxe)",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'expert',
            label: "Avancé (Je veux optimiser)",
            nextQuestionId: 'rythme'),
      ],
    ),

    // --- PATH: BEGINNER CONCEPTS ---
    OnboardingQuestion(
      id: 'curiosity_path',
      question: "Qu'est-ce qui vous attire le plus ?",
      options: [
        OnboardingOption(
            id: 'logic',
            label: "La logique pure (Algorithmes)",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'visual',
            label: "Le visuel (Comment on fait une App)",
            nextQuestionId: 'rythme'),
        OnboardingOption(
            id: 'ai',
            label: "L'IA (Comment ça réfléchit)",
            nextQuestionId: 'rythme'),
      ],
    ),

    // --- FINAL: COMMITMENT (Universal) ---
    OnboardingQuestion(
      id: 'rythme',
      question: "Combien de temps pouvez-vous consacrer par jour ?",
      options: [
        OnboardingOption(id: 'casual', label: "☕ 10 min (Mode Zen)"),
        OnboardingOption(id: 'serious', label: "⚡ 30 min (Mode Focus)"),
        OnboardingOption(id: 'intense', label: "🔥 1h+ (Mode Hardcore)"),
      ],
    ),
  ];

  late String _currentQuesId;
  final List<String> _history = [];
  final Map<String, String> _answers = {};
  @override
  void initState() {
    super.initState();
    _currentQuesId = _questions.first.id;
  }

  void _handleOptionSelect(OnboardingOption option) {
    setState(() {
      _history.add(_currentQuesId);
      _answers.addEntries({MapEntry(_currentQuestion.id, option.label)});
      if (option.nextQuestionId != null) {
        _currentQuesId = option.nextQuestionId!;
      } else {
        _saveUserChoices();
      }
    });
  }

  OnboardingQuestion get _currentQuestion =>
      _questions.firstWhere((q) => q.id == _currentQuesId);

  void _goBack() {
    if (_history.isNotEmpty) {
      setState(() {
        _answers
            .removeWhere((key, val) => key.contains(_currentQuestion.question));
        _currentQuesId = _history.removeLast();
      });
    }
  }

  void _skip() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()));
  }

  Future<void> _saveUserChoices() async {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    try {
      authService.completeOnboarding(_answers);
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()));
      }
    } catch (e) {
      debugPrint("Errir when saving choices");
    }
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
