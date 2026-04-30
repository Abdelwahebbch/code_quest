import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:pfe_test/models/user_model.dart';
import 'package:pfe_test/services/Auth/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository authRepository;
  UserModel? _currentUser;
  bool _isLoading = false;

  AuthProvider({required this.authRepository});

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    try {
    _isLoading = true;
    notifyListeners();
      User? user = await authRepository.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromAppwriteUser(user);
      }
    } catch (e) {
      print('Error initializing AuthProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
    _isLoading = true;
    notifyListeners();
      User user = await authRepository.signUp(
          email: email, password: password, name: name);
      _currentUser = UserModel.fromAppwriteUser(user);
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();
      // account.deleteSession(sessionId: 'current');
      await authRepository.continueWithGoogle();
      User user = await authRepository.appwriteService.account.get();
      _currentUser = UserModel.fromAppwriteUser(user);
      // try {
      //   //await createNewRow();
      // } on AppwriteException catch (e) {
      //   if (e.code == 409) {
      //     print("User row already exists. Skipping creation.");
      //   } else {
      //     rethrow;
      //   }
      // }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print("Appwrite Auth Error: ${e}");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    // await authRepository.appwriteService.account.deleteSession(sessionId: 'current');
    try {
    _isLoading = true;
    notifyListeners();
      User user = await authRepository.signIn(email: email, password: password);
      _currentUser = UserModel.fromAppwriteUser(user);
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await authRepository.signOut();
      _currentUser = null;
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
