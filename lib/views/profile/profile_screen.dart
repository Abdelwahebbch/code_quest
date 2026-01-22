import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "DevExplorer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Level 4 Software Engineer",
              style: TextStyle(color: AppTheme.accentColor),
            ),
            const SizedBox(height: 32),
            _buildStatRow(),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "Earned Badges"),
            const SizedBox(height: 16),
            _buildBadgeGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "Learning Progress"),
            const SizedBox(height: 16),
            _buildProgressList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("Missions", "24"),
        _buildStatItem("Points", "1,200"),
        _buildStatItem("Rank", "#12"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildBadgeGrid() {
    final badges = [
      {'name': 'Bug Hunter', 'icon': Icons.bug_report, 'color': Colors.green},
      {'name': 'Code Ninja', 'icon': Icons.bolt, 'color': Colors.orange},
      {'name': 'Test Master', 'icon': Icons.verified, 'color': Colors.blue},
      {'name': 'Fast Learner', 'icon': Icons.speed, 'color': Colors.purple},
    ];

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
                color: (badges[index]['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: (badges[index]['color'] as Color).withOpacity(0.5)),
              ),
              child: Icon(badges[index]['icon'] as IconData, color: badges[index]['color'] as Color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(badges[index]['name'] as String, style: const TextStyle(fontSize: 8), textAlign: TextAlign.center),
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
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
