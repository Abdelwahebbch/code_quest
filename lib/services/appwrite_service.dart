import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_info_model.dart';
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
          'experience': 0,
          'totalPoints': 0,
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
      // isFirstLogin = progress.language.isEmpty;
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

  void completeOnboarding(String language) {
    //progress.language = language;
    //isFirstLogin = false;
    notifyListeners();
  }

  Future<List<Mission>> getMissions() async {
    try {
      final response = await database.listRows(
          databaseId: "6972adad002e2ba515f2", tableId: "missions");

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
          isCompleted: doc.data['isCompleted'],
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
        badgesProgress:
            jsonDecode(row.data["badgesProgress"]), //replaced by the database,
        showingBadges: [],
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
      if (progress.badgesProgress['debug']! >= 2) {
        if (!progress.earnedBadges.contains('Bug Hunter') &&
            !progress.earnedBadges.contains('Code Ninja')) {
          progress.earnedBadges.add('Bug Hunter');
          returnedBagdes.add('Bug Hunter');
          progress.earnedBadges.add('Code Ninja');
          returnedBagdes.add('Code Ninja');
          progress.showingBadges.add('Code Ninja');
          progress.showingBadges.add('Bug Hunter');
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
      //missing database
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
   // print(progress.showingBadges);
    progress.showingBadges = [];
    notifyListeners();
   // print(progress.showingBadges);
  }

  void updateXp(int newXp) {
    progress.experience += newXp;
    notifyListeners();
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
