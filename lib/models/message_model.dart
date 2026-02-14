import 'dart:convert';

import 'package:pfe_test/models/mission_model.dart';
import 'package:pfe_test/models/user_info_model.dart';

class Message {
  String role;
  String message;

  Mission? mission;
  UserInfo? userInfo;

  Message(
      {required this.role, this.userInfo, required this.message, this.mission});

  String get finalMessage {
    return jsonEncode({
      "student_profile": {
        "level": userInfo!.userLevel , 
        "programming_language": userInfo!.progLanguage,
        "topic": mission!.title
      },
      "mission": {
        "title": mission!.title,
        "description": mission!.description,
        "type": mission!.type.name
      },
      "code": "public class UserService {...}",
      "observed_behavior": {
        "error_message": "NullPointerException at line 12",
        "unexpected_output": "Program crashes",
        "expected_output": "Print user name"
      },
      "student_attempt": "I think the constructor is correct but I'm not sure."
    });
  }

  Map<String, String> userMessagetoJson() {
    return {
      'role': role,
      'content': message,
    };
  }
}
