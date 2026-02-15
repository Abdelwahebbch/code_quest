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
        "name": userInfo!.username,
        "level": userInfo!.userLevel,
        "programming_language": userInfo!.progLanguage,
        "topic": mission!.title
      },
      "mission": {
        "title": mission!.title,
        "description": mission!.description,
        "type": mission!.type.name,
        "initial_code": mission!.initialCode,
      },
      "student_code_attempt": mission!.solution,
      "student_question": message
    });
  }

  Map<String, String> userMessagetoJson() {
    return {
      'role': role,
      'content': message,
    };
  }
}
