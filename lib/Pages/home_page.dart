import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/icomoon_icons.dart';
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
        resizeToAvoidBottomInset: true,
        backgroundColor: black,
        appBar: DefaultAppBar(
          title: "Home",
          context: context,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  color: black, // Change the color as desired
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                Text(
                                  index == 0 ? "My Status" : "User",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.0, // Adjust the height as needed
                decoration: const BoxDecoration(
                  color: Colors.white, // Change the color as desired
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, left: 25),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 100,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Colors.grey[350],
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey[350]!, width: 1)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      childCount: 10,
                      (context, index) => Container(
                        color: Colors
                            .white, // Change the color of the body as desired
                        // Your body content here
                        // Example:
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return const Conversation(
                                    roomId: "LzlmxIZwsO8t81npS1qs",
                                  );
                                }));
                              },
                              leading: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.black,
                              ),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text("Name",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text("2 min ago",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Message",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(100)),
                                    child: const Center(
                                      child: Text(
                                        "3",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ))
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey,
          iconSize: 20,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icomoon.Chats3),
              label: "Chats",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icomoon.Calls),
              label: "Calls",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icomoon.User),
              label: "People",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icomoon.Settings),
              label: "Settings",
            ),
          ],
        ));
  }
}
