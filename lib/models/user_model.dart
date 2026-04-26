
import 'package:appwrite/models.dart';

class UserModel {
  final String id;
  final String email;
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserModel.fromAppwriteUser(User user) {
    return UserModel(
      id: user.$id,
      email: user.email,
      name: user.name,
    );
  }
}
