import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<Map<String, dynamic>> allBadges = [
    {
      'name': 'Bug Hunter',
      'desc': 'Fix 10 debugging missions',
      'icon': Icons.bug_report,
      'color': Colors.green,
      'unlocked': false
    },
    {
      'name': 'Code Ninja',
      'desc': 'Complete 5 missions without hints',
      'icon': Icons.bolt,
      'color': Colors.orange,
      'unlocked': false
    },
    {
      'name': 'Test Master',
      'desc': 'Write 20 unit tests',
      'icon': Icons.verified,
      'color': Colors.blue,
      'unlocked': false
    },
    {
      'name': 'Fast Learner',
      'desc': 'Complete 3 missions in one day',
      'icon': Icons.speed,
      'color': Colors.purple,
      'unlocked': false
    },
    {
      'name': 'Architect',
      'desc': 'Design a complex system',
      'icon': Icons.architecture,
      'color': Colors.red,
      'unlocked': false
    },
    {
      'name': 'Clean Coder',
      'desc': 'Maintain high code quality',
      'icon': Icons.cleaning_services,
      'color': Colors.teal,
      'unlocked': false
    },
    {
      'name': 'Team Player',
      'desc': 'Review 5 peer solutions',
      'icon': Icons.groups,
      'color': Colors.indigo,
      'unlocked': false
    },
    {
      'name': 'AI Whisperer',
      'desc': 'Ask 50 insightful questions',
      'icon': Icons.psychology,
      'color': Colors.pink,
      'unlocked': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context ,listen: false);
    List<String> ownBadges =  authService.progress.earnedBadges;
    setState(() {
      for (var bagde in allBadges) {
        if (ownBadges.contains(bagde['name'])) {
          bagde['unlocked'] = true;
        }
      }
      
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Achievements"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(allBadges),
            const SizedBox(height: 24),
            Text("All Badges", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: allBadges.length,
                itemBuilder: (context, index) {
                  final badge = allBadges[index];
                  return _buildBadgeCard(badge);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<Map<String, dynamic>> badges) {
    final unlockedCount = badges.where((b) => b['unlocked'] == true).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.accentColor]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Colors.white),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$unlockedCount / ${badges.length}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const Text("Badges Unlocked",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> badge) {
    final bool isUnlocked = badge['unlocked'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked ? Border.all(color: badge['color'], width: 1) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.3,
            child: Icon(badge['icon'], size: 48, color: badge['color']),
          ),
          const SizedBox(height: 12),
          Text(
            badge['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.white : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge['desc'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          if (!isUnlocked) ...[
            const SizedBox(height: 8),
            const Icon(Icons.lock, size: 16, color: Colors.grey),
          ]
        ],
      ),
    );
  }
}
