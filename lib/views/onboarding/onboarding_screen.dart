import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/views/onboarding/language_selection_screen.dart';
import 'package:pfe_test/waiting/generating_path_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/onboarding_model.dart';
import '../dashboard/dashboard_screen.dart';
import 'questions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _SmartOnboardingScreenState();
}

class _SmartOnboardingScreenState extends State<OnboardingScreen> {
  late String _currentQuesId;
  final List<String> _history = [];
  final Map<String, String> _answers = {};
  DateTime? startDate;
  DateTime? endDate;
  int questionsLen = 1;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _currentQuesId = questions.first.id;
  }

  void _handleOptionSelect(OnboardingOption option) async {
    switch (option.id) {
      case "hs_student":
        questionsLen = 5;
        break;
      case "uni_student":
        questionsLen = 5;
        break;

      case "explorer":
        questionsLen = 4;
        break;
      default:
    }
    if (option.label.contains("Select range")) {
      final DateTimeRange? selectedRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2025),
        lastDate: DateTime(2027),
      );
      if (selectedRange == null) {
        return;
      }

      startDate = selectedRange.start;
      endDate = selectedRange.end;
    }

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
      questions.firstWhere((q) => q.id == _currentQuesId);

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
    try {
      _answers.addEntries({
        MapEntry("exam_start",
            startDate != null ? startDate!.toIso8601String() : "undefined")
      });
      _answers.addEntries({
        MapEntry("exam_end",
            endDate != null ? endDate!.toIso8601String() : "undefined")
      });
      setState(() {
        _isLoading = true;
      });

      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>  LanguageSelectionScreen(answers : _answers)));
      }
    } catch (e) {
      debugPrint("Error when saving choices $e");
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final progress = _history.length / questionsLen;
    if (_isLoading) {
      return const SafeArea(
          child: Center(
              child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ))));
    }
    return SafeArea(
      child: Scaffold(
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
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                          return _buildOptionCard(
                              _currentQuestion.options[idx]);
                        })
                  ],
                )
              ],
            ),
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option.label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
