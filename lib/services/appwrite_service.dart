import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import '../models/mission_model.dart';

class AppwriteService extends ChangeNotifier {
  Client client = Client();
  late Account account;
  late Databases databases;

  models.User? _user;
  models.User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      _user = await account.get();
      notifyListeners();
    } catch (e) {
      _user = null;
      notifyListeners();
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

  Future<List<Mission>> getMissions() async {
    try {
      // TODO: a3mel talla 3la documentation mte3 appwrite
      //https://appwrite.io/docs/products/databases/quick-start
      final response = await databases.listDocuments(
        databaseId: '6972adad002e2ba515f2',
        collectionId: 'missions',
      );

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
          solution: doc.data['solution'],
          isCompleted: doc.data['isCompleted'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint("Error fetching missions: $e");
      return [
        Mission(
            id: "5",
            title: "Fer8a",
            description: "Aloo Aloo",
            type: MissionType.debug,
            points: 200,
            difficulty: 5,
            initialCode: "aaa",
            solution: "adzad")
      ]; // TODO : rajja3 lista fer8a or handle error
    }
  }
}
