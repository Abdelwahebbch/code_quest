import 'dart:convert';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart' hide Row;
import 'package:appwrite/models.dart';
import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/models/user_model.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_repository.dart';

class DataProvider with ChangeNotifier {
  final DataRepository dataRepository;
  final AuthProvider authProvider;
  bool _isLoading = false;

  late UserInfo progress;
  late bool isFirstLogin;
  late Map<String, dynamic> userGoals;
  bool get isLoading => _isLoading;

  DataProvider({required this.dataRepository, required this.authProvider});
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
        await getUserInfo();
    } catch (e) {
      print('Error initializing DataProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateIsFirstLogin() {
    if (isFirstLogin) {
      dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'isFirstLogin': false},
      );
      isFirstLogin = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding(Map<String, String> data, bool pathCreation,
      DateTime? startDate, DateTime? endDate) async {
    try {
      userGoals = data;
      print(progress.progLanguage);
      print(data["journey"].toString());
      updateIsFirstLogin();
      if (startDate != null && endDate != null) {
        await dataRepository.createRow(
            tableId: "user_goals",
            rowId: authProvider.currentUser!.id,
            data: {
              "username": authProvider.currentUser!.name,
              "prompt": jsonEncode(data),
              "startDate": startDate.toString(),
              "endDate": endDate.toString()
            });
      } else {
        await dataRepository.createRow(
            tableId: "user_goals",
            rowId: authProvider.currentUser!.id,
            data: {
              "username": authProvider.currentUser!.name,
              "prompt": jsonEncode(data)
            });
      }

      var rows =
          await dataRepository.getRows(tableId: "mock_mission", queries: [
        Query.equal("user_category", data["journey"].toString()),
        Query.equal("language", progress.progLanguage),
      ]);

      for (var row in rows.rows) {
        await dataRepository
            .createRow(tableId: "missions", rowId: ID.unique(), data: {
          "user_id": authProvider.currentUser!.id,
          "title": row.data["title"],
          "type": row.data["type"],
          "difficulty": row.data["difficulty"],
          "initialCode": row.data["initialCode"],
          "solution": row.data["solution"],
          "options": List<String>.from(row.data["options"]),
          "correctOrder": List<String>.from(row.data["correctOrder"]),
          "points": row.data["points"],
          "isCompleted": false,
          "description": row.data["description"],
          "nbFailed": 0,
          "aiPointsUsed": 0,
          "conversation": [],
          "rate": 0,
        });
      }

      /*ResolvedProfile profile =
          ProfileResolver.resolve(userId: user!.$id, answers: data);
      if (pathCreation) {
        await AppwritecloudfunctionsService.createLearningPath(
            profile, user!.$id);
      }*/
    } catch (e) {
      print("Error fi complete onboarding $e ");
      rethrow;
    }
  }

  Future<void> getUserInfo() async {
    try {
    
      final row = await dataRepository.getRow(
          tableId: "user_profiles", rowId: "69a8ed72d561f7ab03fd");
      int x = await getRank();
      isFirstLogin = row.data["isFirstLogin"] ?? true;

      progress = UserInfo(
        progLanguage: row.data["progLanguage"] ?? "not selected",
        username: "authProvider.currentUser!.name",
        experience: row.data["experience"],
        totalPoints: row.data["totalPoints"],
        earnedBadges: List<String>.from(row.data["earnedBadges"] ?? []),
        bio: row.data["bio"],
        imageId: row.data["imageId"],
        email: "authProvider.currentUser!.email",
        rank: x,
        difficultySelected: row.data["difficulty"] ?? "Intermediate",
        nbMissions: row.data["nbMission"] ?? 0,
        missions: await getMissions(),
        badgesProgress: jsonDecode(row.data["badgesProgress"]),
        showingBadges: [],
        nbMissionCompletedWithoutHints:
            row.data["nbMissionCompletedWithoutHints"] ?? 0,
        totalFailures: row.data["totalFailures"] ?? 0,
        totalAIQuestions: row.data["totalAIQuestions"] ?? 0,
      );
      if (!isFirstLogin) {
        await getuserGoals();
      }

      try {
        // path = await getLearningPath();
        //print(path.milestones.first.concepts.length);
      } on AppwriteException catch (e) {
        if (e.code == 404) {
          print("Not Found mouch mochkol");
        } else {
          rethrow;
        }
      }
 
    } catch (e) {
      debugPrint("Error fi getUserInfo $e");
      rethrow;
    }
  }

  Future<void> getuserGoals() async {
    final row = await dataRepository.getRow(
        tableId: "user_goals", rowId: authProvider.currentUser!.id);

    progress.rate = row.data["rate"] / 1;

    userGoals = jsonDecode(row.data["prompt"]);
  }

  Future<List<Mission>> getMissions() async {
    try {
      late RowList response;
      String date = DateTime.now().toUtc().toIso8601String().split('T').first;
      print(date);

      response = await dataRepository.getRows(tableId: "missions", queries: [
        Query.equal("user_id", authProvider.currentUser!.id),
        Query.createdAfter("${date}T00:00:00Z"),
        Query.createdBefore("${date}T23:59:59Z"),
        Query.orderDesc("\$createdAt"),
      ]);

      if (response.rows.isEmpty) {
        date = DateTime.now()
            .toUtc()
            .subtract(const Duration(days: 1))
            .toIso8601String()
            .split('T')
            .first;

        response = await dataRepository.getRows(tableId: "missions", queries: [
          Query.equal("user_id", authProvider.currentUser!.id),
          Query.createdAfter("${date}T00:00:00Z"),
          Query.createdBefore("${date}T23:59:59Z"),
          Query.orderDesc("\$createdAt"),
        ]);
      }

      return response.rows.map((doc) {
        final MissionType type = MissionType.values
            .firstWhere((e) => e.name.contains(doc.data["type"]));
        switch (type) {
          case MissionType.complete:
            return Mission.completeMission(doc);

          case MissionType.debug:
            return Mission.debugMission(doc);

          case MissionType.multipleChoice:
            return Mission.multipleChoice(doc);

          case MissionType.ordering:
            return Mission.ordering(doc);

          case MissionType.singleChoice:
            return Mission.singleChoice(doc);

          case MissionType.test:
            return Mission.testMission(doc);
        }
      }).toList();
    } catch (e) {
      debugPrint("Error fetching missions: $e");
      rethrow;
    }
  }

  Future<Mission> loadMissions(String id) async {
    var mission = await dataRepository.getRow(tableId: "missions", rowId: id);

    final MissionType type = MissionType.values
        .firstWhere((e) => e.name.contains(mission.data["type"]));

    switch (type) {
      case MissionType.complete:
        return Mission.completeMission(mission);

      case MissionType.debug:
        return Mission.debugMission(mission);

      case MissionType.multipleChoice:
        return Mission.multipleChoice(mission);

      case MissionType.ordering:
        return Mission.ordering(mission);

      case MissionType.singleChoice:
        return Mission.singleChoice(mission);

      case MissionType.test:
        return Mission.testMission(mission);
    }
  }

  Future<void> updateMissionAiPoints(String id) async {
    try {
      int previousAiPointsUsed = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          previousAiPointsUsed = progress.missions[i].aiPointsUsed;
          progress.missions[i].aiPointsUsed = previousAiPointsUsed + 1;
        }
      }
      int currentAiPointsUsed = previousAiPointsUsed + 1;
      int previousTotalAIQuestions = progress.totalAIQuestions;
      int currentToalAIQuestions = previousTotalAIQuestions + 1;
      progress.totalAIQuestions = currentToalAIQuestions;
      await dataRepository.updateRow(
        tableId: "missions",
        rowId: id,
        data: {'aiPointsUsed': currentAiPointsUsed},
      );
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'totalAIQuestions': currentToalAIQuestions},
      );
      await updateUserPoints(-1);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserPoints(int nb) async {
    try {
      int previousTotalPoints = progress.totalPoints;
      int currentTotalPoints = previousTotalPoints + nb;
      progress.totalPoints = currentTotalPoints;
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'totalPoints': currentTotalPoints},
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToConversation(
      String role, int index, String id, String msg) async {
    try {
      progress.missions[index].conversation
          .add(jsonEncode({'role': role, 'message': msg}));

      await dataRepository.updateRow(
        tableId: "missions",
        rowId: id,
        data: {'conversation': progress.missions[index].conversation},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateXp(int xp) async {
    try {
      int newExperience = progress.experience + xp;
      progress.experience = newExperience;
      notifyListeners();
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'experience': newExperience},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMissionStatus(String id, double rate) async {
    try {
      await dataRepository.updateRow(
        tableId: "missions",
        rowId: id,
        data: {'isCompleted': true, "rate": rate},
      );
      progress.nbMissions += 1;
      await dataRepository.updateRow(
          tableId: "user_profiles",
          rowId: authProvider.currentUser!.id,
          data: {'nbMission': progress.nbMissions});
      int? missionNb;
      int missionDiffculty = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isCompleted = true;
          missionDiffculty = progress.missions[i].difficulty;
          missionNb = i;
        }
      }
      await updateRate(missionDiffculty, rate);
      await checkbadges(missionNb!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRate(int missionDiffculty, double rate) async {
    try {
      //Elo Algorthime
      //s= normalized mission rate
      double S = rate / 10;
      //E = Expected probability
      //2 = is scale you can change
      double E = 1 / (1 + pow(10, ((missionDiffculty - progress.rate) / 2)));
      // Update
      double newRate = progress.rate + (S - E);
      progress.rate = double.parse(newRate.clamp(1, 10).toStringAsFixed(2));
      notifyListeners();
      await dataRepository.updateRow(
          tableId: "user_goals",
          rowId: authProvider.currentUser!.id,
          data: {'rate': progress.rate});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkbadges(int missionNb) async {
    try {
      String missionType = progress.missions[missionNb].type.name;
      progress.badgesProgress[missionType] =
          (progress.badgesProgress[missionType]! + 1);
      int missionsCompletedToday = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].isCompleted) {
          missionsCompletedToday += 1;
        }
      }

      if (progress.badgesProgress['debug']! >= 10) {
        if (!progress.earnedBadges.contains('Bug Hunter')) {
          progress.earnedBadges.add('Bug Hunter');
          progress.showingBadges.add('Bug Hunter');
          await updateUserPoints(10);
        }
      }
      if (progress.nbMissionCompletedWithoutHints >= 5) {
        if (!progress.earnedBadges.contains('Code Ninja')) {
          progress.earnedBadges.add('Code Ninja');
          progress.showingBadges.add('Code Ninja');
          await updateUserPoints(10);
        }
      }
      if (progress.badgesProgress['test']! >= 5) {
        if (!progress.earnedBadges.contains('Test Master')) {
          progress.earnedBadges.add('Test Master');
          progress.showingBadges.add('Test Master');
          await updateUserPoints(10);
        }
      }
      if (missionsCompletedToday >= 3) {
        if (!progress.earnedBadges.contains('Fast Learner')) {
          progress.earnedBadges.add('Fast Learner');
          progress.showingBadges.add('Fast Learner');
          await updateUserPoints(10);
        }
      }
      if (progress.badgesProgress['ordering'] >= 10) {
        if (!progress.earnedBadges.contains('Architect')) {
          progress.earnedBadges.add('Architect');
          progress.showingBadges.add('Architect');
          await updateUserPoints(10);
        }
      }
      if (progress.badgesProgress['complete'] >= 10 &&
          progress.totalFailures <= 30) {
        if (!progress.earnedBadges.contains('Clean Coder')) {
          progress.earnedBadges.add('Clean Coder');
          progress.showingBadges.add('Clean Coder');
          await updateUserPoints(10);
        }
      }
      if (progress.badgesProgress['singleChoice'] >= 10 &&
          progress.badgesProgress['multipleChoice'] >= 10) {
        if (!progress.earnedBadges.contains('Team Player')) {
          progress.earnedBadges.add('Team Player');
          progress.showingBadges.add('Team Player');
          await updateUserPoints(10);
        }
      }
      if (progress.totalAIQuestions >= 50) {
        if (!progress.earnedBadges.contains('AI Whisperer')) {
          progress.earnedBadges.add('AI Whisperer');
          progress.showingBadges.add('AI Whisperer');
          await updateUserPoints(10);
        }
      }
      notifyListeners();
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {
          'badgesProgress': jsonEncode(progress.badgesProgress),
          'earnedBadges': progress.earnedBadges
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFailedNb(String id) async {
    try {
      progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed += 1;

      await dataRepository.updateRow(
        tableId: "missions",
        rowId: id,
        data: {
          'nbFailed':
              progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed
        },
      );
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {
          'totalFailures':
              progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserGoals(Map<String, String> data) async {
    await dataRepository.updateRow(
        tableId: "user_goals",
        rowId: authProvider.currentUser!.id,
        data: {"prompt": jsonEncode(data)});
    userGoals = data;
    notifyListeners();
  }

  Future<void> fixEducationTime(DateTime? startDate, DateTime? endDate) async {
    await dataRepository.updateRow(
        tableId: "user_goals",
        rowId: authProvider.currentUser!.id,
        data: {
          "startDate": startDate?.toString(),
          "endDate": endDate?.toString()
        });
  }

  Future<void> updateProfile(
      String imagePath, String userName, String bio) async {
    try {
      if (imagePath.isNotEmpty) {
        final file = await dataRepository.appwriteService.storage.createFile(
          bucketId: '69891b1d0012c9a7e862',
          fileId: ID.unique(),
          file: InputFile.fromPath(
              path: imagePath, filename: imagePath.split('/').last),
        );
        await dataRepository.updateRow(
          tableId: "user_profiles",
          rowId: authProvider.currentUser!.id,
          data: {'imageId': file.$id, 'bio': bio},
        );
        progress.bio = bio;
        progress.imageId = file.$id;
        progress.username = userName;
        notifyListeners();
      } else {
        await dataRepository.updateRow(
          tableId: "user_profiles",
          rowId: authProvider.currentUser!.id,
          data: {'bio': bio},
        );
        progress.bio = bio;
        progress.username = userName;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLanguageSelected(String languageSelected) async {
    try {
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'progLanguage': languageSelected},
      );
      progress.progLanguage = languageSelected;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getRank() async {
    try {
      final r =
          await dataRepository.getRows(tableId: "user_profiles", queries: [
        Query.orderDesc("experience"),
      ]);

      return r.rows.indexWhere(
            (row) => row.$id == authProvider.currentUser!.id,
          ) +
          1;
    } on AppwriteException catch (e) {
      debugPrint("Error getRank : ${e.message}");
      rethrow;
    }
  }

  Future<void> updateDifficultySelected(String difficultySelected) async {
    try {
      progress.difficultySelected = difficultySelected;
      notifyListeners();
      await dataRepository.updateRow(
        tableId: "user_goals",
        rowId: authProvider.currentUser!.id,
        data: {'difficulty': difficultySelected},
      );
      await dataRepository.updateRow(
        tableId: "user_profiles",
        rowId: authProvider.currentUser!.id,
        data: {'difficulty': difficultySelected},
      );
    } catch (e) {
      rethrow;
    }
  }
}
