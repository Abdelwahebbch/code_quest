enum MissionType {
  debug,
  complete,
  test,
  singleChoice,
  multipleChoice,
  ordering
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int points;
  final int difficulty; // 1-5
  final String? initialCode;
  final String? solution;
  final List<dynamic>? options;
  final List<dynamic>? correctOrder;
  bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.points,
    required this.difficulty,
    this.initialCode,
    this.solution,
    this.options, 
    this.correctOrder, 
    this.isCompleted = false,
  });
}
