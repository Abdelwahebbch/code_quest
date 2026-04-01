import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pfe_test/models/message_model.dart';
import 'package:pfe_test/models/party_model.dart';
import 'package:pfe_test/models/resolve_user_profile.dart';
import 'package:pfe_test/models/user_info_model.dart';

import '../models/mission_model.dart';

class AppwritecloudfunctionsService extends ChangeNotifier {
  static Future<Map<String, dynamic>> sendMessage(Message message) async {
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

  static Future<void> createCustomMissions() async {
    try {
      final res = await http
          .get(Uri.parse('https://6995ccc5002bc1b94906.fra.appwrite.run/'));
      debugPrint(res.body);
    } catch (e) {
      debugPrint("Error when create custom missions");
      rethrow;
    }
  }

  static Future<void> createLearningPath(
      ResolvedProfile profile, String userId) async {
    try {
      final res = await http.post(
          Uri.parse('https://69c8037600042b81ce1b.fra.appwrite.run/'),
          body: jsonEncode({
            "userId": userId,
            "profile": {
              "Topic": profile.language,
              "currentLevel": profile.currentLevel,
              "milestoneCount": profile.milestoneCount,
              "conceptsPerMilestone": profile.conceptsPerMilestone,
              "focusArea": profile.focusArea,
              "commitment": profile.commitment,
            }
          }));
      debugPrint(res.body);
    } catch (e) {
      debugPrint("Error when create learning path $e");
      rethrow;
    }
  }

  // static Future<void> loadLearningPath() {
  //   try {} catch (e) {}
  // }

  static Future<List<dynamic>> checkAnwser(
      UserInfo user, Mission mission, String solution) async {
    try {
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

      List<dynamic> data = [];
      final Map<String, dynamic> decoded = jsonDecode(res.body);
      final String responseString = decoded["response"];
      data = jsonDecode(responseString);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> requestForPartyQuizzes(Party p, String difficulty) async {
    try {
      final res = await http.post(
          Uri.parse('https://69b606670033bd00ed26.fra.appwrite.run/'),
          body: jsonEncode({
            "difficulty": difficulty,
            "party_id": p.partyId,
            "nb_rounds": p.totalRounds
          }));

      // List<dynamic> data = [];
      final Map<String, dynamic> decoded = jsonDecode(res.body);
      //final String responseString = decoded["response"];
      //data = jsonDecode(responseString);
      print(decoded);

      //return data;
    } catch (e) {
      print("Error");
      rethrow;
    }
  }
}
