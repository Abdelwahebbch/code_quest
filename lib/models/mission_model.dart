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
