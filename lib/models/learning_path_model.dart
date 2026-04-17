import 'package:pfe_test/models/mission_model.dart';

class Concept {
  final String id;
  final String name;
  final String description;
  final String category;
  final int difficulty; // 1-5
  final int estimatedHours;
  final List<String> prerequisites;
  final List<String> relatedMissions;
  final String icon;
  final bool isCompleted;
  final int completionPercentage; // 0-100
  final DateTime? startedAt;
  final DateTime? completedAt;

  Concept({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedHours,
    required this.prerequisites,
    required this.relatedMissions,
    required this.icon,
    this.isCompleted = false,
    this.completionPercentage = 0,
    this.startedAt,
    this.completedAt,
  });

  factory Concept.fromJson(Map<String, dynamic> json) {
    return Concept(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 0,
      estimatedHours: json['estimatedHours'] ?? 0,
      // Safely parse lists of strings
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      relatedMissions: List<String>.from(json['relatedMissions'] ?? []),
      icon: json['icon'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completionPercentage: json['completionPercentage'] ?? 0,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      id: json['\$id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'name': name,
      'description': description,
      'category': category,
      'difficulty': difficulty,
      'estimatedHours': estimatedHours,
      'prerequisites': prerequisites,
      'relatedMissions': relatedMissions,
      'icon': icon,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class LearningPathMilestone {
  final String id;
  final String title;
  final String description;
  final List<Concept> concepts;
  final int order;
  final bool isUnlocked;
  final bool isCompleted;
  final int completionPercentage;
  final String icon;
  final DateTime? unlockedAt;
  final DateTime? completedAt;

  LearningPathMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.concepts,
    required this.order,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.completionPercentage = 0,
    required this.icon,
    this.unlockedAt,
    this.completedAt,
  });

  factory LearningPathMilestone.fromJson(Map<String, dynamic> json) {
    return LearningPathMilestone(
      id: json['\$id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      completionPercentage: json['completionPercentage'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      icon: json['icon'] ?? '',
      concepts: (json['concepts'] as List<dynamic>?)
              ?.map((e) => Concept.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'concepts': concepts.map((c) => c.toJson()).toList(),
      'order': order,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'completionPercentage': completionPercentage,
      'icon': icon,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class LearningPath {
  final String userId;
  final String topic;
  final List<LearningPathMilestone> milestones;
  final List<Concept> concepts;
  final List<Mission> missions;
  final int totalConceptsCompleted;
  final int totalConcepts;
  final int overallProgressPercentage;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String currentLevel;

  LearningPath({
    required this.userId,
    required this.topic,
    required this.milestones,
    this.concepts = const [],
    this.missions = const [],
    required this.totalConceptsCompleted,
    required this.totalConcepts,
    required this.overallProgressPercentage,
    required this.startedAt,
    this.completedAt,
    required this.currentLevel,
  });

  int get remainingConcepts => totalConcepts - totalConceptsCompleted;
  int get completedPercentage =>
      totalConcepts > 0 ? (totalConceptsCompleted * 100 ~/ totalConcepts) : 0;
  int get completedMilestones => milestones.where((m) => m.isCompleted).length;
  int get unlockedMilestones => milestones.where((m) => m.isUnlocked).length;

  factory LearningPath.fromJson(Map<String, dynamic> json,
      List<LearningPathMilestone> m, List<Concept> c) {
    return LearningPath(
      userId: json[r'$id'] ?? '',
      topic: json['topic'] ?? '',
      totalConceptsCompleted: json['totalConceptsCompleted'] ?? 0,
      totalConcepts: json['totalConcepts'] ?? 0,
      overallProgressPercentage: json['overallProgressPercentage'] ?? 0,
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      currentLevel: json['currentLevel'] ?? '',
      // Safely map the nested list of milestones
      milestones: m,
      concepts: c,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '\$id': userId,
      'topic': topic,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'totalConceptsCompleted': totalConceptsCompleted,
      'totalConcepts': totalConcepts,
      'overallProgressPercentage': overallProgressPercentage,
      'startedAt': startedAt!.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentLevel': currentLevel,
    };
  }
}
