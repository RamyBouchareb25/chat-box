import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;
  @override
  void initState() {
    _usersStream = _firestore.collection("Users").snapshots();
    _controller.addListener(() {
      _updateStream();
    });
    super.initState();
  }

  _updateStream() {
    setState(() {
      _usersStream = _firestore.collection("Users").orderBy("Name").startAt(
          [_controller.text]).endAt(["${_controller.text}\uf8ff"]).snapshots();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext grandContext) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(
                    Icomoon.search,
                    color: black,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _updateStream();
                        });
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: "Search",
                        hintStyle: const TextStyle(color: black),
                        border: InputBorder.none,
                      ),
                    )),
                IconButton(
                  onPressed: () {
                    _controller.clear();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: black,
                  ),
                )
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child:
                  Text("People", style: TextStyle(color: black, fontSize: 20)),
            ),
            StreamBuilder(
                stream: _usersStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        UserModel user = UserModel.fromMap(
                            snapshot.data!.docs[index].data());
                        return ListTile(
                          onTap: () async {
                            final newRoom =
                                await _firestore.collection("Rooms").add({
                              "users": [user.uid, Auth().currentUser!.uid],
                            });
                            final testMessage = await _firestore
                                .collection("Rooms")
                                .doc(newRoom.id)
                                .collection("messages")
                                .add(MessageData(
                                  senderId: Auth().currentUser!.uid,
                                  timestamp: DateTime.now().toString(),
                                ).toMap());
                            await _firestore
                                .collection("Rooms")
                                .doc(newRoom.id)
                                .collection("messages")
                                .doc(testMessage.id)
                                .delete();
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return Conversation(
                                    roomId: newRoom.id,
                                    user: user,
                                    lastMessages: const <MessageData>[]);
                              },
                            ));
                            Navigator.pop(grandContext);
                          },
                          leading: const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage:
                                AssetImage("Assets/Profile-Dark.png"),
                          ),
                          title: Text(user.name!,
                              style:
                                  const TextStyle(color: black, fontSize: 20)),
                          subtitle: Text(
                            user.status!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        );
                      },
                    ),
                  );
                })
          ],
        ));
  }
}
