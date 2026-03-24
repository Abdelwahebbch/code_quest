class Concept {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., "Variables", "Functions", "OOP"
  final int difficulty; // 1-5
  final int estimatedHours;
  final List<String> prerequisites; // IDs of concepts that must be completed first
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
      relatedMissions: List<String>.from(json['relatedMissions'] as List? ?? []),
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
  final String language; // e.g., "Python", "JavaScript"
  final List<LearningPathMilestone> milestones;
  final List<Concept> concepts;
  final int totalConceptsCompleted;
  final int totalConcepts;
  final int overallProgressPercentage;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String currentLevel; // Beginner, Intermediate, Advanced

  LearningPath({
    required this.userId,
    required this.language,
    required this.milestones,
    required this.concepts,
    required this.totalConceptsCompleted,
    required this.totalConcepts,
    required this.overallProgressPercentage,
    required this.startedAt,
    this.completedAt,
    required this.currentLevel,
  });

  // Calculate statistics
  int get remainingConcepts => totalConcepts - totalConceptsCompleted;
  int get completedPercentage =>
      totalConcepts > 0 ? (totalConceptsCompleted * 100 ~/ totalConcepts) : 0;
  int get completedMilestones =>
      milestones.where((m) => m.isCompleted).length;
  int get unlockedMilestones =>
      milestones.where((m) => m.isUnlocked).length;

  factory LearningPath.fromJson(Map<String, dynamic> json) {
    return LearningPath(
      userId: json['userId'] as String,
      language: json['language'] as String,
      milestones: (json['milestones'] as List?)
              ?.map((m) => LearningPathMilestone.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      concepts: (json['concepts'] as List?)
              ?.map((c) => Concept.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      totalConceptsCompleted: json['totalConceptsCompleted'] as int? ?? 0,
      totalConcepts: json['totalConcepts'] as int? ?? 0,
      overallProgressPercentage:
          json['overallProgressPercentage'] as int? ?? 0,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      currentLevel: json['currentLevel'] as String? ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'language': language,
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
class LearningPathSampleData {
  static LearningPath getSamplePythonPath() {
    final concepts = [
      Concept(
        id: 'var-001',
        name: 'Variables & Data Types',
        description: 'Learn about variables, strings, numbers, and basic data types',
        category: 'Fundamentals',
        difficulty: 1,
        estimatedHours: 2,
        prerequisites: [],
        relatedMissions: ['mission-001', 'mission-002'],
        icon: '📦',
        isCompleted: true,
        completionPercentage: 100,
        startedAt: DateTime.now().subtract(const Duration(days: 30)),
        completedAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Concept(
        id: 'cond-001',
        name: 'Conditionals & Logic',
        description: 'Master if/else statements and boolean logic',
        category: 'Control Flow',
        difficulty: 1,
        estimatedHours: 3,
        prerequisites: ['var-001'],
        relatedMissions: ['mission-003', 'mission-004'],
        icon: '🔀',
        isCompleted: true,
        completionPercentage: 100,
        startedAt: DateTime.now().subtract(const Duration(days: 24)),
        completedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Concept(
        id: 'loop-001',
        name: 'Loops & Iteration',
        description: 'Understand for loops, while loops, and iteration patterns',
        category: 'Control Flow',
        difficulty: 2,
        estimatedHours: 4,
        prerequisites: ['cond-001'],
        relatedMissions: ['mission-005', 'mission-006'],
        icon: '🔁',
        isCompleted: true,
        completionPercentage: 100,
        startedAt: DateTime.now().subtract(const Duration(days: 19)),
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Concept(
        id: 'func-001',
        name: 'Functions & Scope',
        description: 'Create reusable functions and understand variable scope',
        category: 'Functions',
        difficulty: 2,
        estimatedHours: 5,
        prerequisites: ['loop-001'],
        relatedMissions: ['mission-007', 'mission-008'],
        icon: '⚙️',
        isCompleted: true,
        completionPercentage: 100,
        startedAt: DateTime.now().subtract(const Duration(days: 14)),
        completedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Concept(
        id: 'list-001',
        name: 'Lists & Collections',
        description: 'Work with lists, tuples, and other collection types',
        category: 'Data Structures',
        difficulty: 2,
        estimatedHours: 4,
        prerequisites: ['func-001'],
        relatedMissions: ['mission-009', 'mission-010'],
        icon: '📋',
        isCompleted: true,
        completionPercentage: 100,
        startedAt: DateTime.now().subtract(const Duration(days: 9)),
        completedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Concept(
        id: 'dict-001',
        name: 'Dictionaries & Maps',
        description: 'Master key-value data structures',
        category: 'Data Structures',
        difficulty: 2,
        estimatedHours: 3,
        prerequisites: ['list-001'],
        relatedMissions: ['mission-011', 'mission-012'],
        icon: '🗺️',
        isCompleted: false,
        completionPercentage: 60,
        startedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Concept(
        id: 'oop-001',
        name: 'Object-Oriented Programming',
        description: 'Learn classes, objects, inheritance, and polymorphism',
        category: 'OOP',
        difficulty: 3,
        estimatedHours: 8,
        prerequisites: ['dict-001', 'func-001'],
        relatedMissions: ['mission-013', 'mission-014'],
        icon: '🏗️',
        isCompleted: false,
        completionPercentage: 0,
      ),
      Concept(
        id: 'err-001',
        name: 'Error Handling',
        description: 'Handle exceptions and write robust error-handling code',
        category: 'Advanced',
        difficulty: 3,
        estimatedHours: 3,
        prerequisites: ['oop-001'],
        relatedMissions: ['mission-015', 'mission-016'],
        icon: '⚠️',
        isCompleted: false,
        completionPercentage: 0,
      ),
      Concept(
        id: 'file-001',
        name: 'File I/O & Modules',
        description: 'Read/write files and organize code with modules',
        category: 'Advanced',
        difficulty: 3,
        estimatedHours: 4,
        prerequisites: ['err-001'],
        relatedMissions: ['mission-017', 'mission-018'],
        icon: '📁',
        isCompleted: false,
        completionPercentage: 0,
      ),
    ];

    final milestones = [
      LearningPathMilestone(
        id: 'milestone-001',
        title: 'Python Basics',
        description: 'Master the fundamentals of Python programming',
        conceptIds: ['var-001', 'cond-001', 'loop-001'],
        order: 1,
        isUnlocked: true,
        isCompleted: true,
        completionPercentage: 100,
        icon: '🎯',
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      LearningPathMilestone(
        id: 'milestone-002',
        title: 'Functions & Data Structures',
        description: 'Learn to write functions and work with collections',
        conceptIds: ['func-001', 'list-001', 'dict-001'],
        order: 2,
        isUnlocked: true,
        isCompleted: false,
        completionPercentage: 70,
        icon: '🔧',
        unlockedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      LearningPathMilestone(
        id: 'milestone-003',
        title: 'Object-Oriented Programming',
        description: 'Master OOP concepts and design patterns',
        conceptIds: ['oop-001', 'err-001'],
        order: 3,
        isUnlocked: false,
        isCompleted: false,
        completionPercentage: 0,
        icon: '🏛️',
      ),
      LearningPathMilestone(
        id: 'milestone-004',
        title: 'Advanced Topics',
        description: 'Explore file handling, modules, and more',
        conceptIds: ['file-001'],
        order: 4,
        isUnlocked: false,
        isCompleted: false,
        completionPercentage: 0,
        icon: '🚀',
      ),
    ];

    return LearningPath(
      userId: 'user-123',
      language: 'Python',
      milestones: milestones,
      concepts: concepts,
      totalConceptsCompleted: 5,
      totalConcepts: 9,
      overallProgressPercentage: 56,
      startedAt: DateTime.now().subtract(const Duration(days: 30)),
      currentLevel: 'Intermediate',
    );
  }
}
