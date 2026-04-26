import 'dart:convert';

import 'package:pfe_test/models/mission_model.dart';




class PartyMember {
  String userId;
  String username;
  String imageId;
  int score; 
  int correctAnswers;
  int totalAnswers;
  bool isReady;
  DateTime joinedAt;
  bool isSubmit;

  PartyMember(
      {required this.userId,
      required this.username,
      required this.imageId,
      this.score = 0,
      this.correctAnswers = 0,
      this.totalAnswers = 0,
      this.isReady = false,
      required this.joinedAt,
      this.isSubmit = false});

  double get accuracy {
    if (totalAnswers == 0) return 0;
    return (correctAnswers / totalAnswers) * 100;
  }

  factory PartyMember.fromJson(Map<String, dynamic> json) {
    return PartyMember(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      imageId: json['imageId'] ?? '',
      score: json['score'] ?? 0,
      correctAnswers: json['correctAnswers'] ?? 0,
      totalAnswers: json['totalAnswers'] ?? 0,
      isReady: json['isReady'] ?? false,
      joinedAt:
          DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() {
    return jsonEncode({
      'userId': userId,
      'username': username,
      'imageId': imageId,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'isReady': isReady,
      'joinedAt': joinedAt.toString(),
    });
  }
}

class Party {
  String partyId;
  String partyCode;
  String partyName;
  String hostId;
  String hostName;
  List<PartyMember> members;
  List<Mission> missions;
  int maxMembers;
  int currentMissionIndex;
  bool isActive;
  bool isStarted;
  bool isPublic;
  DateTime? startedAt;
  DateTime? endedAt;
  String difficulty; // beginner, intermediate, advanced
  String gameMode; // quiz, missions, mixed
  int totalRounds;
  int nbMembers;

  Party(
      {required this.partyId,
      required this.partyCode,
      required this.partyName,
      required this.hostId,
      required this.hostName,
      this.members = const [],
      this.missions = const [],
      this.maxMembers = 8,
      this.currentMissionIndex = 0,
      this.isActive = true,
      this.isStarted = false,
      this.startedAt,
      this.endedAt,
      this.difficulty = 'intermediate',
      this.gameMode = 'quiz',
      this.totalRounds = 5,
      this.isPublic = false,
      this.nbMembers = 1});

  bool get isFull => (members.length >= maxMembers || nbMembers >= maxMembers);

  bool get canStart => members.length >= 2 && members.every((m) => m.isReady);

  int get memberCount => members.length;

  PartyMember? getHostMember() {
    try {
      return members.firstWhere((m) => m.userId == hostId);
    } catch (e) {
      return null;
    }
  }

  factory Party.fromJson(Map<String, dynamic> json) {
    return Party(
        partyId: "1",
        partyCode: "AB123AS",
        partyName: "partyName",
        hostId: "hostId",
        hostName: "hostName");
  }

  Map<String, dynamic> toJson() {
    return {
      'partyId': "partyId",
      'partyName': "partyName",
      'hostId': "hostId",
      'hostName': "hostName",
      'members': ["1", "2"],
      'missions': ["1", "2"],
      'maxMembers': 10,
      'currentMissionIndex': 1,
      'isActive': true,
      'isStarted': true,
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'difficulty': difficulty,
      'gameMode': gameMode,
      'totalRounds': totalRounds,
    };
  }
}

class PartyResult {
  String partyId;
  String partyName;
  List<PartyMember> finalRanking;
  DateTime completedAt;
  int totalDuration; // in seconds
  String winnerName;
  int winnerScore;

  PartyResult({
    required this.partyId,
    required this.partyName,
    required this.finalRanking,
    required this.completedAt,
    required this.totalDuration,
    required this.winnerName,
    required this.winnerScore,
  });

  factory PartyResult.fromJson(Map<String, dynamic> json) {
    return PartyResult(
      partyId: json['partyId'] ?? '',
      partyName: json['partyName'] ?? '',
      finalRanking: (json['finalRanking'] as List?)
              ?.map((m) => PartyMember.fromJson(m))
              .toList() ??
          [],
      completedAt: DateTime.parse(
          json['completedAt'] ?? DateTime.now().toIso8601String()),
      totalDuration: json['totalDuration'] ?? 0,
      winnerName: json['winnerName'] ?? '',
      winnerScore: json['winnerScore'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partyId': partyId,
      'partyName': partyName,
      'finalRanking': finalRanking.map((m) => m.toJson()).toList(),
      'completedAt': completedAt.toIso8601String(),
      'totalDuration': totalDuration,
      'winnerName': winnerName,
      'winnerScore': winnerScore,
    };
  }
}
