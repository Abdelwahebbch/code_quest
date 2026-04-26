import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/services/Data/party_data_provider.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

class PartyResultsScreen extends StatefulWidget {
  final String rowId;
  const PartyResultsScreen({
    super.key,
    required this.rowId,
  });

  @override
  State<PartyResultsScreen> createState() => _PartyResultsScreenState();
}

class _PartyResultsScreenState extends State<PartyResultsScreen>
    with TickerProviderStateMixin {
  late List<PartyMember> _rankedMembers;
  late AnimationController _animationController;
  bool _isLoading = true;
  late bool isHost;
  Future<void> checkWinner() async {
    final authService = Provider.of<PartyDataProvider>(context, listen: false);
    final dataService = Provider.of<DataProvider>(context, listen: false);
    await authService.updateMembersDetails(widget.rowId);
    _rankedMembers = List.from(authService.party.members)
      ..sort((a, b) => b.score.compareTo(a.score));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (authService.party.hostId == authService.authProvider.currentUser!.id) {
      await authService.savePartyHistory(_rankedMembers);
    }
    if (authService.authProvider.currentUser!.id == _rankedMembers[0].userId) {
      await dataService.updateUserPoints(authService.partyMember.score);
    }
  }

  void exit() async {
    await Provider.of<PartyDataProvider>(context, listen: false).quiteLobby(null);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
    checkWinner();
    final authService = Provider.of<PartyDataProvider>(context, listen: false);
    var party = authService.party;
    isHost = party.hostId == authService.authProvider.currentUser!.id;
    var subscriptionParty = authService.appwriteService.realtime.subscribe([
      Channel.tablesdb("6972adad002e2ba515f2").table("party").row(party.partyId)
    ]);
    if (!isHost) {
      subscriptionParty.stream.listen((response) {
        Map<String, dynamic> row = response.payload;
        if (response.events.first.contains("delete")) {
          if (!isHost && row["\$id"] == party.partyId && mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The owner just close the party'),
              ),
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<PartyDataProvider>(context, listen: false);
    if (_isLoading) {
      //TODO : lazem ttbaddel
      return const SafeArea(
        child: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return SafeArea(
        child: PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'To leave the party results, tap the "Back to Home" button in the Bottom.'),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Results'),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Winner Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Game Finished!',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 20),
                    if (_rankedMembers.isNotEmpty)
                      Column(
                        children: [
                          Text(
                            'Winner',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _rankedMembers[0].username,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Text(
                              '${_rankedMembers[0].score} points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Rankings
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Final Rankings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _rankedMembers.length,
                      itemBuilder: (context, index) {
                        final member = _rankedMembers[index];
                        final medalEmoji = index == 0
                            ? '🥇'
                            : index == 1
                                ? '🥈'
                                : index == 2
                                    ? '🥉'
                                    : '${index + 1}.';

                        return ScaleTransition(
                          scale: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                index * 0.1,
                                (index + 1) * 0.1,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: index < 3
                                    ? AppTheme.primaryColor
                                        .withValues(alpha: 0.3)
                                    : Colors.grey.withValues(alpha: 0.2),
                                width: index < 3 ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  medalEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 16),
                                CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor
                                      .withValues(alpha: 0.2),
                                  child: Text(
                                    member.username[0].toUpperCase(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Accuracy: ${member.accuracy.toStringAsFixed(1)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${member.score}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'pts',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppTheme.primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Stats Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Total Players',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_rankedMembers.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Avg Score',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (_rankedMembers.fold<int>(
                                        0, (sum, m) => sum + m.score) /
                                    _rankedMembers.length)
                                .toStringAsFixed(0),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Total Questions',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${authService.party.totalRounds}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          exit();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isHost)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () async {
                            await authService.partyPlayAgain();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Play Again',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
