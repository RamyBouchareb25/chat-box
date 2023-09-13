import 'package:chat_app/Classes/custom_page_route.dart';
import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/Pages/profile.dart';
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
  bool isDisposed = false;
  FirebaseStorage storage = FirebaseStorage.instance;
  List<UserModel> users = [];
  List<String> urls = [];
  List<int> lastMessagesLength = List.generate(100, (index) => 0);
  Future<QuerySnapshot<Map<String, dynamic>>> _getRooms() async {
    return await firestore
        .collection("Rooms")
        .orderBy("LastMsgTime", descending: true)
        .where("users", arrayContains: user!.uid)
        .get();
  }

  Future<void> constantRefresh() async {
    await _onRefresh();
    await Future.delayed(const Duration(seconds: 1));
    if (!isDisposed) {
      constantRefresh();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
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
    Auth.setuser();
    var value = await _getUsers();
    var snapshot = await _getRooms();
    if (!isDisposed && context.mounted) {
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
    }
    if (!isDisposed && !firstTimeLoading && context.mounted) {
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
    constantRefresh();
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
          heroTag: true,
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
                                          child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                        CustomPageRoute(
                                                            child:
                                                                const Profile(),
                                                            axis: AxisDirection
                                                                .right));
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 30,
                                                    backgroundColor:
                                                        Colors.white,
                                                    backgroundImage: i == 0
                                                        ? NetworkImage(
                                                            user!.photoURL!)
                                                        : users.length > index
                                                            ? NetworkImage(users[
                                                                            index]
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
                                                Positioned(
                                                  bottom: 10,
                                                  right: 0,
                                                  child: i != 0
                                                      ? Container(
                                                          height: 15,
                                                          width: 15,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: users.length <=
                                                                    index
                                                                ? Colors.grey
                                                                : users[index]
                                                                            .status ==
                                                                        "online"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                          ),
                                                        )
                                                      : Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: const Icon(
                                                            Icons.add,
                                                            size: 15,
                                                          )),
                                                )
                                              ]),
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
                                        var thisLastMessages = <MessageData>[];
                                        for (var element in snap.data!.docs) {
                                          var thisMsg = MessageData.fromMap(
                                              element.data());
                                          if (thisMsg.isRead == false &&
                                              thisMsg.senderId ==
                                                  users[index].uid) {
                                            thisLastMessages.add(thisMsg);
                                          }
                                        }
                                        lastMessagesLength[index] =
                                            thisLastMessages.length;
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
                                      // var unreadMmessages = [];
                                      // for (var msg in lastMessages) {
                                      //   if (msg.senderId == users[index].uid) {
                                      //     unreadMmessages.add(msg);
                                      //   }
                                      // }
                                      // if (kDebugMode) {
                                      //   print(unreadMmessages);
                                      // }
                                      return Container(
                                        color: Colors.white,
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: ListTile(
                                              onTap: () {
                                                if (finishLoading) {
                                                  if (users.length > index) {
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
                                                    Navigator.of(context).push(
                                                        CustomPageRoute(
                                                            axis: AxisDirection
                                                                .down,
                                                            child: Conversation(
                                                              lastMessages: unReadMessages
                                                                      .isEmpty
                                                                  ? <MessageData>[]
                                                                  : unReadMessages,
                                                              user:
                                                                  users[index],
                                                              roomId: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id,
                                                            )));
                                                  }
                                                }
                                              },
                                              leading: finishLoading
                                                  ? Stack(children: [
                                                      CircleAvatar(
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
                                                      ),
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Container(
                                                          height: 15,
                                                          width: 15,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: users.length <=
                                                                    index
                                                                ? Colors.grey
                                                                : users[index]
                                                                            .status ==
                                                                        "online"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .grey,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 2),
                                                          ),
                                                        ),
                                                      )
                                                    ])
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
                                                            lastMessage != null
                                                                ? lastMessage!
                                                                            .id ==
                                                                        null
                                                                    ? "No Messages Yet"
                                                                    : timeago.format(DateTime.parse(
                                                                        lastMessage!
                                                                            .timestamp!))
                                                                : "failed to retreive msg please Refresh !",
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
                                                        showLastMessage(
                                                            lastMessage:
                                                                lastMessage!,
                                                            user: user),
                                                        lastMessages.any((element) =>
                                                                    element
                                                                        .senderId ==
                                                                    users[index]
                                                                        .uid) &&
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
                                                                    lastMessagesLength[
                                                                            index]
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

Widget showLastMessage({required MessageData lastMessage, User? user}) {
  int messageMaxLength = 18;
  var messsage = "";
  if (lastMessage.senderId == null) {
    messsage = "No Messages Yet";
  } else if (lastMessage.senderId == user!.uid) {
    messsage = "You: ";
  } else if (lastMessage.message == null) {
    messsage = "No Messages Yet";
  }
  switch (lastMessage.type) {
    case MessageType.Text:
      messsage += lastMessage.message!.length > messageMaxLength
          ? "${lastMessage.message!.substring(0, messageMaxLength)}..."
          : lastMessage.message!;
      break;
    case MessageType.Image:
      messsage += "Sent an Image";
      break;
    case MessageType.Video:
      messsage += "Sent a Video";
      break;
    case MessageType.Audio:
      messsage += "Sent an Audio";
      break;
    case MessageType.File:
      messsage += "Sent a File";
      break;
    case MessageType.Location:
      messsage += "Sent a Location";
      break;
    case MessageType.Sticker:
      messsage += "Sent a Sticker";
      break;
    default:
      messsage += "";
      break;
  }

  var color = lastMessage.id == null ||
          lastMessage.senderId == user!.uid ||
          lastMessage.isRead!
      ? Colors.grey
      : black;
  return Text(
    messsage,
    style: TextStyle(color: color, fontSize: 15),
  );
}
