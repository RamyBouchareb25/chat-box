import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(title: "Settings", context: context,controller: TextEditingController(),),
      body: const Center(
        child: Text("Settings"),
      ),
      bottomNavigationBar: bottomNavBar(context: context, selectedPage: 3),
    );
  }
}
