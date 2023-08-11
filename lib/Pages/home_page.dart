import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? user = Auth().currentUser;
  final firestore = FirebaseFirestore.instance;
  List<UserModel> users = [];
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
              StreamBuilder(
                  stream: firestore
                      .collection("Rooms")
                      .where("users", arrayContains: user!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 150,
                        decoration: const BoxDecoration(
                          color: black, // Change the color as desired
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data!.size + 1,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          index == 0 ? "My Status" : "User",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: black,
                          backgroundColor: Colors.white,
                        ),
                      );
                    }
                  }),
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
                child: StreamBuilder(
                    stream: firestore
                        .collection("Rooms")
                        .where("users", arrayContains: user!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          return CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: snapshot.data!.size,
                                      (context, index) {
                                firestore
                                    .collection("Users")
                                    .get()
                                    .then((value) {
                                  for (var element in value.docs) {
                                    if ((element.data()["UserId"] ==
                                                snapshot.data!.docs[index]
                                                    .data()["users"][0] ||
                                            element.data()["UserId"] ==
                                                snapshot.data!.docs[index]
                                                    .data()["users"][1]) &&
                                        element.data()["UserId"] != user!.uid) {
                                      setState(() {
                                        UserModel user =
                                            UserModel.fromMap(element.data());
                                        users.add(user);
                                      });
                                    }
                                  }
                                });
                                return StreamBuilder(
                                    stream: firestore
                                        .collection("Rooms")
                                        .doc(snapshot.data!.docs[index].id)
                                        .collection("messages")
                                        .orderBy("timestamp")
                                        .snapshots(),
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        MessageData lastMessage =
                                            MessageData.fromMap(snap
                                                .data!.docs[snap.data!.size - 1]
                                                .data());
                                        List<MessageData> lastMessages = [];
                                        for (var element in snap.data!.docs) {
                                          if (element.data()["isRead"] ==
                                              false) {
                                            var msg = MessageData.fromMap(
                                                element.data());
                                            msg.id = element.id;
                                            lastMessages.add(msg);
                                          }
                                        }
                                        return Container(
                                          color: Colors.white,
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16.0),
                                              child: ListTile(
                                                onTap: () {
                                                  if (users.length > index) {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      return Conversation(
                                                        lastMessages:
                                                            lastMessages.isEmpty
                                                                ? <MessageData>[]
                                                                : lastMessages,
                                                        user: users[index],
                                                        roomId: snapshot.data!
                                                            .docs[index].id,
                                                      );
                                                    }));
                                                  }
                                                },
                                                leading: const CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.black,
                                                ),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        users.length > index
                                                            ? users[index].name!
                                                            : "User",
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                        timeago.format(DateTime
                                                            .parse(lastMessage
                                                                .timestamp!)),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.grey)),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      lastMessage.senderId ==
                                                              user!.uid
                                                          ? "You: ${lastMessage.message!}"
                                                          : lastMessage
                                                                  .message ??
                                                              "No Messages Yet",
                                                      style: TextStyle(
                                                          color: lastMessage
                                                                          .senderId ==
                                                                      user!
                                                                          .uid ||
                                                                  lastMessage
                                                                      .isRead!
                                                              ? Colors.grey
                                                              : black,
                                                          fontSize: 15),
                                                    ),
                                                    lastMessages.isNotEmpty &&
                                                            lastMessage
                                                                    .senderId !=
                                                                user!.uid
                                                        ? Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    Colors.red,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100)),
                                                            child: Center(
                                                              child: Text(
                                                                lastMessages
                                                                    .length
                                                                    .toString(),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                                  ],
                                                ),
                                              )),
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            backgroundColor: Colors.white,
                                          ),
                                        );
                                      }
                                    });
                              })),
                              SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Container(
                                    color: Colors.white,
                                  ))
                            ],
                          );
                        } else {
                          return const Center(
                              child:
                                  Text("You have No conversations for now X)"));
                        }
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("An Error Occured X("),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                            backgroundColor: Colors.white,
                          ),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavBar(context: context, selectedPage: 0));
  }
}
