import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/global.dart';

class Conversation extends StatefulWidget {
  const Conversation({super.key, required this.roomId});
  final String roomId;

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FocusNode _textFieldFocus = FocusNode();
  double _bottomAppBarOffset = 0.0;
  final TextEditingController messageController = TextEditingController();
  bool isWriting = false;
  @override
  void initState() {
    super.initState();
    _textFieldFocus.addListener(_onTextFieldFocusChange);
  }

  void _onTextFieldFocusChange() {
    setState(() {
      _bottomAppBarOffset = _textFieldFocus.hasFocus ? 50.0 : 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
        body: StreamBuilder(
            stream: firestore
                .collection("Rooms")
                .doc(widget.roomId)
                .collection("messages")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var msgData = snapshot.data!.docs[index].data()!
                            as Map<String, dynamic>;
                        return Center(
                          child: Text(
                              msgData['message'] ?? "error fetching message"),
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
                              senderId: "",
                              timestamp: DateTime.now().toString(),
                              type: "Text",
                            ).toMap());
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
