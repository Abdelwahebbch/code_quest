import 'dart:convert';
import 'dart:math';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/models/learning_path_model.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:pfe_test/models/user_info_model.dart';
import 'package:pfe_test/services/appwrite_cloud_functions_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission_model.dart';

class AppwriteService extends ChangeNotifier {
  Client client = Client();

  models.User? _user;
  models.User? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late LearningPath path;
  late Account account;
  late TablesDB database;
  late Storage storage;
  late Realtime realtime;
  late bool isFirstLogin = true;
  late UserInfo progress;
  late Party party;
  late PartyMember partyMember;
  late Map<String, dynamic> userGoals;
  final String dbID = '6972adad002e2ba515f2';

  AppwriteService() {
    _init();
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      final prefs = await SharedPreferences.getInstance();
      await account.createPushTarget(
        targetId: ID.unique(),
        identifier: newToken,
        providerId: '699bf106002c3fc1716f',
      );
      await prefs.setString('fcm_token', newToken);
    });

    print("ok");
    registerNotificationDevice();
    print("ok");
  }

  void _init() {
    client
        .setEndpoint('https://fra.cloud.appwrite.io/v1')
        .setProject('697295e70021593c3438');

    account = Account(client);
    database = TablesDB(client);
    storage = Storage(client);
    realtime = Realtime(client);
    checkSession();
  }

  Future<void> registerNotificationDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('fcmToken');

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();

    if (fcmToken != null && fcmToken != storedToken) {
      try {
        await account.createPushTarget(
          targetId: ID.unique(),
          identifier: fcmToken,
          providerId: '699bf106002c3fc1716f',
        );
        await prefs.setString('fcmToken', fcmToken);
        // ignore: empty_catches
      } catch (e) {
        debugPrint("error fi register nooootiiif $e ");
      }
    }
  }

  Future<void> checkSession() async {
    try {
      _user = await account.get();
      await getUserInfo();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> createNewRow() async {
    try {
      // models.User user = await account.get();
      await database.createRow(
        databaseId: dbID,
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
          'difficulty': "intermediate",
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
      );
    } catch (e) {
      debugPrint("Error fi create new row: $e");
      rethrow;
    }
  }

  Future<void> signup(
      String email, String password, String name, bool isGoogle) async {
    _isLoading = true;
    notifyListeners();
    try {
      switch (isGoogle) {
        case false:
          await account.create(
            userId: ID.unique(),
            email: email,
            password: password,
            name: name,
          );
          //await account.deleteSession(sessionId: 'current');
          await account.createEmailPasswordSession(
            email: email,
            password: password,
          );
          break;
        case true:
          await account.createOAuth2Session(
            provider: OAuthProvider.google,
          );
          break;
      }
      _user = await account.get();
      await createNewRow();
      await getUserInfo();
      await registerNotificationDevice();
      _isLoading = false;
      // registerNotificationDevice();
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
      // registerNotificationDevice();
      await getUserInfo();
      await registerNotificationDevice();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error  fi login : $e");
      rethrow;
    }
  }

  /// Google SignIn
  Future<void> signInWithGoogle() async {
    try {
      // account.deleteSession(sessionId: 'current');
      await account.createOAuth2Session(
        provider: OAuthProvider.google,
      );
      _user = await account.get();
      try {
        await createNewRow();
      } on AppwriteException catch (e) {
        if (e.code == 409) {
          print("User row already exists. Skipping creation.");
        } else {
          rethrow;
        }
      }
      await getUserInfo();
      await registerNotificationDevice();
      _isLoading = false;
      notifyListeners();
    } on AppwriteException catch (e) {
      print("Appwrite Auth Error: ${e.message}");
      _isLoading = false;
      notifyListeners();
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

  Future<void> completeOnboarding(Map<String, String> data, bool pathCreation,
      DateTime? startDate, DateTime? endDate) async {
    try {
      userGoals = data;
      print(progress.progLanguage);
      print(data["journey"].toString());
      updateIsFirstLogin();
      if (startDate != null && endDate != null) {
        await database.createRow(
            databaseId: dbID,
            tableId: "user_goals",
            rowId: user!.$id,
            data: {
              "username": user!.name,
              "prompt": jsonEncode(data),
              "startDate": startDate.toString(),
              "endDate": endDate.toString()
            });
      } else {
        await database.createRow(
            databaseId: dbID,
            tableId: "user_goals",
            rowId: user!.$id,
            data: {"username": user!.name, "prompt": jsonEncode(data)});
      }

      var rows = await database
          .listRows(databaseId: dbID, tableId: "mock_mission", queries: [
        Query.equal("user_category", data["journey"].toString()),
        Query.equal("language", progress.progLanguage),
      ]);

      for (var row in rows.rows) {
        await database.createRow(
            databaseId: dbID,
            tableId: "missions",
            rowId: ID.unique(),
            data: {
              "user_id": user!.$id,
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

  Future<List<Mission>> getMissions() async {
    try {
      late models.RowList response;
      String date = DateTime.now().toUtc().toIso8601String().split('T').first;
      print(date);

      response = await database
          .listRows(databaseId: dbID, tableId: "missions", queries: [
        Query.equal("user_id", user!.$id),
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

        response = await database
            .listRows(databaseId: dbID, tableId: "missions", queries: [
          Query.equal("user_id", user!.$id),
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

  Future<LearningPath> getLearningPath() async {
    List<LearningPathMilestone> milestones = [];
    List<Concept> concepts = [];
    try {
      var row = await database.getRow(
          databaseId: dbID,
          tableId: DatabaseTables.learnig_paths.name,
          rowId: user!.$id,
          queries: [
            Query.select([
              "*",
              "milestones.*",
              "milestones.concepts.*",
              "milestones.concepts.missionrelation.*"
            ])
          ]);

      final Map<String, dynamic> parsedData = row.data;
      milestones = (parsedData['milestones'] as List<dynamic>?)
              ?.map((e) =>
                  LearningPathMilestone.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      for (var m in milestones) {
        if (m.concepts.isNotEmpty) {
          concepts.addAll(m.concepts);
        }
      }
      return LearningPath.fromJson(parsedData, milestones, concepts);
    } catch (e) {
      debugPrint("Error fetching learning path : $e");
      rethrow;
    }
  }

  Future<void> getuserGoals() async {
    final row = await database.getRow(
        databaseId: dbID, tableId: "user_goals", rowId: _user!.$id);

    progress.rate = row.data["rate"] / 1;

    userGoals = jsonDecode(row.data["prompt"]);
  }

  Future<void> getUserInfo() async {
    try {
      models.User user = await account.get();
      final row = await database.getRow(
          databaseId: dbID, tableId: "user_profiles", rowId: user.$id);

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
        difficultySelected: row.data["difficulty"] ?? "Intermediate",
        nbMissions: row.data["nbMission"] ?? 0,
        missions: await getMissions(),
        badgesProgress: jsonDecode(row.data["badgesProgress"]),
        showingBadges: [],
        nbMissionCompletedWithoutHints:
            row.data["nbMissionCompletedWithoutHints"] ?? 0,
        totalFailures: row.data["totalFailures"] ?? 0,
        totalAIQuestions: row.data["totalAIQuestions"] ?? 0,
        elo: row.data["elo"],
      );

      if (!isFirstLogin) {
        await getuserGoals();
      }

      try {
        path = await getLearningPath();
        print(path.milestones.first.concepts.length);
      } on AppwriteException catch (e) {
        if (e.code == 404) {
          print("Not Found mouch mochkol");
        } else {
          rethrow;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint("Error fi getUserInfo $e");
      rethrow;
    }
  }

  Future<void> updateUserGoals(Map<String, String> data) async {
    await database.updateRow(
        databaseId: dbID,
        tableId: "user_goals",
        rowId: user!.$id,
        data: {"prompt": jsonEncode(data)});
    userGoals = data;
    notifyListeners();
  }

  Future<void> fixEducationTime(DateTime? startDate, DateTime? endDate) async {
    await database.updateRow(
        databaseId: dbID,
        tableId: "user_goals",
        rowId: user!.$id,
        data: { "startDate": startDate?.toString(),
              "endDate": endDate?.toString()});
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
          databaseId: dbID,
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
          databaseId: dbID,
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
        databaseId: dbID,
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

  Future<void> updateDifficultySelected(String difficultySelected) async {
    try {
      progress.difficultySelected = difficultySelected;
      notifyListeners();
      await database.updateRow(
        databaseId: dbID,
        tableId: "user_goals",
        rowId: _user!.$id,
        data: {'difficulty': difficultySelected},
      );
      await database.updateRow(
        databaseId: dbID,
        tableId: "user_profiles",
        rowId: _user!.$id,
        data: {'difficulty': difficultySelected},
      );
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
      await database.updateRow(
        databaseId: dbID,
        tableId: "user_profiles",
        rowId: _user!.$id,
        data: {
          'badgesProgress': jsonEncode(progress.badgesProgress),
          'earnedBadges': progress.earnedBadges
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRate(int missionDiffculty,int missionPoints ,double S) async {
    try {
      //Elo Algorthime
      //s= normalized mission rate
      //E = Expected probability
      //2 = is scale you can change
      double E = 1 / (1 + pow(10, ((missionDiffculty - progress.rate) / 4)));
      double k= 0.3*(1+0.5*(missionDiffculty/10));
      double s2=S*(1+0.1*(missionPoints/2500));
      // Update
      double newRate = progress.rate + k*(s2 - E);
      print(newRate);
      progress.elo+=((k*(s2 - E))*100).toInt();
      if(progress.elo<0) progress.elo=0;
      if(newRate>10) newRate=10;
      if(newRate<0.0) newRate=0.0;
      progress.rate = double.parse(newRate.clamp(1, 10).toStringAsFixed(2));
      notifyListeners();
      await database.updateRow(
          databaseId: dbID,
          tableId: "user_goals",
          rowId: user!.$id,
          data: {'rate': progress.rate});
      await database.updateRow(
          databaseId: dbID,
          tableId: "user_profiles",
          rowId: user!.$id,
          data: {'elo': progress.elo});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMissionStatus(String id, double rate) async {
    try {
      await database.updateRow(
        databaseId: dbID,
        tableId: "missions",
        rowId: id,
        data: {'isCompleted': true, "rate": rate},
      );
      progress.nbMissions += 1;
      await database.updateRow(
          databaseId: dbID,
          tableId: "user_profiles",
          rowId: user!.$id,
          data: {'nbMission': progress.nbMissions});
      int? missionNb;
      int missionDiffculty = 0;
      int missionPoints=0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isCompleted = true;
          missionDiffculty = progress.missions[i].difficulty;
          missionPoints= progress.missions[i].points;
          missionNb = i;
        }
      }
      await updateRate(missionDiffculty, missionPoints,rate);
      await checkbadges(missionNb!);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> surrendereMission(String id) async{
    try {
      await database.updateRow(
        databaseId: dbID,
        tableId: "missions",
        rowId: id,
        data: {'Surrendered': true},
      );
      int? missionNb;
      int missionDiffculty = 0;
      int missionPoints=0;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isSurrendered = true;
          missionDiffculty = progress.missions[i].difficulty;
          missionPoints= progress.missions[i].points;
        }
      }
      await updateRate(missionDiffculty, missionPoints,0);
      //To do Rate
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<int> getRank() async {
    try {
      final r = await database
          .listRows(databaseId: dbID, tableId: "user_profiles", queries: [
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
      progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed += 1;

      await database.updateRow(
        databaseId: dbID,
        tableId: "missions",
        rowId: id,
        data: {
          'nbFailed':
              progress.missions.firstWhere((m) => m.id.contains(id)).nbFailed
        },
      );
      await database.updateRow(
        databaseId: dbID,
        tableId: "user_profiles",
        rowId: user!.$id,
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

  Future<void> updateXp(int xp) async {
    try {
      int newExperience = progress.experience + xp;
      progress.experience = newExperience;
      notifyListeners();
      await database.updateRow(
        databaseId: dbID,
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
        databaseId: dbID,
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
        databaseId: dbID,
        tableId: "missions",
        rowId: id,
        data: {'aiPointsUsed': currentAiPointsUsed},
      );
      await database.updateRow(
        databaseId: dbID,
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

  Future<void> addToConversation(
      String role, int index, String id, String msg) async {
    try {
      progress.missions[index].conversation
          .add(jsonEncode({'role': role, 'message': msg}));

      await database.updateRow(
        databaseId: dbID,
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
        databaseId: dbID,
        tableId: "user_profiles",
        rowId: user!.$id,
        data: {'isFirstLogin': false},
      );
      isFirstLogin = false;
      notifyListeners();
    }
  }

  Future<String> checkExistingParty() async {
    print('aa4');
    var row = await database.listRows(
      databaseId: dbID,
      tableId: "party",
      queries: [
        Query.equal("hostId", user?.$id),
      ],
    );

    if (row.rows.isNotEmpty) {
      print("aaaaa");
      return row.rows[0].$id;
    }
    print("aaaa1");
    return "";
  }

  Future<void> createParty(Party party) async {
    try {
      this.party = party;
      partyMember = PartyMember(
        userId: user!.$id,
        username: user!.name,
        imageId: progress.imageId,
        joinedAt: DateTime.now(),
        score: 0,
        correctAnswers: 0,
        totalAnswers: 0,
        isReady: false,
      );
      notifyListeners();
      await database.createRow(
        databaseId: dbID,
        tableId: "party",
        rowId: party.partyId,
        data: {
          "partyCode": party.partyCode,
          "partyName": party.partyName,
          "hostId": party.hostId,
          "hostName": party.hostName,
          "maxMembers": party.maxMembers,
          "difficulty": party.difficulty,
          "gameMode": party.gameMode,
          "totalRounds": party.totalRounds,
          "isStarted": party.isStarted,
          "isPublic": party.isPublic
        },
      );
      await database.createRow(
        databaseId: dbID,
        tableId: "party_member",
        data: {
          "partyId": party.partyId,
          "userId": user!.$id,
          "username": user?.name,
          "imageId": progress.imageId,
          "joinedAt": DateTime.now().toString(),
          "score": 0,
          "correctAnswers": 0,
          "totalAnswers": 0,
          "isReady": false,
          "isSubmit": false,
        },
        rowId: user!.$id,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> joinParty(String code) async {
    try {
      final partyResult = await database.listRows(
        databaseId: dbID,
        tableId: "party",
        queries: [
          Query.equal("partyCode", code),
        ],
      );

      if (partyResult.rows.isEmpty) {
        return "Party not found";
      }
      final partyRow = partyResult.rows.first;
      final String rowId = partyRow.$id;
      final bool isStarted= partyRow.data["isStarted"];
      print(isStarted);
      if(isStarted == true){
        return "Party already Started";
      }
      final int maxMembers = partyRow.data["maxMembers"] ?? 0;
      final membersResult = await database.listRows(
        databaseId: dbID,
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
        ],
      );

      final currentMembersCount = membersResult.rows.length;

      if (currentMembersCount >= maxMembers) {
        return "Party is Full";
      }
      final memberData = {
        "partyId": rowId,
        "userId": user!.$id,
        "username": user!.name,
        "imageId": progress.imageId,
        "joinedAt": DateTime.now().toIso8601String(),
        "score": 0,
        "correctAnswers": 0,
        "totalAnswers": 0,
        "isReady": false,
      };
      await database.createRow(
        databaseId: dbID,
        tableId: "party_member",
        rowId: user!.$id,
        data: memberData,
      );
      final List<PartyMember> members = membersResult.rows
          .map((m) => PartyMember(
              userId: m.data["userId"],
              username: m.data["username"],
              imageId: m.data["imageId"],
              joinedAt: DateTime.parse(m.data["joinedAt"]),
              score: m.data["score"],
              correctAnswers: m.data["correctAnswers"],
              totalAnswers: m.data["totalAnswers"],
              isReady: m.data["isReady"],
              isSubmit: m.data["isSubmit"]))
          .toList();
      partyMember = PartyMember(
          userId: user!.$id,
          username: user!.name,
          imageId: progress.imageId,
          joinedAt: DateTime.now(),
          score: 0,
          correctAnswers: 0,
          totalAnswers: 0,
          isReady: false,
          isSubmit: false);

      members.add(partyMember);

      party = Party(
        partyId: partyRow.$id,
        partyCode: partyRow.data["partyCode"],
        partyName: partyRow.data["partyName"],
        hostId: partyRow.data["hostId"],
        hostName: partyRow.data["hostName"],
        members: members,
        maxMembers: partyRow.data["maxMembers"],
        difficulty: partyRow.data["difficulty"],
        gameMode: partyRow.data["gameMode"],
        totalRounds: partyRow.data["totalRounds"],
        isStarted: partyRow.data["isStarted"],
      );
      notifyListeners();
      return rowId;
    } catch (e) {
      //Mazelt el cas mte kif yabdew yal3bo w yo5rej
      print("Error joining party: $e");
      rethrow;
    }
  }

  Future<void> toggleReady(String rowId) async {
    try {
      bool isReady = false;
      for (int i = 0; i < party.members.length; i++) {
        if (party.members[i].username == user?.name) {
          isReady = party.members[i].isReady;
          party.members[i].isReady = !isReady;
          partyMember.isReady = !isReady;
        }
      }

      await database.listRows(
        databaseId: dbID,
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
          Query.equal("userId", user?.$id)
        ],
      );
      await database.updateRow(
        databaseId: dbID,
        tableId: "party_member",
        rowId: user!.$id,
        data: {'isReady': !isReady},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startParty(String rowId) async {
    try {
      await database.updateRow(
        databaseId: dbID,
        tableId: "party",
        rowId: rowId,
        data: {'isStarted': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> quiteLobby(String? row) async {
    try {
      if (row == null) {
        if (party.hostId.contains(user!.$id)) {
          await database.deleteRow(
              databaseId: dbID, tableId: "party", rowId: party.partyId);
          deleteAllMembers();
        } else {
          await database.deleteRow(
              databaseId: dbID, tableId: "party_member", rowId: user!.$id);
        }
      } else {
        await database.deleteRow(
            databaseId: dbID, tableId: "party", rowId: row);
        await database.deleteRow(
            databaseId: dbID, tableId: "party_member", rowId: user!.$id);
      }
      //notifyListeners();
    } catch (e) {
      print("Erreur quite lobby $e");
      rethrow;
    }
  }

  Future<void> deleteAllMembers() async {
    try {
      await Future.wait(party.members.map((m) => database.deleteRow(
            databaseId: dbID,
            tableId: "party_member",
            rowId: m.userId,
          )));
      party.members.clear();
    } catch (e) {
      print("Erreur fi deleteAllMembers $e");
      rethrow;
    }
  }

  Future<void> deleteMemberFromRemote(String id) async {
    try {
      await database.deleteRow(
          databaseId: dbID, tableId: "party_member", rowId: id);
      deleteMemberFromLocal(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitAnswer(PartyMember partyMember) async {
    try {
      this.partyMember.score = partyMember.score;
      this.partyMember.correctAnswers = partyMember.correctAnswers;
      this.partyMember.totalAnswers = partyMember.totalAnswers;
      await database.updateRow(
        databaseId: dbID,
        tableId: "party_member",
        rowId: user!.$id,
        data: {
          'correctAnswers': partyMember.correctAnswers,
          "score": partyMember.score,
          "totalAnswers": partyMember.totalAnswers,
          "isSubmit": true
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMembersDetails(String rowId) async {
    print(party.memberCount);
    bool isAllSubmit = false;
    while (isAllSubmit == false) {
      isAllSubmit = true;
      await Future.delayed(const Duration(seconds: 2));
      var rows = await database.listRows(
        databaseId: dbID,
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
        ],
      );
      for (int i = 0; i < rows.rows.length; i++) {
        for (int j = 0; j < party.memberCount; j++) {
          if (party.members[j].userId == rows.rows[i].data["userId"]) {
            party.members[j].score = rows.rows[i].data["score"];
            party.members[j].correctAnswers =
                rows.rows[i].data["correctAnswers"];
            party.members[j].totalAnswers = rows.rows[i].data["totalAnswers"];
            party.members[j].isSubmit = rows.rows[i].data["isSubmit"];
            if (!party.members[j].isSubmit) {
              isAllSubmit = false;
              break;
            }
          }
        }
        if (!isAllSubmit) {
          break;
        }
      }
      notifyListeners();
    }
  }

  Future<void> kickMember(String userId) async {
    try {
      await database.deleteRow(
          databaseId: dbID, tableId: "party_member", rowId: userId);
    } catch (e) {
      rethrow;
    }
  }

  void addMember(PartyMember partyMember) {
    party.members.add(partyMember);
    notifyListeners();
  }

  void changeIsStartedLocaly() {
    party.isStarted = !party.isStarted;
    notifyListeners();
  }

  void deleteMemberFromLocal(String memberId) {
    party.members.removeWhere((item) => item.userId == memberId);
    notifyListeners();
  }

  void toggleReadyLocaly(int memberIndex, bool isReady) {
    party.members[memberIndex].isReady = isReady;
    if (party.members[memberIndex].userId == user!.$id) {
      partyMember.isReady = isReady;
    }
    notifyListeners();
  }

  Future<void> savePartyHistory(List<PartyMember> rankedMembers) async {
    List<String> jsonMembers = [];
    for (int i = 0; i < rankedMembers.length; i++) {
      jsonMembers.add(rankedMembers[i].toJson());
    }
    await database.createRow(
      databaseId: dbID,
      tableId: "party_history",
      // kenet ID.unique
      rowId: ID.unique(),
      data: {
        "partyId": party.partyId,
        "partyName": party.partyName,
        "partyMembers": jsonMembers,
        "startedAt": party.startedAt.toString(),
        "completedAt": party.endedAt.toString(),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getQuiz() async {
    try {
      List<Map<String, dynamic>> quizs = [];
      var rows = await database.listRows(
        databaseId: "6972adad002e2ba515f2",
        tableId: "quizzes",
        queries: [
          Query.equal("partyId", party.partyId),
          Query.orderDesc("\$createdAt"),
        ],
      );
      for (int i = 0; i < rows.rows.length; i++) {
        final row = await database.getRow(
            databaseId: "6972adad002e2ba515f2",
            tableId: "quizzes",
            rowId: rows.rows[i].$id);
        quizs.add({
          'question': row.data['question'],
          'options': row.data['options'],
          'correct': row.data['correct'],
          'category': row.data['category']
        });
      }
      return quizs;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> GotToExisteParty(String partyIdDb) async {
    try {
      final partyRow = await database.getRow(
          databaseId: dbID, tableId: "party", rowId: partyIdDb);
      final membersResult = await database.listRows(
        databaseId: dbID,
        tableId: "party_member",
        queries: [
          Query.equal("partyId", partyIdDb),
        ],
      );
      final List<PartyMember> members = membersResult.rows
          .map((m) => PartyMember(
              userId: m.data["userId"],
              username: m.data["username"],
              imageId: m.data["imageId"],
              joinedAt: DateTime.parse(m.data["joinedAt"]),
              score: m.data["score"],
              correctAnswers: m.data["correctAnswers"],
              totalAnswers: m.data["totalAnswers"],
              isReady: m.data["isReady"],
              isSubmit: m.data["isSubmit"]))
          .toList();
      partyMember = PartyMember(
          userId: user!.$id,
          username: user!.name,
          imageId: progress.imageId,
          joinedAt: DateTime.now(),
          score: 0,
          correctAnswers: 0,
          totalAnswers: 0,
          isReady: false,
          isSubmit: false);
      final m = await database.getRow(
          databaseId: dbID, tableId: "party_member", rowId: user!.$id);
      partyMember = PartyMember(
          userId: m.data["userId"],
          username: m.data["username"],
          imageId: m.data["imageId"],
          joinedAt: DateTime.parse(m.data["joinedAt"]),
          score: m.data["score"],
          correctAnswers: m.data["correctAnswers"],
          totalAnswers: m.data["totalAnswers"],
          isReady: m.data["isReady"],
          isSubmit: m.data["isSubmit"]);
      party = Party(
        partyId: partyRow.$id,
        partyCode: partyRow.data["partyCode"],
        partyName: partyRow.data["partyName"],
        hostId: partyRow.data["hostId"],
        hostName: partyRow.data["hostName"],
        members: members,
        maxMembers: partyRow.data["maxMembers"],
        difficulty: partyRow.data["difficulty"],
        gameMode: partyRow.data["gameMode"],
        totalRounds: partyRow.data["totalRounds"],
        isStarted: partyRow.data["isStarted"],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkExistingPartyMember() async {
    try {
      await database.getRow(
          databaseId: dbID, tableId: "party_member", rowId: user!.$id);
      await database.deleteRow(
          databaseId: dbID, tableId: "party_member", rowId: user!.$id);
    } catch (e) {
      null;
    }
  }

  Future<void> partyPlayAgain() async {
    try {
      await database.updateRow(
        databaseId: dbID,
        tableId: "party",
        rowId: party.partyId,
        data: {'isStarted': false},
      );

    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLearningPathRows(DatabaseTables table, rowId) {
    return database.getRow(databaseId: dbID, tableId: table.name, rowId: rowId);
  }

  void testSelect() async {
    try {
      await database.createRow(
        databaseId: dbID,
        tableId: 'learnig_paths',
        rowId: ID.unique(),
        data: {
          'topic': 'Spiderman',
          'totalConceptsCompleted': 5,
          'totalConcepts': 5,
          'overallProgressPercentage': 5,
          'milestones': [
            {
              'title': 'Bob',
              'description': 'Great movie!',
              'order': 5,
              'concepts': [
                {'name': 'Aloo Alooo'}
              ]
            },
          ]
        },
      );
    } catch (e) {
      print("Error is $e");
    }
  }

  Future<Mission> loadMissions(String id) async {
    var mission = await database.getRow(
        databaseId: dbID, tableId: DatabaseTables.missions.name, rowId: id);

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
}

enum DatabaseTables {
  user_profiles,
  user_goals,
  quizzes,
  party_member,
  party_history,
  party,
  mock_mission,
  missions,
  learning_path_missions,
  learnig_paths,
  learnig_path_milestones,
  learnig_path_concepts,
  feedbacks
}
