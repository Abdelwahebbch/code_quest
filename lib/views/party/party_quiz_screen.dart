import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:provider/provider.dart';
import 'party_results_screen.dart';

class PartyQuizScreen extends StatefulWidget {

  final String rowId;
  const PartyQuizScreen({
    super.key,
    required this.rowId,
    
  });

  @override
  State<PartyQuizScreen> createState() => _PartyQuizScreenState();
}

class _PartyQuizScreenState extends State<PartyQuizScreen> {
  late Party _party;
  int _currentRound = 1;
  int _timeRemaining = 30;
  bool _answered = false;
  String? _selectedAnswer;
  late DateTime _roundStartTime;
  int? answerIndex;
  late int memberIndex;
  // Mock questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the output of print(2 ** 3) in Python?',
      'options': ['6', '8', '9', '5'],
      'correct': 1,
      'category': 'Python Basics',
    },
    {
      'question': 'Which keyword is used to declare a variable in JavaScript?',
      'options': ['var', 'variable', 'declare', 'let'],
      'correct': 0,
      'category': 'JavaScript',
    },
    {
      'question': 'What does API stand for?',
      'options': [
        'Application Programming Interface',
        'Application Process Integration',
        'Advanced Programming Interface',
        'Application Protocol Interface'
      ],
      'correct': 0,
      'category': 'General',
    },
  ];

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AppwriteService>(context, listen: false);
    _party = authService.party;
    _roundStartTime = DateTime.now();
    for(int i=0;i<_party.memberCount;i++){
      if(_party.members[i].userId==authService.user?.$id){
        memberIndex=i;
      }
    }
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted ) {
        setState(() {
          _timeRemaining--;
          if (_timeRemaining <= 0) {
            if(answerIndex != null){
              _submitAnswer(answerIndex);
            }
            _submitAnswer(null);
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
      this.answerIndex=answerIndex!;
    });
    // 7asben les point (local just pour le test ) 
    if(_timeRemaining==0){
    bool isCorrect = answerIndex ==
        _questions[(_currentRound - 1) % _questions.length]['correct'];
    
    _party.members[memberIndex].score += isCorrect? 10:0; 
    _party.members[memberIndex].correctAnswers += isCorrect? 1:0;
    _party.members[memberIndex].totalAnswers += 1;
    print(isCorrect);
    Future.delayed(const Duration(seconds: 2), () async {
      if (_currentRound < _party.totalRounds) {
        setState(() {
          _currentRound++;
          _timeRemaining = 30;
          _answered = false;
          _selectedAnswer = null;
          _roundStartTime = DateTime.now();
        });
        _startTimer();
      } else {
        // Game finished
        await authService.submitAnswer(widget.rowId,memberIndex,_party.members[memberIndex].score, _party.members[memberIndex].correctAnswers,_party.members[memberIndex].totalAnswers);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PartyResultsScreen(rowId:widget.rowId),
          ),
        );
      }
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[(_currentRound - 1) % _questions.length];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_party.partyName} - Round $_currentRound/${_party.totalRounds}'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        final isCorrect = index == currentQuestion['correct'];
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
                            backgroundColor = Colors.red.withValues(alpha: 0.2);
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
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
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
    );
  }
}
