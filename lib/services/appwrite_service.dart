import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:pfe_test/models/user_progress_model.dart';
import '../models/mission_model.dart';

class AppwriteService extends ChangeNotifier {
  Client client = Client();
  late Account account;
  late Databases databases;

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
    databases = Databases(client);
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
      await databases.createDocument(
        databaseId: '6972adad002e2ba515f2',
        collectionId: 'user_profiles',
        documentId: ID.unique(),
        data: {
          'experience': 0,
          'level': 1,
          'totalPoints': 0,
          'progLanguage': 'Java',
          'earnedBadges': [],
          'userId': user.$id,
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

  Future<List<String>> getBadges() async {
    try {
      final response = await databases.listDocuments(
        databaseId: "6972adad002e2ba515f2",
        collectionId: "user_profiles",
        queries: [
          //TODO : baddlha bel RLS man8ir ma tab9a ta3mel fi select bech kol user tjih automatiquement el row mte3ou 5ater hakka bech twalli ta3mel id el user fkey fi el user_profile w tt3attel akther
          //TODO : ken nbaddlouha el fonction he4i twalli tloadi el ROW el kol fi marra wa7da 5ater bech tloadi el b9iyya zeda fi fonction wa7da o5ra ywalli barcha
          Query.equal('userId', _user?.$id),
        ],
      );
      if (response.documents[0].data["earnedBadges"] != null) {
        return List<String>.from(response.documents[0].data["earnedBadges"]);
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Mission>> getMissions() async {
    try {
      final response = await databases.listDocuments(
          databaseId: "6972adad002e2ba515f2", collectionId: "missions");

      return response.documents.map((doc) {
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
      final response = await databases.listDocuments(
        databaseId: "6972adad002e2ba515f2",
        collectionId: "user_profiles",
        queries: [
          Query.equal('userId', user.$id),
        ],
      );

      if (response.documents.isNotEmpty) {
        final doc = response.documents.first;

        progress = UserProgress(
          progLanguage: doc.data["progLanguage"],
          username: _user!.name,
          level: doc.data["level"],
          experience: doc.data["experience"],
          totalPoints: doc.data["totalPoints"],
          earnedBadges: List<String>.from(doc.data["earnedBadges"] ?? []),
        );

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Aloo Alooo Error $e");
      rethrow;
    }
  }
}
