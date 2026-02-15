import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../theme/app_theme.dart';
import '../views/mission/mission_detail_screen.dart';

class MissionTile extends StatelessWidget {
  final Mission mission;

  const MissionTile({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    bool isComplete =mission.isCompleted;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getIcon(), color: AppTheme.primaryColor),
        ),
        title: Text(mission.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(mission.description,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag("${mission.points} XP", AppTheme.accentColor),
                const SizedBox(width: 8),
                _buildTag(
                    "Diff: ${mission.difficulty}/5", AppTheme.warningColor),
              ],
            ),
          ],
        ),
        trailing: isComplete? const Icon(Icons.check,color: AppTheme.warningColor,): const Icon(Icons.chevron_right),
        onTap: () {
          //add if is it commplet
         if(!isComplete){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MissionDetailScreen(mission: mission)),
          );
         }else{
          null;
         }
          
          
        },
      ),
    );
  }

  IconData _getIcon() {
    switch (mission.type) {
      case MissionType.debug:
        return Icons.bug_report;
      case MissionType.complete:
        return Icons.code;
      case MissionType.test:
        return Icons.checklist;
      case MissionType.multipleChoice:
        return Icons.rule;
      case MissionType.singleChoice:
        return Icons.quiz;
      case MissionType.ordering:
        return Icons.reorder;
    }
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
