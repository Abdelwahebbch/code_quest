import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_progress_model.dart';
import '../models/mission_model.dart';

class AppwriteService extends ChangeNotifier {
  Client client = Client();
  late Account account;
  late TablesDB database;

  models.User? _user;
  models.User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  // ignore: unused_field
  final bool isFirstLogin = false;

  late UserProgress progress;

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
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      _user = await account.get();
      await getUserProgress();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
    }
  }

  Future<void> createNewRow() async {
    try {
      models.User user = await account.get();
      await database.createRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: 'user_profiles',
        rowId: user.$id,
        data: {
          'experience': 0,
          'level': 1,
          'totalPoints': 0,
          'progLanguage': 'Java',
          'earnedBadges': [],
          'bio': "",
          'imagePath': "",
        },
        permissions: [
          Permission.read(Role.user(user.$id)),
          Permission.update(Role.user(user.$id)),
        ],
      );
    } catch (e) {
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
      await login(email, password);
      await createNewRow();
      await getUserProgress();
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
      await getUserProgress();
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
          isCompleted: doc.data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching missions: $e");
      rethrow;
    }
  }

  Future<void> getUserProgress() async {
    try {
      models.User user = await account.get();
      final row = await database.getRow(
          databaseId: "6972adad002e2ba515f2",
          tableId: "user_profiles",
          rowId: user.$id);

      progress = UserProgress(
        progLanguage: row.data["progLanguage"],
        username: _user!.name,
        level: row.data["level"],
        experience: row.data["experience"],
        totalPoints: row.data["totalPoints"],
        earnedBadges: List<String>.from(row.data["earnedBadges"] ?? []),
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Aloo Alooo Error $e");
      rethrow;
    }
  }
}
