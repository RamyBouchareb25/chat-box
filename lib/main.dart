import 'package:chat_app/models/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
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
