import 'dart:math';

class UserInfo {
  String username;
  String progLanguage;
  int experience;
  int totalPoints;
  int rank;
  int nbMissions;
  List<String> earnedBadges;
  String imageId;
  String bio;
  String email;

  UserInfo({
    required this.username,
    required this.progLanguage,
    this.experience = 0,
    this.totalPoints = 0,
    this.earnedBadges = const [],
    this.imageId = "",
    this.bio = "",
    this.email = "",
    this.nbMissions = 0,
    this.rank = 0,
  });

  double get progressToNextLevel {
    const baseXP = 500;
    int level = userLevel;

    int currentLevelXP = baseXP * level * level;
    int nextLevelXP = baseXP * (level + 1) * (level + 1);

    return (experience - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }

  int get userLevel {
    return max(1, sqrt(experience / 500).floor());
  }
}

