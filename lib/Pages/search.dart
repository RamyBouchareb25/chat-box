import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/Pages/conversation.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:elastic_client/elastic_client.dart' as elastic;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final elastic.Client client = elastic.Client(elastic.HttpTransport(
      url: "https://chatbox.es.europe-west1.gcp.cloud.es.io",
      authorization:
          "ApiKey Y3VVdVRvb0IwZGh4RUV2M2piRno6RDRjNEdweGhUZWlVWUo1Y2I1ZFh5dw=="));

  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;
  late Future<List<UserModel>> _usersFuture;
  _updateStream() {
    setState(() {
      // userIds != null && userIds.isNotEmpty
      //     ? _usersStream = _firestore
      //         .collection("Users")
      //         .where("UserId", whereIn: userIds)
      //         .snapshots()
      //     :
      _usersStream = _firestore.collection("Users").orderBy("Name").snapshots();
    });
  }

  @override
  void initState() {
    _usersFuture = searchUsers();
    _usersStream = _firestore.collection("Users").snapshots();
    _controller.addListener(() {
      _updateStream();
    });
    super.initState();
  }

  Future<List<UserModel>> searchUsers() async {
    List<UserModel> users = <UserModel>[];
    var query = _controller.text;
    try {
      elastic.SearchResult response;
      if (query == "") {
        response = await client.search(
            index: "users",
            query: elastic.Query.matchAll(),
            source: true,
            size: 1000);
      } else {
        response = await client.search(
            index: "users",
            query: elastic.Query.match("Name", _controller.text));
      }

      for (var element in response.hits) {
        var user = UserModel.fromMap(element.doc as Map<String, dynamic>);
        users.add(user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    return users;
  }

  Future<void> _createRoom(UserModel user, BuildContext ctx) async {
    final newRoom = await _firestore.collection("Rooms").add({
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
    Navigator.pop(ctx);
  }

  bool isLoading = false;
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
                      autofocus: true,
                      onChanged: (value) async {
                        setState(() {
                          _usersFuture = searchUsers();
                        });
                        // _updateStream(userIds: uIds);
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
        body: !isLoading
            ? Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("People",
                        style: TextStyle(color: black, fontSize: 20)),
                  ),
                  FutureBuilder(
                      future: _usersFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("No Users Found"),
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              UserModel user = snapshot.data![index];
                              return ListTile(
                                onTap: () async {
                                  setState(() {});
                                  final Room1 = await _firestore
                                      .collection("Rooms")
                                      .where("users", isEqualTo: [
                                    user.uid,
                                    Auth().currentUser!.uid
                                  ]).get();
                                  final Room2 = await _firestore
                                      .collection("Rooms")
                                      .where("users", isEqualTo: [
                                    Auth().currentUser!.uid,
                                    user.uid
                                  ]).get();
                                  final roomExists = Room1.docs.isNotEmpty ||
                                      Room2.docs.isNotEmpty;
                                  if (roomExists) {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return Conversation(
                                            roomId: Room1.docs.isNotEmpty
                                                ? Room1.docs.first.id
                                                : Room2.docs.first.id,
                                            user: user,
                                            lastMessages: const <
                                                MessageData>[]);
                                      },
                                    ));
                                    Navigator.pop(grandContext);
                                  } else {
                                    _createRoom(user, grandContext);
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage:
                                      NetworkImage(user.profilePhoto!),
                                ),
                                title: Text(user.name!,
                                    style: const TextStyle(
                                        color: black, fontSize: 20)),
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
              )
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}
