class UserInfo {
  String username;
  String progLanguage;
  int experience;
  int totalPoints;
  int rank;
  int nbMissions;
  List<String> earnedBadges;
  String imagePath;
  String bio;
  String email;

  UserInfo({
    required this.username,
    required this.progLanguage,
    this.experience = 0,
    this.totalPoints = 0,
    this.earnedBadges = const [],
    this.imagePath = "",
    this.bio = "",
    this.email = "",
    this.nbMissions = 0,
    this.rank = 0,
  });

  double get progressToNextLevel => (experience % 1000) / 1000;

  int get userLevel {
    int lvl = (experience / 1000).toInt();
    if (lvl == 0) {
      return 1;
    } else {
      return lvl;
    }
  }

  
}
//TODO : Add Bio , ImagePath att
