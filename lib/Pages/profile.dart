import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({required this.user, super.key});
  final UserModel user;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late bool roomExists;
  late String roomId;
  Future<DocumentReference<Map<String, dynamic>>> _createRoom(
      UserModel user) async {
    var newRoom = await _firestore.collection("Rooms").add({
      "users": [user.uid, Auth().currentUser!.uid],
    });
    await _firestore.collection("Rooms").doc(newRoom.id).update({
      "isTyping": {"User1": false, "User2": false},
      "LastMsgTime": DateTime.now().toString()
    });
    return newRoom;
  }

  final _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    _firestore
        .collection("Rooms")
        .where("users", isEqualTo: [widget.user.uid, Auth().currentUser!.uid])
        .get()
        .then((room1) {
          _firestore
              .collection("Rooms")
              .where("users",
                  isEqualTo: [Auth().currentUser!.uid, widget.user.uid])
              .get()
              .then((room2) {
                roomExists = room1.docs.isNotEmpty || room2.docs.isNotEmpty;
                roomId = room1.docs.isNotEmpty
                    ? room1.docs.first.id
                    : room2.docs.first.id;
              });
        });
    super.initState();
  }

  Widget _item({required String title, required String subtitle}) {
    return Container(
      color: Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(color: Color.fromARGB(255, 128, 128, 128)),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: black, fontSize: 20),
        ),
      ),
    );
  }

  Widget _button({required IconData icon, required Function() onPressed}) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: darkGreen),
      child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: Colors.white,
            size: 20,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160), // Set the height you desire
        child: Stack(
          children: [
            AppBar(
                // Other AppBar properties like actions, etc.
                ),
            Positioned(
              top: 60, // Adjust the top value as needed
              left: MediaQuery.of(context).size.width / 2.8,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.user.profilePhoto!),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
          top: true,
          child: Column(
            children: [
              Center(
                  child: Text(widget.user.name!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Text("@${widget.user.name!.replaceAll(" ", "")}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _button(
                        icon: Icomoon.Chats3,
                        onPressed: () {
                          if (roomExists) {
                            Navigator.of(context).pop();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Conversation(
                                    roomId: roomId,
                                    user: widget.user,
                                    lastMessages: const <MessageData>[]);
                              },
                            ));
                          } else {
                            _createRoom(widget.user).then((newRoom) {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx3) {
                                  return Conversation(
                                      roomId: newRoom.id,
                                      user: widget.user,
                                      lastMessages: const <MessageData>[]);
                                },
                              ));
                            });
                          }
                        }),
                    _button(icon: Icomoon.Video, onPressed: () {}),
                    _button(icon: Icomoon.Call, onPressed: () {}),
                    _button(icon: Icons.more_horiz, onPressed: () {}),
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
                        delegate: SliverChildListDelegate.fixed([
                      _item(title: "Display Name", subtitle: widget.user.name!),
                      _item(
                          title: "Email Adress", subtitle: widget.user.email!),
                      _item(title: "Adress", subtitle: "Not Set"),
                      _item(title: "Phone Number", subtitle: "Not Set"),
                    ])),
                    SliverFillRemaining(
                      child: Container(
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
