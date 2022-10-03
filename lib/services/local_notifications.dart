import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sates/main_pages/chats_screen.dart';

void onSelectNotification(String payload) async {

    print(payload);
}
class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initilize() async{
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"));
   await  _notificationsPlugin.initialize(initializationSettings,
       onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {

         Chats_screen();
       },);
  }

  static void showNotificationOnForeground(RemoteMessage message) {
    final notificationDetail = NotificationDetails(
        android: AndroidNotificationDetails(
            "com.example.sates",
            "firebase_push_notification",
            importance: Importance.max,
            priority: Priority.high));

    _notificationsPlugin.show(
        DateTime.now().microsecond,
        message.notification!.title,
        message.notification!.body,
        notificationDetail,
        payload: message.data["message"]);
  }
}
