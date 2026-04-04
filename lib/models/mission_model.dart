import 'package:appwrite/models.dart';

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
  String? solution;
  final List<dynamic>? options;
  final List<dynamic>? correctOrder;
  bool isCompleted;
  int nbFailed;
  int aiPointsUsed;
  List<String> conversation;

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
    this.nbFailed = 0,
    this.aiPointsUsed = 0,
    this.conversation = const [],
  });

  factory Mission.completeMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.complete,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"]);
  }
  factory Mission.jsonCompleteMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.complete,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"]);
  }

  factory Mission.testMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.test,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"],
        solution: row.data["solution"]);
  }
  factory Mission.jsonTestMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.test,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"],
        solution: row["solution"]);
  }

  factory Mission.debugMission(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.debug,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        initialCode: row.data["initialCode"]);
  }
  factory Mission.jsonDebugMission(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.debug,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        initialCode: row["initialCode"]);
  }

  factory Mission.singleChoice(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.singleChoice,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        options: row.data["options"],
        solution: row.data["solution"]);
  }
  factory Mission.jsonSingleChoice(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id",
        title: row['title'],
        description: row['description'],
        type: MissionType.singleChoice,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        options: row["options"],
        solution: row["solution"]);
  }

  factory Mission.multipleChoice(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.multipleChoice,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        options: row.data["options"],
        solution: row.data["solution"]);
  }
  factory Mission.jsonMultipleChoice(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id2",
        title: row['title'],
        description: row['description'],
        type: MissionType.multipleChoice,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        options: row["options"],
        solution: row["solution"]);
  }

  //mrigla
  factory Mission.ordering(Row row) {
    return Mission(
        id: row.$id,
        title: row.data['title'],
        description: row.data['description'],
        type: MissionType.ordering,
        points: row.data['points'],
        difficulty: row.data['difficulty'],
        nbFailed: row.data['nbFailed'],
        aiPointsUsed: row.data['aiPointsUsed'],
        isCompleted: row.data['isCompleted'],
        conversation: List<String>.from(row.data['conversation'] ?? []),
        correctOrder: row.data["correctOrder"],
        options: row.data["options"]);
  }
  factory Mission.jsonOrdering(Map<String, dynamic> row) {
    return Mission(
        id: "mission_id2",
        title: row['title'],
        description: row['description'],
        type: MissionType.ordering,
        points: row['points'],
        difficulty: row['difficulty'],
        nbFailed: row['nbFailed'],
        aiPointsUsed: row['aiPointsUsed'],
        isCompleted: row['isCompleted'],
        conversation: List<String>.from(row['conversation'] ?? []),
        correctOrder: row["correctOrder"],
        options: row["options"]);
  }
}
