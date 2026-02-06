class UserProgress {
  final String username;
  final String progLanguage;
  int level;
  int experience;
  int totalPoints;
  List<String> earnedBadges;

  UserProgress({
    required this.username,
    required this.progLanguage,
    this.level = 1,
    this.experience = 0,
    this.totalPoints = 0,
    this.earnedBadges = const [],
  });

  double get progressToNextLevel => (experience % 1000) / 1000;
}
//TODO : Add Bio , ImagePath att 