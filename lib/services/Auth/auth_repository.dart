import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:pfe_test/services/appwrite_service.dart';

class AuthRepository {
  final AppwriteService appwriteService;

  AuthRepository({required this.appwriteService});

  Future<User?> get currentUser => _getCurrentUser();

  Future<User?> _getCurrentUser() async {
    try {
      return await appwriteService.account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null;
      }
      rethrow;
    } catch (e){
      print(e); 
      rethrow;
    }
  }

  Future<void> continueWithGoogle(
    ) async {
    try {
       await appwriteService.account
          .createOAuth2Session(provider: OAuthProvider.google);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> signUp(
      {required String email,
      required String password,
      required String name}) async {
    try {
      await appwriteService.account.create(
        name: name,
        userId: ID.unique(),
        email: email,
        password: password,
      );
      return await signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      await appwriteService.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return await appwriteService.account.get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await appwriteService.account.deleteSession(sessionId: 'current');
    } catch (e) {
      rethrow;
    }
  }
}
