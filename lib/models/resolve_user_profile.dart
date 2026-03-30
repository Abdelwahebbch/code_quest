class ResolvedProfile {
  final String userId;
  final String language;
  final String currentLevel; // "Beginner" | "Intermediate" | "Advanced"
  final int milestoneCount; // 3 | 4 | 5
  final int conceptsPerMilestone; // 3 | 4 | 5 | 6
  final String focusArea; // maps to objective
  final String commitment; // "casual" | "consistent" | "intensive"

  String get languagePrefix =>
      language.toLowerCase().replaceAll(' ', '_').substring(0, 2);
  // e.g. "Python" → "py", "JavaScript" → "ja"

  const ResolvedProfile({
    required this.userId,
    required this.language,
    required this.currentLevel,
    required this.milestoneCount,
    required this.conceptsPerMilestone,
    required this.focusArea,
    required this.commitment,
  });

  @override
  String toString() {
    return 'ResolvedProfile(\n'
        '  userId: $userId,\n'
        '  language: $language ,\n'
        '  currentLevel: $currentLevel,\n'
        '  milestoneCount: $milestoneCount,\n'
        '  conceptsPerMilestone: $conceptsPerMilestone,\n'
        '  focusArea: $focusArea,\n'
        '  commitment: $commitment\n'
        ')';
  }
}

class ProfileResolver {
  /// Takes the raw answers map from your onboarding flow and returns a
  /// fully resolved profile. All logic is deterministic — no API call needed.
  static ResolvedProfile resolve({
    required String userId,
    required Map<String, String?> answers,
  }) {
    final journey = answers['journey'];
    final section = answers['section'];
    final milestone = answers['student_milestone'];
    final commitment = answers['commitment'] ?? 'casual';

    final objective = answers['student_objective'];
    final learning_goal = answers['learning_goal'];
    final explorer_objective = answers['explorer_objective'] ?? 'casual';

    // final exam_range = answers['exam_range'] ?? 'casual';

    final language = _resolveLanguage(journey, section, objective);
    final level = _resolveLevel(journey, milestone, objective);
    final scope = _resolveScope(commitment);

    final focusArea = _resolveFocusArea(objective);

    return ResolvedProfile(
      userId: userId,
      language: language,
      currentLevel: level,
      milestoneCount: scope['milestones']!,
      conceptsPerMilestone: scope['concepts']!,
      focusArea: focusArea,
      commitment: commitment,
    );
  }

  // ─── Language ──────────────────────────────────────────────────────────────

  static String _resolveLanguage(
    String? journey,
    String? section,
    String? objective,
  ) {
    if (journey == 'hs_student') {
      return section == 'lettre_student' ? 'Scratch' : 'Python';
    }
    if (journey == 'uni_student') return 'Python';
    if (journey == 'explorer') {
      if (objective == 'build_apps') return 'JavaScript';
      return 'Python';
    }
    if (objective == 'new_stack') return 'JavaScript';
    if (objective == 'interviews') return 'Python';
    return 'Python'; // safe default
  }

  // ─── Level ─────────────────────────────────────────────────────────────────

  static String _resolveLevel(
    String? journey,
    String? studentMilestone,
    String? objective,
  ) {
    if (objective == 'interviews' || objective == 'deepen_knowledge') {
      return 'Advanced';
    }
    if (journey == 'uni_student') {
      if (studentMilestone == 'graduate' || objective == 'getting_ahead') {
        return 'Intermediate';
      }
      return 'Beginner';
    }
    if (journey == 'explorer' && objective == 'start_career') {
      return 'Intermediate';
    }
    return 'Beginner';
  }

  // ─── Scope (milestone count + concepts per milestone) ──────────────────────

  static Map<String, int> _resolveScope(String commitment) {
    switch (commitment) {
      case '🔥 3+ hours':
        return {'milestones': 5, 'concepts': 5};
      case '⚡ 1-2 hours':
        return {'milestones': 4, 'concepts': 4};
      case '☕ 15-30 min':
      default:
        return {'milestones': 3, 'concepts': 3};
    }
  }

  // ─── Focus Area ────────────────────────────────────────────────────────────

  static String _resolveFocusArea(String? objective) {
    const map = {
      'exam_prep': 'Prepare for exams',
      'basics': 'Learn the basics',
      'getting_ahead': 'Learn outside of class',
      'master_lang': 'Master a programming language',
    };
    return map[objective] ?? 'basics';
  }
}
