import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final User? user = Auth().currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final int messageMaxLength = 18;

  FirebaseStorage storage = FirebaseStorage.instance;
  List<UserModel> users = [];
  List<String> urls = [];
  Future<QuerySnapshot<Map<String, dynamic>>> _getRooms() async {
    return await firestore
        .collection("Rooms")
        .orderBy("LastMsgTime", descending: true)
        .where("users", arrayContains: user!.uid)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _getMessages(
      {required dynamic docId, required bool isEmpty}) {
    return isEmpty
        ? const Stream.empty()
        : firestore
            .collection("Rooms")
            .doc(docId)
            .collection("messages")
            .orderBy("timestamp")
            .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getUsers() async {
    return await firestore.collection("Users").get();
  }

  final RefreshController _controller = RefreshController();
  bool firstTimeLoading = true;
  Future<void> _onRefresh() async {
    var value = await _getUsers();
    var snapshot = await _getRooms();
    setState(() {
      users = [];
      for (var index = 0; index < snapshot.docs.length; index++) {
        for (var aUser in value.docs) {
          UserModel userNow = UserModel.fromMap(aUser.data());
          if ((userNow.uid == snapshot.docs[index].data()["users"][0] ||
                  aUser.data()["UserId"] ==
                      snapshot.docs[index].data()["users"][1]) &&
              userNow.uid != user!.uid) {
            users.add(userNow);
          }
        }
      }
    });
    if (!firstTimeLoading && context.mounted) {
      lastMessages = [];
    }
    firstTimeLoading = false;

    _controller.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await _getRooms();
    _controller.loadComplete();
  }

  MessageData? lastMessage;
  List<MessageData> lastMessages = [];
  @override
  void initState() {
    _getUsers().then((value) {
      _getRooms().then((snapshot) {
        for (var index = 0; index < snapshot.docs.length; index++) {
          for (var aUser in value.docs) {
            UserModel userNow = UserModel.fromMap(aUser.data());
            if ((userNow.uid == snapshot.docs[index].data()["users"][0] ||
                    aUser.data()["UserId"] ==
                        snapshot.docs[index].data()["users"][1]) &&
                userNow.uid != user!.uid) {
              users.add(userNow);
            }
          }
        }
      });
      _onRefresh();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // firestore.collection("Rooms").get().then((value) {
    //   for (var element in value.docs) {
    //     firestore
    //         .collection("Rooms")
    //         .doc(element.id)
    //         .collection("messages")
    //         .orderBy("timestamp", descending: true)
    //         .get()
    //         .then((value) {
    //       if (value.docs.isNotEmpty) {
    //         var e = value.docs[0];
    //         firestore
    //             .collection("Rooms")
    //             .doc(e['id'])
    //             .update({"LastMsgTime": e.data()["timestamp"]});
    //       }
    //     });
    //   }
    // });
    // Auth().currentUser!.updatePhotoURL(
    //     "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Profile%20Photos%2Fmejpg.jpg?alt=media&token=20625eb2-e272-49b8-bcec-c7e762e4a786");
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: black,
        appBar: DefaultAppBar(
          controller: TextEditingController(),
          title: "Home",
          context: context,
          image: NetworkImage(user!.photoURL ??
              "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577"),
        ),
        body: SafeArea(
          top: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                  future: _getRooms(),
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
                                itemBuilder: (context, i) {
                                  var index = i - 1;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 25),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.white,
                                            backgroundImage: i == 0
                                                ? NetworkImage(user!.photoURL!)
                                                : users.length > index
                                                    ? NetworkImage(users[index]
                                                                .profilePhoto !=
                                                            ""
                                                        ? users[index]
                                                            .profilePhoto!
                                                        : "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577")
                                                    : const AssetImage(
                                                            "Assets/Profile-Dark.png")
                                                        as ImageProvider,
                                          ),
                                        ),
                                        Text(
                                          i == 0
                                              ? "My Status"
                                              : users.length > index
                                                  ? users[index].name!
                                                  : "User",
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
                child: FutureBuilder(
                    future: _getRooms(),
                    builder: (context, snapshot) {
                      // _onRefresh();
                      // if (snapshot.hasData) {
                      var finishLoading2 = snapshot.hasData;
                      if (!finishLoading2 || snapshot.data!.docs.isNotEmpty) {
                        return SmartRefresher(
                          enablePullUp: false,
                          enablePullDown: true,
                          controller: _controller,
                          onLoading: _onLoading,
                          onRefresh: _onRefresh,
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: finishLoading2
                                          ? snapshot.data!.size
                                          : 5, (context, index) {
                                return StreamBuilder(
                                    stream: _getMessages(
                                        docId: finishLoading2
                                            ? snapshot.data!.docs[index].id
                                            : null,
                                        isEmpty: !finishLoading2),
                                    builder: (context, snap) {
                                      var finishLoading = snap.hasData;

                                      if (finishLoading && finishLoading2) {
                                        lastMessage = snap.data!.size == 0
                                            ? MessageData()
                                            : MessageData.fromMap(snap
                                                .data!.docs[snap.data!.size - 1]
                                                .data());
                                        for (var element in snap.data!.docs) {
                                          var msg = MessageData.fromMap(
                                              element.data());
                                          if (msg.isRead == false) {
                                            var addOrNot = lastMessages.every(
                                                (element) =>
                                                    element.id != msg.id);
                                            addOrNot
                                                ? lastMessages.add(msg)
                                                : null;
                                          }
                                        }
                                      }
                                      lastMessages
                                          .map((e) =>
                                              e.senderId == users[index].uid)
                                          .length;
                                      return Container(
                                        color: Colors.white,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: ListTile(
                                              onTap: () {
                                                if (finishLoading) {
                                                  if (users.length > index) {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                      var unReadMessages =
                                                          <MessageData>[];
                                                      for (var element
                                                          in lastMessages) {
                                                        element.senderId ==
                                                                    users[index]
                                                                        .uid &&
                                                                element.receiverId ==
                                                                    Auth()
                                                                        .currentUser!
                                                                        .uid
                                                            ? unReadMessages
                                                                .add(element)
                                                            : null;
                                                      }
                                                      return Conversation(
                                                        lastMessages:
                                                            unReadMessages
                                                                    .isEmpty
                                                                ? <MessageData>[]
                                                                : unReadMessages,
                                                        user: users[index],
                                                        roomId: snapshot.data!
                                                            .docs[index].id,
                                                      );
                                                    }));
                                                  }
                                                }
                                              },
                                              leading: finishLoading
                                                  ? CircleAvatar(
                                                      radius: 30,
                                                      backgroundImage: users
                                                              .isNotEmpty
                                                          ? NetworkImage(users[
                                                                          index]
                                                                      .profilePhoto !=
                                                                  ""
                                                              ? users[index]
                                                                  .profilePhoto!
                                                              : "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577")
                                                          : null,
                                                      backgroundColor:
                                                          Colors.white,
                                                    )
                                                  : Shimmer.fromColors(
                                                      baseColor: Colors.grey,
                                                      highlightColor: black,
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50)),
                                                            color:
                                                                Colors.white),
                                                      )),
                                              title: finishLoading
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            users.length > index
                                                                ? users[index]
                                                                    .name!
                                                                : "User",
                                                            style: const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            lastMessage!.id ==
                                                                    null
                                                                ? "No Messages Yet"
                                                                : timeago.format(
                                                                    DateTime.parse(
                                                                        lastMessage!
                                                                            .timestamp!)),
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .grey)),
                                                      ],
                                                    )
                                                  : Shimmer.fromColors(
                                                      baseColor: Colors.grey,
                                                      highlightColor: black,
                                                      child: Container(
                                                        height: 50,
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            25)),
                                                            color:
                                                                Colors.white),
                                                      )),
                                              subtitle: finishLoading
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          lastMessage!.senderId ==
                                                                  null
                                                              ? "No Messages Yet"
                                                              : lastMessage!
                                                                          .senderId ==
                                                                      user!.uid
                                                                  ? "You: ${lastMessage!.message!.substring(0, lastMessage!.message!.length < messageMaxLength ? lastMessage!.message!.length : messageMaxLength)} ${lastMessage!.message!.length > messageMaxLength ? "..." : ""}"
                                                                  : lastMessage!
                                                                              .message ==
                                                                          null
                                                                      ? "No Messages Yet"
                                                                      : "${lastMessage!.message!.substring(0, lastMessage!.message!.length < messageMaxLength ? lastMessage!.message!.length : messageMaxLength)} ${lastMessage!.message!.length > messageMaxLength ? "..." : ""}",
                                                          style: TextStyle(
                                                              color: lastMessage!
                                                                              .id ==
                                                                          null ||
                                                                      lastMessage!
                                                                              .senderId ==
                                                                          user!
                                                                              .uid ||
                                                                      lastMessage!
                                                                          .isRead!
                                                                  ? Colors.grey
                                                                  : black,
                                                              fontSize: 15),
                                                        ),
                                                        lastMessages.isNotEmpty &&
                                                                lastMessage!
                                                                        .id !=
                                                                    null &&
                                                                lastMessage!
                                                                        .senderId !=
                                                                    user!.uid
                                                            ? Container(
                                                                width: 20,
                                                                height: 20,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .red,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100)),
                                                                child: Center(
                                                                  child: Text(
                                                                    lastMessages
                                                                        .map((e) =>
                                                                            e.senderId ==
                                                                            users[index].uid)
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
                                                    )
                                                  : Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      child: Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey,
                                                          highlightColor: black,
                                                          child: Container(
                                                            height: 50,
                                                            decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            25)),
                                                                color: Colors
                                                                    .white),
                                                          )),
                                                    ),
                                            )),
                                      );
                                    });
                              })),
                              SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: Container(
                                    color: Colors.white,
                                  ))
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          color: Colors.white,
                          child: const Center(
                              child:
                                  Text("You have No conversations for now X)")),
                        );
                      }

                      // } else {
                      //   return Center(
                      //     child: SizedBox(
                      //       height: MediaQuery.of(context).size.height,
                      //       width: MediaQuery.of(context).size.width,
                      //     ),
                      //   );
                      // }
                    }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavBar(context: context, selectedPage: 0));
  }
}
