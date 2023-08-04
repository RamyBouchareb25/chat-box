import 'package:chat_app/models/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/global.dart';

class Conversation extends StatelessWidget {
  const Conversation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: black,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Name LastName",
                  style: TextStyle(color: black),
                ),
                Text(
                  "Active Now",
                  style: TextStyle(color: grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icomoon.Call,
              color: black,
              size: 20,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icomoon.Video,
              color: black,
              size: 15,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text("Conversation"),
      ),
    );
  }
}
