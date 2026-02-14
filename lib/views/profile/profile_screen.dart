import 'package:flutter/material.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/appwrite_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    final user = authService.user;
    final String userImage = authService.progress.imageId;
    NetworkImage dataBaseImage = NetworkImage(
        'https://fra.cloud.appwrite.io/v1/storage/buckets/69891b1d0012c9a7e862/files/$userImage/view?project=697295e70021593c3438&mode=admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: userImage.isEmpty ? null : dataBaseImage,
              child: userImage.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? "Guest",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              authService.progress.bio,
              style: const TextStyle(color: AppTheme.accentColor),
            ),
            const SizedBox(height: 32),
            _buildStatRow(context),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "Earned Badges"),
            const SizedBox(height: 16),
            _buildBadgeGrid(context),
            const SizedBox(height: 16),
            _buildSectionTitle(context, "Learning Progress"),
            const SizedBox(height: 16),
            _buildProgressList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(context) {
    final authService = Provider.of<AppwriteService>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Missions", "${authService.progress.nbMissions}"),
        _buildStatItem("Points", "${authService.progress.totalPoints}"),
        _buildStatItem("Rank", "#${authService.progress.rank}"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildBadgeGrid(context) {
    final authService = Provider.of<AppwriteService>(context, listen: false);
    List<String> earnBadges = authService.progress.earnedBadges;
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
    List<Map<String, dynamic>> badges=[];
    for(int i=0;i<allBadges.length;i++){
      if(earnBadges.contains(allBadges[i]['name'])){
        badges.add(allBadges[i]);
      }
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (badges[index]['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: (badges[index]['color'] as Color)
                        .withValues(alpha: 0.5)),
              ),
              child: Icon(badges[index]['icon'] as IconData,
                  color: badges[index]['color'] as Color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(badges[index]['name'] as String,
                style: const TextStyle(fontSize: 8),
                textAlign: TextAlign.center),
          ],
        );
      },
    );
  }

  Widget _buildProgressList() {
    return Column(
      children: [
        _buildProgressItem("Python", 0.8),
        const SizedBox(height: 12),
        _buildProgressItem("Data Structures", 0.4),
        const SizedBox(height: 12),
        _buildProgressItem("Algorithms", 0.2),
      ],
    );
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
}
