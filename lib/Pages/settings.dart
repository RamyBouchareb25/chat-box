import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Settings", context: context),
      body: const Center(
        child: Text("Settings"),
      ),
      bottomNavigationBar: bottomNavBar(context: context, selectedPage: 3),
    );
  }
}
