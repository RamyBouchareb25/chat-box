import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/global.dart';
import 'package:timeago/timeago.dart' as timeago;

class Conversation extends StatefulWidget {
  const Conversation(
      {super.key,
      required this.roomId,
      required this.user,
      required this.lastMessages});
  final String roomId;
  final UserModel user;
  final List<MessageData> lastMessages;

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FocusNode _textFieldFocus = FocusNode();
  double _bottomAppBarOffset = 0.0;
  double _bodyOffset = 0.0;
  final TextEditingController messageController = TextEditingController();
  bool isWriting = false;
  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(_onTextFieldFocusChange);
    if (widget.lastMessages.isNotEmpty) {
      for (var element in widget.lastMessages) {
        if (element.senderId != Auth().currentUser!.uid) {
          firestore
              .collection("Rooms")
              .doc(widget.roomId)
              .collection("messages")
              .doc(element.id)
              .update({"isRead": true});
        }
      }
    }
  }

  void _onTextFieldFocusChange() {
    setState(() {
      _bottomAppBarOffset = _textFieldFocus.hasFocus ? 50.0 : 0.0;
      _bodyOffset = _textFieldFocus.hasFocus ? 50.0 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
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
          title: StreamBuilder(
              stream: firestore
                  .collection("Users")
                  .where("UserId", isEqualTo: widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  UserModel interlocuter =
                      UserModel.fromMap(snapshot.data!.docs[0].data());
                  return Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: black,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                color: interlocuter.status == "online"
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name ?? "error fetching name",
                            style: const TextStyle(color: black),
                          ),
                          Text(
                            interlocuter.status ?? "error fetching status",
                            style: const TextStyle(color: grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
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
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          transform: Matrix4.translationValues(0.0, -_bodyOffset, 0.0),
          child: StreamBuilder(
              stream: firestore
                  .collection("Rooms")
                  .doc(widget.roomId)
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: snapshot.data!.size,
                        itemBuilder: (context, index) {
                          MessageData data = MessageData.fromMap(
                              snapshot.data!.docs[index].data()!
                                  as Map<String, dynamic>);
                          MessageData? previousData = index > 0
                              ? MessageData.fromMap(
                                  snapshot.data!.docs[index - 1].data()!
                                      as Map<String, dynamic>)
                              : null;
                          // MessageData? nextData =
                          //     index < snapshot.data!.docs.length - 1
                          //         ? MessageData.fromMap(
                          //             snapshot.data!.docs[index + 1].data()!
                          //                 as Map<String, dynamic>)
                          //         : null;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: previousData != null
                                  ? previousData.senderId != data.senderId
                                      ? 30
                                      : 5
                                  : 40,
                              left: data.senderId == Auth().currentUser!.uid
                                  ? 0
                                  : 15,
                              right: data.senderId == Auth().currentUser!.uid
                                  ? 15
                                  : 0,
                            ),
                            child: Align(
                              alignment:
                                  data.senderId == Auth().currentUser!.uid
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Align(
                                    alignment:
                                        data.senderId == Auth().currentUser!.uid
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: data.senderId ==
                                                  Auth().currentUser!.uid
                                              ? primaryColor
                                              : grey2,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                data.senderId ==
                                                        Auth().currentUser!.uid
                                                    ? 20
                                                    : 0),
                                            topRight: Radius.circular(
                                                data.senderId ==
                                                        Auth().currentUser!.uid
                                                    ? 0
                                                    : 20),
                                            bottomLeft:
                                                const Radius.circular(20),
                                            bottomRight:
                                                const Radius.circular(20),
                                          )),
                                      child: Text(
                                        data.message ??
                                            "error fetching message",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: data.senderId ==
                                                  Auth().currentUser!.uid
                                              ? Colors.white
                                              : black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if ((previousData != null &&
                                          previousData.senderId !=
                                              data.senderId) ||
                                      index == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 10),
                                      child: Text(
                                        timeago.format(
                                            DateTime.parse(data.timestamp!)),
                                        style: const TextStyle(
                                          color: grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("Something went wrong"),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          transform: Matrix4.translationValues(
              0.0,
              _bottomAppBarOffset > 0
                  ? -MediaQuery.of(context).viewInsets.bottom
                  : 0.0,
              0.0),
          child: BottomAppBar(
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icomoon.Clip,
                      color: black,
                      size: 20,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        setState(() {
                          isWriting = value.isNotEmpty;
                        });
                      },
                      focusNode: _textFieldFocus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: "Write your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      height: 40,
                      width: 40,
                      decoration: isWriting
                          ? BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            )
                          : null,
                      child: Icon(
                        !isWriting ? Icomoon.Camera : Icomoon.Send,
                        color: !isWriting ? black : Colors.white,
                        size: !isWriting ? 20 : 15,
                      ),
                    ),
                    onPressed: () {
                      if (isWriting) {
                        firestore
                            .collection("Rooms")
                            .doc(widget.roomId)
                            .collection("messages")
                            .add(MessageData(
                                    id: widget.roomId,
                                    message: messageController.text,
                                    receiverId: "",
                                    senderId: Auth().currentUser!.uid,
                                    timestamp: DateTime.now().toString(),
                                    type: "Text",
                                    isRead: false)
                                .toMap());
                        messageController.clear();
                        setState(() {
                          isWriting = false;
                        });
                      }
                    },
                  ),
                  !isWriting
                      ? IconButton(
                          icon: const Icon(
                            Icomoon.Mic,
                            color: black,
                            size: 20,
                          ),
                          onPressed: () {},
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ));
  }
}
