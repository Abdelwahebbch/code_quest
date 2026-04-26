import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> with SingleTickerProviderStateMixin{
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
  late TabController _tabController;
  int selectedTab = 0;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedTab = _tabController.index;
      });
    });
  }

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Badges")),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: const Color.fromARGB(255, 189, 175, 175),
            tabs: const [
              Tab(text: 'All Badges'),
              Tab(text: 'Progress'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            badges(),
            _buildProgressList(context)
          ],
        ),
      ),
    );
  }
    Widget _buildProgressList(context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    Map<String, dynamic> progress = authService.progress.badgesProgress;
    int missionsCompletedToday = 0;
    for (int i = 0; i < authService.progress.missions.length; i++) {
      if (authService.progress.missions[i].isCompleted) {
        missionsCompletedToday += 1;
      }
    }
    double bugHunter =
        (progress['debug'] / 10) >= 1 ? 1 : progress['debug'] / 10;
    double codeNinja =
        ((authService.progress.nbMissionCompletedWithoutHints / 10) * 2) >= 1
            ? 1
            : (authService.progress.nbMissionCompletedWithoutHints / 10) * 2;
    double TestMaster =
        ((progress['test'] / 10) * 2) >= 1 ? 1 : (progress['test'] / 10) * 2;
    double FastLearner =
        missionsCompletedToday / 3 >= 1 ? 1 : missionsCompletedToday / 3;
    double Architect =
        progress['ordering'] / 10 >= 1 ? 1 : progress['ordering'] / 10;
    double CleanCoder =
        ((progress['complete'] / 10 > 1 ? 1 : progress['complete'] / 10) +
                (authService.progress.totalFailures / 30 > 1
                    ? 1
                    : authService.progress.totalFailures / 30)) /
            2;
    double TeamPlayer = ((progress['singleChoice'] / 10 > 1
                ? 1
                : progress['singleChoice'] / 10) +
            (progress['multipleChoice'] / 10 > 1
                ? 1
                : progress['multipleChoice'] / 10)) /
        2;
    double AIWhisperer = (authService.progress.totalAIQuestions / 50) > 1
        ? 1
        : (authService.progress.totalAIQuestions / 50);

    //TODO : lazem dynamique
    return SingleChildScrollView(
      child: 
      Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Bug Hunter", bugHunter),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Code Ninja", codeNinja),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Test Master", TestMaster),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Fast Learner", FastLearner),
        ),
        const SizedBox(height: 12),
        Padding(
         padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Architect", Architect),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Clean Coder", CleanCoder),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("Team Player", TeamPlayer),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 10),
          child: _buildProgressItem("AI Whisperer", AIWhisperer),
        ),
        const SizedBox(height: 12),
      ],
    ));
  }

  Widget _buildProgressItem(String title, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("${(progress * 100).toInt()}%"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
  Widget badges(){
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding:  EdgeInsets.only(left:10.0),
                child:  Text(
                  "Your Achievements",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: _buildSummaryCard(allBadges),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text("All Badges", style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: GridView.builder(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
