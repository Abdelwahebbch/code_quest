import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pfe_test/models/message_model.dart';
import 'package:pfe_test/models/user_info_model.dart';

import '../models/mission_model.dart';

class AppwritecloudfunctionsService extends ChangeNotifier {
  Future<Map<String, dynamic>> sendMessage(Message message) async {
    final res = await http.post(
        Uri.parse('https://698a84430024b427a4a4.fra.appwrite.run/'),
        body: message.finalMessage);

    try {
      final Map<String, dynamic> data = jsonDecode(res.body);

      return data;
    } catch (e) {
      throw Exception("Failed to load data");
    }
  }

  Future<void> createCustomMissions() async {
    try {
      final res = await http
          .get(Uri.parse('https://6995ccc5002bc1b94906.fra.appwrite.run/'));
      debugPrint(res.body);
    } catch (e) {
      debugPrint("Error when create custom missions");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkAnwser(
      UserInfo user, Mission mission, String solution) async {
    final res = await http.post(
        Uri.parse('https://699266030015f5f27806.fra.appwrite.run/'),
        body: jsonEncode({
          "name": user.username,
          "student_profile": {
            "level": user.userLevel,
            "programming_language": user.progLanguage
          },
          "mission": {
            "title": mission.title,
            "description": mission.description,
            "type": mission.type.name,
            "initial_code": mission.initialCode,
            "failed_time": mission.nbFailed,
          },
          "topic": mission.title,
          "student_code_attempt": solution
        }));
    try {
      final Map<String, dynamic> data = {};
      var outPut = jsonDecode(res.body);
      var response = outPut["response"];
      debugPrint(response);
      if (response.startsWith("```json")) {
        response = response.substring("```json".length);
      }
      if (response.endsWith("```")) {
        response = response.substring(0, response.length - "```".length);
      }
      var realResponse = jsonDecode(response);
      data.addAll({
        "result": realResponse["result"],
        "success": realResponse["success"]
      });

      return data;
    } catch (e) {
      throw Exception(e);
    }
  }
}
