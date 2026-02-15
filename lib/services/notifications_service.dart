import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService {
  final notifPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized {
    return _isInitialized;
  }

  Future<void> initNotification() async {
    if (isInitialized) return;
    const intiSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: intiSettings);
    await notifPlugin.initialize(settings: initSettings);
    notifPlugin.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails( "channelId", "channelName",
            importance: Importance.max, priority: Priority.high));
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body}) async {
    return notifPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails:  notificationDetails());
  }
}
