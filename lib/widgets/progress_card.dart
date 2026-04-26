import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_info_model.dart';
import '../theme/app_theme.dart';


class ProgressCard extends StatelessWidget {
  final UserInfo user;

  const ProgressCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          // final authservice =
          //     Provider.of<AuthProvider>(context, listen: false);

          // if (authservice.user!.$id != authservice.path.userId) Exception("For previous user ");

          // final learningPath = authservice.path;
          // // LearningPathSampleData.getSamplePythonPath();

          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => LearningPathScreen(
          //       learningPath: learningPath,
          //     ),
          //   ),
          // );
        } catch (e) {
          showDialog(
              context: context,
              builder: (context) => const AlertDialog(
                    icon: Icon(Icons.info),
                    title: Text(
                      "Learning path not found ! ",
                      style: TextStyle(fontSize: 12),
                    ),
                    content: Text("We can't load your lerning path "),
                  ));
        }
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
