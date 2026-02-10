import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pfe_test/models/message_model.dart';

class AppwritecloudfunctionsService extends ChangeNotifier {
  Future<Map<String, dynamic>> sendMessage(Message message) async {
    final res = await http.post(
        Uri.parse('https://698a84430024b427a4a4.fra.appwrite.run/'),
        body: message.finalMessage);

    try  {
      final Map<String, dynamic> data = jsonDecode(res.body);
      print(data['response']);
      print(res.statusCode);
      return data;
    } catch(e) {
      print(res.body);
      throw Exception("Failed to load data");
    }
  }
}
