import 'package:flutter/material.dart';
import 'package:pfe_test/models/mock_data.dart';
import 'package:pfe_test/services/appwrite_service.dart';
import 'package:provider/provider.dart';
import '../models/user_info_model.dart';
import '../theme/app_theme.dart';
import '../views/learning_path/learning_path_screen.dart';

class ProgressCard extends StatelessWidget {
  final UserInfo user;

  const ProgressCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final authservice =
            Provider.of<AppwriteService>(context, listen: false);
        final learningPath = authservice.path;
        // LearningPathSampleData.getSamplePythonPath();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LearningPathScreen(
              learningPath: learningPath,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Level",
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text("${user.userLevel}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("${user.totalPoints} pts",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: user.progressToNextLevel,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${(user.progressToNextLevel * 100).toInt()}% to Level ${user.userLevel + 1}",
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const Text("Tap to view learning path",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
