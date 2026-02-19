import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/services/appwrite_cloud_functions_service.dart';
import '../models/mission_model.dart';

class AppwriteService extends ChangeNotifier {
  Client client = Client();

  models.User? _user;
  models.User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late Account account;
  late TablesDB database;
  late Storage storage;
  late bool isFirstLogin = true;
  late UserInfo progress;

  AppwriteService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint('https://fra.cloud.appwrite.io/v1')
        .setProject('697295e70021593c3438')
        .setSelfSigned(status: true);

    account = Account(client);
    database = TablesDB(client);
    storage = Storage(client);
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      _user = await account.get();
      await getUserInfo();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createNewRow() async {
    try {
      //  models.User user = await account.get();
      await database.createRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: 'user_profiles',
        rowId: _user!.$id,
        data: {
          'experience': 500,
          'totalPoints': 10,
          'progLanguage': "",
          'earnedBadges': [],
          'bio': "",
          'imageId': "",
          'nbMission': 0,
          'badgesProgress': jsonEncode({
            "debug": 0,
            "complete": 0,
            "test": 0,
            "singleChoice": 0,
            "multipleChoice": 0,
            "ordering": 0
          }),
          'isFirstLogin': true,
        },
        permissions: [
          Permission.read(Role.user(_user!.$id)),
          Permission.update(Role.user(_user!.$id)),
        ],
      );
    } catch (e) {
      debugPrint("Error : $e");
      rethrow;
    }
  }

  Future<void> signup(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _user = await account.get();
      await createNewRow();
      await getUserInfo();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _user = await account.get();
      _isLoading = false;
      await getUserInfo();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error : $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

//TODO : nzidou les dates mte3 les exams haka3lech Map<String, --> dynamic <---- >
  void completeOnboarding(Map<String, dynamic> data) async {
    try {
      await database.createRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_goals",
          rowId: user!.$id,
          data: data);
      updateIsFirstLogin();
      await AppwritecloudfunctionsService().createCustomMissions();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Mission>> getMissions() async {
    try {
      final response = await database.listRows(
          databaseId: "6972adad002e2ba515f2",
          tableId: "missions",
          queries: [
            !isFirstLogin
                ? Query.equal("user_id", user!.$id)
                : Query.equal("user_id", "mock_miss"),
          ]);

      return response.rows.map((doc) {
        return Mission(
          id: doc.$id,
          title: doc.data['title'],
          description: doc.data['description'],
          type: MissionType.values.firstWhere(
              (e) => e.toString().split('.').last == doc.data['type']),
          points: doc.data['points'],
          difficulty: doc.data['difficulty'],
          initialCode: doc.data['initialCode'],
          options: doc.data['options'],
          correctOrder: doc.data['correctOrder'],
          solution: doc.data['solution'],
          isCompleted: isFirstLogin ? false : doc.data['isCompleted'],
          nbFailed: doc.data['nbFailed'] ?? 0,
          aiPointsUsed: doc.data['aiPointsUsed'] ?? 0,
          conversation: List<String>.from(doc.data['conversation'] ?? []),
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching missions: $e");
      rethrow;
    }
  }

  Future<void> getUserInfo() async {
    try {
      models.User user = await account.get();
      final row = await database.getRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_profiles",
          rowId: user.$id);
      int x = await getRank();

      isFirstLogin = row.data["isFirstLogin"] ?? true;
      notifyListeners();
      progress = UserInfo(
        progLanguage: row.data["progLanguage"] ?? "not selected",
        username: user.name,
        experience: row.data["experience"],
        totalPoints: row.data["totalPoints"],
        earnedBadges: List<String>.from(row.data["earnedBadges"] ?? []),
        bio: row.data["bio"],
        imageId: row.data["imageId"],
        email: user.email,
        rank: x,
        nbMissions: row.data["nbMission"] ?? 0,
        missions: await getMissions(),
        badgesProgress: jsonDecode(row.data["badgesProgress"]),
        showingBadges: [],
        nbMissionCompletedWithoutHints:
            row.data["nbMissionCompletedWithoutHints"] ?? 0,
        totalFailures: row.data["totalFailures"] ?? 0,
        totalAIQuestions: row.data["totalAIQuestions"] ?? 0,
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error fi getUserInfo $e");
      rethrow;
    }
  }

  Future<void> updateProfile(
      String imagePath, String userName, String bio) async {
    try {
      if (imagePath.isNotEmpty) {
        final file = await storage.createFile(
          bucketId: '69891b1d0012c9a7e862',
          fileId: ID.unique(),
          file: InputFile.fromPath(
              path: imagePath, filename: imagePath.split('/').last),
        );
        await database.updateRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_profiles",
          rowId: _user!.$id,
          data: {'imageId': file.$id, 'bio': bio},
        );
        progress.bio = bio;
        progress.imageId = file.$id;
        progress.username = userName;
        notifyListeners();
      } else {
        await database.updateRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_profiles",
          rowId: _user!.$id,
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
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: _user!.$id,
        data: {'progLanguage': languageSelected},
      );
      progress.progLanguage = languageSelected;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> checkbadges(int missionNb) async {
    try {
      List<String> returnedBagdes = [];
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
          returnedBagdes.add('Bug Hunter');
          progress.showingBadges.add('Bug Hunter');
        }
      }
      if (progress.nbMissionCompletedWithoutHints >= 5) {
        if (!progress.earnedBadges.contains('Code Ninja')) {
          progress.earnedBadges.add('Code Ninja');
          returnedBagdes.add('Code Ninja');
          progress.showingBadges.add('Code Ninja');
        }
      }
      if (progress.badgesProgress['test']! >= 5) {
        if (!progress.earnedBadges.contains('Test Master')) {
          progress.earnedBadges.add('Test Master');
          returnedBagdes.add('Test Master');
          progress.showingBadges.add('Test Master');
        }
      }
      if (missionsCompletedToday >= 3) {
        if (!progress.earnedBadges.contains('Fast Learner')) {
          progress.earnedBadges.add('Fast Learner');
          returnedBagdes.add('Fast Learner');
          progress.showingBadges.add('Fast Learner');
        }
      }
      if (progress.badgesProgress['ordering'] >= 10) {
        if (!progress.earnedBadges.contains('Architect')) {
          progress.earnedBadges.add('Architect');
          returnedBagdes.add('Architect');
          progress.showingBadges.add('Architect');
        }
      }
      if (progress.badgesProgress['complete'] >= 10 &&
          progress.totalFailures <= 30) {
        if (!progress.earnedBadges.contains('Clean Coder')) {
          progress.earnedBadges.add('Clean Coder');
          returnedBagdes.add('Clean Coder');
          progress.showingBadges.add('Clean Coder');
        }
      }
      if (progress.badgesProgress['singleChoice'] >= 10 &&
          progress.badgesProgress['multipleChoice'] >= 10) {
        if (!progress.earnedBadges.contains('Team Player')) {
          progress.earnedBadges.add('Team Player');
          returnedBagdes.add('Team Player');
          progress.showingBadges.add('Team Player');
        }
      }
      if (progress.totalAIQuestions >= 50) {
        if (!progress.earnedBadges.contains('AI Whisperer')) {
          progress.earnedBadges.add('AI Whisperer');
          returnedBagdes.add('AI Whisperer');
          progress.showingBadges.add('AI Whisperer');
        }
      }
      notifyListeners();
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: _user!.$id,
        data: {
          'badgesProgress': jsonEncode(progress.badgesProgress),
          'earnedBadges': progress.earnedBadges
        },
      );

      return returnedBagdes;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> updateMissionStatus(String id) async {
    try {
      List<String> returnedBagdes = [];
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "missions",
        rowId: id,
        data: {'isCompleted': true},
      );
      int? missionNb;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isCompleted = true;
          missionNb = i;
        }
      }
      returnedBagdes = await checkbadges(missionNb!);
      notifyListeners();
      return returnedBagdes;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getRank() async {
    try {
      final r = await database.listRows(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_profiles",
          queries: [
            Query.orderDesc("experience"),
          ]);

      return r.rows.indexWhere(
            (row) => row.$id == _user!.$id,
          ) +
          1;
    } on AppwriteException catch (e) {
      debugPrint("Error getRank : ${e.message}");
      rethrow;
    }
  }

  void emptyShowingBadges() {
    progress.showingBadges = [];
    notifyListeners();
  }

  Future<void> updateFailedNb(String id) async {
    try {
      int previousNbFailed = 0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          previousNbFailed = progress.missions[i].nbFailed;
          progress.missions[i].nbFailed = previousNbFailed + 1;
        }
      }
      int cuurentNbFailed = previousNbFailed + 1;
      int previousTotalFailures = progress.totalFailures;
      int currentTotalFailures = previousTotalFailures + 1;
      progress.totalFailures = currentTotalFailures;
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "missions",
        rowId: id,
        data: {'nbFailed': cuurentNbFailed},
      );
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: user!.$id,
        data: {'totalFailures': currentTotalFailures},
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateXp(int xp) async {
    try {
      int newExperience = progress.experience + xp;
      progress.experience = newExperience;
      notifyListeners();
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: user!.$id,
        data: {'experience': newExperience},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserPoints(int nb) async {
    try {
      int previousTotalPoints = progress.totalPoints;
      int currentTotalPoints = previousTotalPoints + nb;
      progress.totalPoints = currentTotalPoints;
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: _user!.$id,
        data: {'totalPoints': currentTotalPoints},
      );
      notifyListeners();
    } catch (e) {
      rethrow;
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
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "missions",
        rowId: id,
        data: {'aiPointsUsed': currentAiPointsUsed},
      );
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: user!.$id,
        data: {'totalAIQuestions': currentToalAIQuestions},
      );
      await updateUserPoints(-1);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  Future<void> addToConversation(String role,int index,String id,String msg) async{
    try {
      
      progress.missions[index].conversation.add(jsonEncode({'role':role,'message':msg}));
      
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "missions",
        rowId: id,
        data: {'conversation': progress.missions[index].conversation},
      );
    } catch (e) {
      rethrow;
    }
  }

  void updateIsFirstLogin() {
    if (isFirstLogin) {
      database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_profiles",
        rowId: user!.$id,
        data: {'isFirstLogin': false},
      );
      isFirstLogin = false;
      notifyListeners();
    }
  }
}
