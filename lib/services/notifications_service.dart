import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService extends ChangeNotifier {
  final notifPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized {
    return _isInitialized;
  }

  NotificationsService() {
    initNotification();
  }
  Future<void> initNotification() async {
    if (isInitialized) return;
    const intiSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: intiSettings);
    await notifPlugin.initialize(settings: initSettings);
    notifPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails("channelId", "channelName",
            importance: Importance.max, priority: Priority.high));
  }

  Future<void> showNotification(
      {int id = 0, required String title, required String body}) async {
    return notifPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails());
  }

  Future<void> cancelNotif() {
    return notifPlugin.cancel(id: 0);
  }
}
