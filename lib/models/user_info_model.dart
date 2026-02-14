import 'dart:math';

import 'package:pfe_test/models/mission_model.dart';

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
  List<Mission> missions;
  Map<String,dynamic> badgesProgress;
  List<String> showingBadges;

  UserInfo({
    required this.username,
    required this.progLanguage,
    this.experience = 0,
    this.totalPoints = 0,
    this.earnedBadges =  const [],
    this.imageId = "",
    this.bio = "",
    this.email = "",
    this.nbMissions = 0,
    this.rank = 0,
    this.missions= const [],
    this.badgesProgress=const {"debug":0 ,"complete":0 ,"test":0 ,"singleChoice":0 ,"multipleChoice":0 ,"ordering":0 },
    this.showingBadges=const[],
  });
  //Alert : we must discust about it quickly
  double get progressToNextLevel {
    const baseXP = 500;
    int level = userLevel;//1

    int currentLevelXP = baseXP * level * level;//500
    int nextLevelXP = baseXP * (level + 1) * (level + 1);//2000
    //print((experience - currentLevelXP) / (nextLevelXP - currentLevelXP));
    return (experience - currentLevelXP) / (nextLevelXP - currentLevelXP);
  }

  int get userLevel {
    return max(1, sqrt(experience / 500).floor());
  }
}

