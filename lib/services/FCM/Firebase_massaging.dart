import 'package:appwrite/appwrite.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pfe_test/services/appwrite_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMassaging {
  final AppwriteService appwriteService;

  FirebaseMassaging({required this.appwriteService});

  Future<void> registerNotificationDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('fcmToken');

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();

    if (fcmToken != null && fcmToken != storedToken) {
      try {
        await appwriteService.account.createPushTarget(
          targetId: ID.unique(),
          identifier: fcmToken,
          providerId: '699bf106002c3fc1716f',
        );
        await prefs.setString('fcmToken', fcmToken);
        // ignore: empty_catches
      } catch (e) {
        debugPrint("error fi register nooootiiif $e ");
      }
    }
  }
}
