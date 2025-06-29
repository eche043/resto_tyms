import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:odrive_restaurant/main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Stream<String>? _tokenStream;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
  await Firebase.initializeApp();
}

Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'head_up_notification', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void _showNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'head_up_notification',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          icon: android.smallIcon,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

void _setToken(String? token) {
  if (token == null) return;
  print('FCM Token: $token');
  account.setFcbToken(token);
}

firebaseInitApp(BuildContext context) async {
  print("firebaseInitApp");

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null && message.notification != null) {
      print("FCB message _notifyCallback=;_notifyCallback ${message.from}");
      print("object");
      account.addNotify();

      _showNotification(message);
    }
  });

  _firebaseGetToken(context);
}

_firebaseGetToken(BuildContext context) async {
  print("Firebase messaging: _getToken");

  // iOS
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Update the iOS foreground notification presentation options to allow
  // heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  print("tokkenn________-fcm");
  print(await FirebaseMessaging.instance.getToken());

  _setToken(await FirebaseMessaging.instance.getToken());
  _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
  _tokenStream!.listen(_setToken);

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification == null) return;
    if (_lastMessageId != null) if (_lastMessageId == message.messageId) return;
    _lastMessageId = message.messageId;
    print("FirebaseMessaging.onMessageOpenedApp $message ${message.from}");
    account.addNotify();
    _showNotification(message);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("FirebaseMessaging.onMessage ${message.messageId}");
    print("${message.data['chat']}");
    if (_lastMessageId != null) if (_lastMessageId == message.messageId) return;
    _lastMessageId = message.messageId;
    account.addNotify();
    _showNotification(message);
  });

  await _createNotificationChannel();
}

String? _lastMessageId;
