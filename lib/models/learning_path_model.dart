import 'dart:convert';

import 'package:appwrite/models.dart';
import 'package:pfe_test/models/mission_model.dart';

class Concept {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "Variables", "Functions", "OOP"
  final int difficulty; // 1-5
  final int estimatedHours;
  final List<String>
      prerequisites; // IDs of concepts that must be completed first
  final List<String> relatedMissions; // Mission IDs related to this concept
  final String icon; // Emoji or icon name
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
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as int,
      estimatedHours: json['estimatedHours'] as int,
      prerequisites: List<String>.from(json['prerequisites'] as List? ?? []),
      relatedMissions:
          List<String>.from(json['relatedMissions'] as List? ?? []),
      icon: json['icon'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
  final List<String> conceptIds; // Concepts in this milestone
  final int order; // Order in the learning path
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
    required this.conceptIds,
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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      conceptIds: List<String>.from(json['conceptIds'] as List? ?? []),
      order: json['order'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completionPercentage: json['completionPercentage'] as int? ?? 0,
      icon: json['icon'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'conceptIds': conceptIds,
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
  final DateTime startedAt;
  final DateTime? completedAt;
  final String currentLevel; // Beginner, Intermediate, Advanced

  LearningPath({
    required this.userId,
    required this.topic,
    required this.milestones,
    required this.concepts,
    required this.missions,
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

  factory LearningPath.fromJson(Row row) {
    print(row.$id);
    final rawMilestones = row.data['milestones'];
    final rawConcepts = row.data['concepts'];
    final rawMissions = row.data['missions'];
    print("Aloo");

    // 2. Check if it's a stringified JSON array and decode it, otherwise treat as List
    final List<dynamic>? milestonesList = rawMilestones is String
        ? jsonDecode(rawMilestones) as List<dynamic>?
        : rawMilestones as List<dynamic>?;

    final List<dynamic>? conceptsList = rawConcepts is String
        ? jsonDecode(rawConcepts) as List<dynamic>?
        : rawConcepts as List<dynamic>?;

    final List<dynamic>? missionsList = rawMissions is String
        ? jsonDecode(rawMissions) as List<dynamic>?
        : rawMissions as List<dynamic>?;
    return LearningPath(
      userId: row.$id,
      topic: row.data['topic'] as String,
      milestones: milestonesList
              ?.map((m) =>
                  LearningPathMilestone.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      concepts: conceptsList
              ?.map((c) => Concept.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      missions: missionsList?.map((doc) {
        
            final MissionType type = MissionType.values
                .firstWhere((e) => e.name.contains(doc["type"]));
            switch (type) {
              case MissionType.complete:
                return Mission.jsonCompleteMission( doc);

              case MissionType.debug:
                return Mission.jsonDebugMission(doc);

              case MissionType.multipleChoice:
                return Mission.jsonMultipleChoice(doc);

              case MissionType.ordering:
                return Mission.jsonOrdering(doc);

              case MissionType.singleChoice:
                return Mission.jsonSingleChoice(doc);

              case MissionType.test:
                return Mission.jsonTestMission(doc);
            }
          }).toList() ??
          [],
      totalConceptsCompleted: row.data['totalConceptsCompleted'] as int? ?? 0,
      totalConcepts: row.data['totalConcepts'] as int? ?? 0,
      overallProgressPercentage:
          row.data['overallProgressPercentage'] as int? ?? 0,
      startedAt: DateTime.parse(row.data['startedAt'] as String),
      completedAt: row.data['completedAt'] != null
          ? DateTime.parse(row.data['completedAt'] as String)
          : null,
      currentLevel: row.data['currentLevel'] as String? ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'topic': topic,
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'concepts': concepts.map((c) => c.toJson()).toList(),
      'totalConceptsCompleted': totalConceptsCompleted,
      'totalConcepts': totalConcepts,
      'overallProgressPercentage': overallProgressPercentage,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'currentLevel': currentLevel,
    };
  }
}

// Sample data for demonstration
