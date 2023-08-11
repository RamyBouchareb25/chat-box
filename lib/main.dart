import 'package:chat_app/models/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widget_tree.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("onBackgroundMessage: ${message.data}");
  }
}

Future<void> showNotification(RemoteMessage message) async {
  const NotificationDetails notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'channel_id',
      'Channel name',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    ),
  );
}

Future<void> initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging message = FirebaseMessaging.instance;
  String? token = await message.getToken();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print("Message received: ${message.data}");
    }
    showNotification(message);

    // Implement your own logic to update the UI with the new message
  });
  NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      sound: true);

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  BehaviorSubject<RemoteMessage> tokenStream = BehaviorSubject<RemoteMessage>();
  FirebaseMessaging.onMessage.listen((event) {
    if (kDebugMode) {
      print("onMessage: ${event.data}");
    }
    tokenStream.add(event);
    tokenStream.sink.add(event);
  });

  runApp(MyApp(
    token: token,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.token});
  final String? token;
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("token : \n${token!}");
    }
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        title: 'Chat Box',
        theme: ThemeData(
          fontFamily: "circular",
          appBarTheme: const AppBarTheme(
            backgroundColor: black,
            elevation: 0,
            centerTitle: true,
          ),
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            elevation: 0,
            centerTitle: true,
          ),
          brightness: Brightness.dark,
        ),
        home: const WidgetTree());
  }
}
