import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/auth.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final User? user = Auth().currentUser;
  Future<void> _signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Welcome ${user?.email}"),
          ),
          ElevatedButton(
            onPressed: _signOut,
            child: const Text("Sign Out"),
          )
        ],
      ),
    );
  }
}
