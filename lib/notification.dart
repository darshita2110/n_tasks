import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ShowLocalNotification {
  //initialization
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void showNotificaton(String title, String body) async {
    var android = AndroidNotificationDetails('channel id', 'channel NAME',
        priority: Priority.high, importance: Importance.max);
    var platform = NotificationDetails(
      android: android,
    );
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: 'Welcome to the Local Notification demo ');
  }

}