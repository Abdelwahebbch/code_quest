import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/models/party_model.dart';
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
  late Realtime realtime;
  late bool isFirstLogin = true;
  late UserInfo progress;
  late Party party;

  AppwriteService() {
    _init();
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
    final account = Account(client);
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      String? fcmToken = await messaging.getToken();

      if (fcmToken != null) {
        await account.createPushTarget(
          targetId: ID.unique(),
          identifier: fcmToken,
          providerId: '699bf106002c3fc1716f',
        );
      }
    } catch (e) {
      print("Error fi el registerNotificationDevice ");
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
          await account.createEmailPasswordSession(
            email: email,
            password: password,
          );
        case true:
          await account.createOAuth2Session(
            provider: OAuthProvider.google,
          );
      }
      _user = await account.get();
      await createNewRow();
      await getUserInfo();
      _isLoading = false;
      registerNotificationDevice();
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
      // await account.deleteSession(sessionId: 'current');
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _user = await account.get();
      _isLoading = false;
      registerNotificationDevice();
      await getUserInfo();
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error : $e");
      rethrow;
    }
  }

  /// Google SignIn
  Future<void> signInWithGoogle() async {
    try {
      await account.createOAuth2Session(
        provider: OAuthProvider.google,
      );

      _user = await account.get();
      _isLoading = false;
      await getUserInfo();
      notifyListeners();
    } on AppwriteException catch (e) {
      print("Appwrite Auth Error: ${e.message}");
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
  ///to get user info
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
        tableId: "user_goals",
        rowId: _user!.$id,
        data: {'lang_goal': languageSelected},
      );
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

  Future<void> updateDifficultySelected(String difficultySelected) async {
    try {
      progress.difficultySelected = difficultySelected;
      notifyListeners();
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "user_goals",
        rowId: _user!.$id,
        data: {'difficulty': difficultySelected},
      );
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
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
        databaseId: "6972adad002e2ba515f2",
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

  Future<void> updateMissionStatus(String id, double rate) async {
    try {
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "missions",
        rowId: id,
        data: {'isCompleted': true, "rate": rate},
      );
      int? missionNb;
      for (int i = 0; i < progress.missions.length; i++) {
        if (progress.missions[i].id == id) {
          progress.missions[i].isCompleted = true;
          missionNb = i;
        }
      }
      await checkbadges(missionNb!);
      notifyListeners();
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

  Future<void> addToConversation(
      String role, int index, String id, String msg) async {
    try {
      progress.missions[index].conversation
          .add(jsonEncode({'role': role, 'message': msg}));

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

  Future<String> createParty(Party party) async {
    try {
      List<String> partyMembers = [];
      partyMembers.add(
          jsonEncode({"memberId": party.members[0].userId, "isReady": false}));
      this.party = party;
      notifyListeners();
      final row = await database.createRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party",
        data: {
          "partyId": int.parse(party.partyId),
          "partyName": party.partyName,
          "hostId": party.hostId,
          "hostName": party.hostName,
          "members": partyMembers,
          "maxMembers": party.maxMembers,
          "difficulty": party.difficulty,
          "gameMode": party.gameMode,
          "totalRounds": party.totalRounds,
          "isStarted": party.isStarted
        },
        rowId: ID.unique(),
      );
      await database.createRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party_member",
        data: {
          "partyId": row.$id,
          "userId": user?.$id,
          "username": user?.name,
          "imageId": progress.imageId,
          "joinedAt": DateTime.now().toString(),
          "score": 0,
          "correctAnswers": 0,
          "totalAnswers": 0
        },
        rowId: ID.unique(),
      );
      return row.$id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> joinParty(int code) async {
    try {
      var result = await database.listRows(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party",
        queries: [
          Query.equal("partyId", code),
        ],
      );
      var row = result.rows[0];
      String rowId = result.rows[0].$id;
      List<dynamic> dbMembers = List.from(result.rows[0].data["members"] ?? []);
      int maxMembers = result.rows[0].data["maxMembers"];
      if (dbMembers.length < maxMembers) {
        List<PartyMember> members = [];

        for (int i = 0; i < dbMembers.length; i++) {
          String memberId = jsonDecode(dbMembers[i])["memberId"];
          var row = await database.listRows(
            databaseId: "6972adad002e2ba515f2",
            tableId: "party_member",
            queries: [
              Query.equal("partyId", rowId),
              Query.equal("userId", memberId)
            ],
          );
          members.add(PartyMember(
              userId: row.rows[0].data["userId"],
              username: row.rows[0].data["username"],
              imageId: row.rows[0].data["imageId"],
              joinedAt: DateTime.parse(row.rows[0].data["joinedAt"]),
              score: row.rows[0].data["score"],
              correctAnswers: row.rows[0].data["correctAnswers"],
              totalAnswers: row.rows[0].data["totalAnswers"],
              isReady: false));
        }
        PartyMember member = PartyMember(
            userId: user!.$id,
            username: user!.name,
            imageId: progress.imageId,
            joinedAt: DateTime.now(),
            score: 0,
            correctAnswers: 0,
            totalAnswers: 0,
            isReady: false);
        dbMembers.add(jsonEncode({"memberId": user?.$id, "isReady": false}));
        party = Party(
          partyId: row.data["partyId"].toString(),
          partyName: row.data["partyName"],
          hostId: row.data["hostId"],
          hostName: row.data["hostName"],
          members: members,
          maxMembers: row.data["maxMembers"],
          difficulty: row.data["difficulty"],
          gameMode: row.data["gameMode"],
          totalRounds: row.data["totalRounds"],
          isStarted: row.data["isStarted"],
        );
        members.add(member);
        notifyListeners();
        await database.updateRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "party",
          rowId: rowId,
          data: {'members': dbMembers},
        );
        await database.createRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "party_member",
          rowId: ID.unique(),
          data: {
            "partyId": rowId,
            "userId": user!.$id,
            "username": user!.name,
            "imageId": progress.imageId,
            "joinedAt": DateTime.now().toString(),
            "score": 0,
            "correctAnswers": 0,
            "totalAnswers": 0,
          },
        );
        return rowId;
      }
      return "";
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMemberDetails(
      String rowId, var userId) async {
    Map<String, dynamic> member = {};
    var row = await database.listRows(
      databaseId: "6972adad002e2ba515f2",
      tableId: "party_member",
      queries: [Query.equal("partyId", rowId), Query.equal("userId", userId)],
    );
    member.addAll({
      "userId": row.rows[0].data["userId"],
      "username": row.rows[0].data["username"],
      "imageId": row.rows[0].data["imageId"],
      "joinedAt": DateTime.parse(row.rows[0].data["joinedAt"]),
      "score": row.rows[0].data["score"],
      "correctAnswers": row.rows[0].data["correctAnswers"],
      "totalAnswers": row.rows[0].data["totalAnswers"],
    });
    return member;
  }

  Future<void> toggleReady(String rowId) async {
    try {
      List<dynamic> jsonMembers = [];
      for (int i = 0; i < party.members.length; i++) {
        if (party.members[i].username == user?.name) {
          bool isReady = party.members[i].isReady;
          party.members[i].isReady = !isReady;
        }
        jsonMembers.add(jsonEncode({
          "memberId": party.members[i].userId,
          "isReady": party.members[i].isReady
        }));
      }

      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party",
        rowId: rowId,
        data: {'members': jsonMembers},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startParty(String rowId) async {
    try {
      party.isStarted = true;
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party",
        rowId: rowId,
        data: {'isStarted': true},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> quiteLobby(String rowId) async {
    try {
      List<dynamic> dbMembers = [];
      for (int i = 0; i < party.memberCount; i++) {
        if (party.members[i].userId != user?.$id) {
          dbMembers.add(jsonEncode({
            "memberId": party.members[i].userId,
            "isReady": party.members[i].isReady
          }));
        } else {
          party.members.removeAt(i);
        }
      }
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party",
        rowId: rowId,
        data: {'members': dbMembers},
      );
      var row = await database.listRows(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
          Query.equal("userId", user?.$id)
        ],
      );
      await database.deleteRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "party_member",
          rowId: row.rows[0].$id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitAnswer(String rowId, int memberIndex, int score,
      int correctAnwsers, int totalAnswers) async {
    try {
      party.members[memberIndex].score = score;
      party.members[memberIndex].correctAnswers = correctAnwsers;
      party.members[memberIndex].totalAnswers = totalAnswers;
      var row = await database.listRows(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
          Query.equal("userId", user?.$id)
        ],
      );
      await database.updateRow(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party_member",
        rowId: row.rows[0].$id,
        data: {
          'correctAnswers': correctAnwsers,
          "score": score,
          "totalAnswers": totalAnswers
        },
      );
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMembersDetails(String rowId) async {
    for (int i = 0; i < party.memberCount; i++) {
      var row = await database.listRows(
        databaseId: "6972adad002e2ba515f2",
        tableId: "party_member",
        queries: [
          Query.equal("partyId", rowId),
          Query.equal("userId", party.members[i].userId)
        ],
      );
      party.members[i].score = row.rows[0].data["score"];
      party.members[i].correctAnswers = row.rows[0].data["correctAnswers"];
      party.members[i].totalAnswers = row.rows[0].data["totalAnswers"];
      print(row.rows[0].data["score"]);
    }
    notifyListeners();
    print("aaaa2");
  }
}
