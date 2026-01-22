enum MissionType { debug, complete, test }

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int points;
  final int difficulty; // 1-5
  final String initialCode;
  final String solution;
  bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.points,
    required this.difficulty,
    required this.initialCode,
    required this.solution,
    this.isCompleted = false,
  });
}

class UserProgress {
  final String username;
  int level;
  int experience;
  int totalPoints;
  List<String> earnedBadges;

  UserProgress({
    required this.username,
    this.level = 1,
    this.experience = 0,
    this.totalPoints = 0,
    this.earnedBadges = const [],
  });

  double get progressToNextLevel => (experience % 1000) / 1000;
}
