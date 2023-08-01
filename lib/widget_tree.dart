import 'package:chat_app/Pages/start_here.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/Pages/home_page.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return Home();
          } else {
            return const Start();
          }
        } else {
          return Scaffold(
            body: Center(
              child: Image.asset("Assets/Logo.png"),
            ),
          );
        }
      },
    );
  }
}
