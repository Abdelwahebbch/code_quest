import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'party_results_screen.dart';

class PartyQuizScreen extends StatefulWidget {
  final questions;
  const PartyQuizScreen({
    super.key,
    this.questions,
  });

  @override
  State<PartyQuizScreen> createState() => _PartyQuizScreenState();
}

class _PartyQuizScreenState extends State<PartyQuizScreen> {
  late Party _party;
  int _currentRound = 1;
  int _timeRemaining = 30;
  String? _selectedAnswer;
  late DateTime roundStartTime;
  bool _answered = false;
  int? answerIndex;
  late PartyMember partyMember;
  // Mock questions
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    _party = authService.party;
    roundStartTime = DateTime.now();
    partyMember = authService.partyMember;
    _questions = widget.questions;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            if (answerIndex != null) {
              _submitAnswer(answerIndex);
            } else {
              _submitAnswer(null);
            }
          } else {
            _startTimer();
          }
        });
      }
    });
  }

  void _submitAnswer(int? answerIndex) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    setState(() {
      _answered = true;
      if (answerIndex != null) {
        this.answerIndex = answerIndex;
      }
    });
    // 7asben les point (local just pour le test )
    if (_timeRemaining == 0) {
      bool isCorrect = answerIndex ==
          _questions[(_currentRound - 1) % _questions.length]['correct'];

      partyMember.score += isCorrect ? 10 : 0;
      partyMember.correctAnswers += isCorrect ? 1 : 0;
      partyMember.totalAnswers += 1;
      print("isCorrect $isCorrect");
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        if (_currentRound < _party.totalRounds) {
          setState(() {
            print("_currentRound   : $_currentRound");
            _currentRound++;
            print("_currentRound incermented  : $_currentRound");
            _timeRemaining = 30;
            _answered = false;
            _selectedAnswer = null;
            roundStartTime = DateTime.now();
          });
          _startTimer();
        } else {
          // Game finished
          await authService.submitAnswer(partyMember);
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PartyResultsScreen(rowId: _party.partyId),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final currentQuestion = _questions[(_currentRound - 1) % _questions.length];
    final authService = Provider.of<AppwriteService>(context, listen: false);
    return SafeArea(
      child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('To leave the quiz, tap the back arrow in the top-left corner.'),
            ),
          );
        },
          child: Scaffold(
            body: Column(
              children: [
                Stack(
                  children: [
                    Container(
                        height: 70,
                        width: double.infinity,
                        color: AppTheme.primaryColor),
                    Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 3,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: () async {
                                await authService.quiteLobby(null);
                                Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const DashboardScreen()),
                              (route) => false,
                            );
                              },
                            ),
      
                            const SizedBox(width: 20),
      
                            Text(
              '${_party.partyName} - Round $_currentRound/${_party.totalRounds}',style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),),
      
                      
                          ],
                        ))
                  ],
                ),
                // Timer and Score Header
                Container(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time Remaining',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '$_timeRemaining s',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _timeRemaining <= 10
                                      ? Colors.red
                                      : AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Players Online',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_party.memberCount}/${_party.maxMembers}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      
                // Question
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            currentQuestion['category'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentQuestion['question'],
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 30),
      
                        // Answer Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: currentQuestion['options'].length,
                            itemBuilder: (context, index) {
                              final option = currentQuestion['options'][index];
                              final isSelected = _selectedAnswer == option;
                              final isCorrect =
                                  index == currentQuestion['correct'];
                              final showResult = _answered;
      
                              Color backgroundColor;
                              if (!showResult) {
                                backgroundColor = isSelected
                                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                                    : AppTheme.cardColor;
                              } else {
                                if (isCorrect) {
                                  backgroundColor =
                                      Colors.green.withValues(alpha: 0.2);
                                } else if (isSelected && !isCorrect) {
                                  backgroundColor =
                                      Colors.red.withValues(alpha: 0.2);
                                } else {
                                  backgroundColor = AppTheme.cardColor;
                                }
                              }
      
                              return GestureDetector(
                                onTap: _answered
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedAnswer = option;
                                        });
                                        _submitAnswer(index);
                                      },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryColor
                                          : Colors.grey.withValues(alpha: 0.2),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ),
                                      if (showResult)
                                        Icon(
                                          isCorrect ? Icons.check : Icons.close,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _currentRound / _party.totalRounds,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
