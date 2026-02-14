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
      "Name": userInfo?.username,
      "Level": userInfo?.userLevel,
      "number_of_solved_missions": userInfo?.nbMissions,
      "programming_language": userInfo?.progLanguage,
      "Mission_Title": mission?.title,
      "Mission_description": mission?.description,
      "Mission_type": "debug",
      "Mission_initialCode": mission?.initialCode,
      "Mission_options": mission?.options,
      "question": message
    });
  }

  Map<String, String> userMessagetoJson() {
    return {
      'role': role,
      'content': message,
    };
  }
}
