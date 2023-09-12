import 'dart:io';

import 'package:chat_app/Classes/message.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/global.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final thisHeight = Get.height;
  final thisWidth = Get.width;
  final record = FlutterSoundRecorder();
  final _storage = FirebaseStorage.instance;
  Map<String, VideoPlayerController> controllers = {};
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseFunctions functions = FirebaseFunctions.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  UserModel? interlocuter;
  final TextEditingController messageController = TextEditingController();
  bool isWriting = false;
  String chatBoxImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FApp%20icon.png?alt=media&token=d050fd05-8dbe-4393-a55e-2d4d9515218d";

  Future<HttpsCallableResult> sendMessage(String token, String messsage) async {
    HttpsCallable sendNotif = functions.httpsCallable("sendNotification");
    final resp = sendNotif.call(<String, dynamic>{
      "title": Auth().currentUser!.displayName,
      "body": messsage,
      "token": token,
      "image": chatBoxImageUrl,
    });
    return await resp;
  }

  Future<void> _launchURL(String url) async {
    var parsedUrl = Uri.parse(url);
    if (!await launchUrl(parsedUrl)) {
      throw Exception('Could not launch $parsedUrl');
    }
  }
  
  Future<void> sendImage(ImageSource source) async {
    ImagePickerPlus picker = ImagePickerPlus(context);
    SelectedImagesDetails? images = await picker.pickBoth(
        source: source,
        galleryDisplaySettings:
            GalleryDisplaySettings(cropImage: true, showImagePreview: true));
    if (images != null) {
      try {
        for (var image in images.selectedFiles) {
          var ref = _storage.ref();
          var uid = const Uuid().v4();
          var isImage = image.isThatImage;
          var snapshot = await ref
              .child("Messages/${widget.roomId}/$uid")
              .putFile(image.selectedFile);
          var url = await snapshot.ref.getDownloadURL();
          var now = DateTime.now().toString();
          MessageData message = MessageData(
              id: widget.roomId,
              message: url,
              messageId: uid,
              receiverId: widget.user.uid,
              senderId: Auth().currentUser!.uid,
              timestamp: now,
              type: isImage ? MessageType.Image : MessageType.Video,
              isRead: false);
          await firestore
              .collection("Rooms")
              .doc(widget.roomId)
              .collection("messages")
              .add(message.toMap());
          _updateLastMessage(now);
        }
      } catch (e) {
        printError(info: e.toString());
      }
    }
  }

  _updateLastMessage(String date) {
    firestore
        .collection("Rooms")
        .doc(widget.roomId)
        .update({"LastMsgTime": date});
  }

  List<TextSpan> extractURLAndText(
      {required String text, required Color color}) {
    List<TextSpan> spans = [];
    const urlPattern = r'(https?|ftp):\/\/[^\s/$.?#].[^\s]*$';
    final regex = RegExp(urlPattern, caseSensitive: false);

    String url = '';
    String linkText = text;
    int currentIndex = 0;
    for (var match in regex.allMatches(text)) {
      final preMatch = text.substring(currentIndex, match.start);
      if (preMatch.isNotEmpty) {
        spans.add(
          TextSpan(
              text: preMatch,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        );
      }
      // Extract the URL and text
      final url = match.group(0)!;
      final linkText = url;

      // Create a clickable span
      spans.add(
        TextSpan(
          text: linkText,
          style: TextStyle(
            color: color,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(url);
            },
        ),
      );

      currentIndex = match.end;
    }
    // Add any remaining non-URL text
    final remainingText = text.substring(currentIndex);
    if (remainingText.isNotEmpty) {
      spans.add(
        TextSpan(
            text: remainingText,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      );
    }

    return spans;
  }

  Widget renderText(MessageData data, BuildContext context) {
    var spans = extractURLAndText(
      text: data.message!,
      color: data.senderId != Auth().currentUser!.uid ? black : Colors.white,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color:
              data.senderId == Auth().currentUser!.uid ? primaryColor : grey2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
                data.senderId == Auth().currentUser!.uid ? 20 : 0),
            topRight: Radius.circular(
                data.senderId == Auth().currentUser!.uid ? 0 : 20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          )),
      child: RichText(text: TextSpan(children: spans)),
    );
  }

  Widget renderImageMessage(MessageData data, BuildContext context) {
    return Container(
      height: thisHeight * 0.3,
      width: thisWidth * 0.7,
      decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(data.message!))),
    );
  }

  Widget renderVideo(MessageData data, BuildContext context) {
    controllers[data.messageId!] ??=
        VideoPlayerController.networkUrl(Uri.parse(data.message!));
    var controller = controllers[data.messageId!];
    if (!controller!.value.isInitialized) {
      controller.initialize().then((_) {
        if (context.mounted) {
          setState(() {});
        }
      });
      controller.setLooping(true);
    }

    if (controller.value.isInitialized) {
      return SizedBox(
        width: thisWidth * 0.7,
        child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(alignment: Alignment.center, children: [
              VideoPlayer(controller),
              IconButton(
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icomoon.Play,
                    color: Colors.white,
                  )),
            ])),
      );
    } else {
      return Shimmer.fromColors(
        baseColor: Colors.red,
        highlightColor: Colors.green,
        child: SizedBox(
          height: thisHeight * 0.3,
          width: thisWidth * 0.7,
        ),
      );
    }
  }

  Widget renderMessage(MessageData data, BuildContext context) {
    switch (data.type) {
      case MessageType.Text:
        return renderText(data, context);
      case MessageType.Image:
        return renderImageMessage(data, context);
      case MessageType.Video:
        return renderVideo(data, context);
      default:
        return renderText(data, context);
    }
  }

  Widget thisBottomAppBar() {
    return BottomAppBar(
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
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (context) {
                //     return const Test();
                //   },
                // ));
              },
            ),
            Expanded(
              child: TextField(
                controller: messageController,
                onChanged: (value) {
                  setState(() {
                    isWriting = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                        onPressed: () async {
                          await sendImage(ImageSource.gallery);
                        },
                        icon: const Icon(
                          Icomoon.files,
                          color: black,
                        )),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: "your message...",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    )),
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
              onPressed: send,
            ),
            !isWriting
                ? IconButton(
                    icon: const Icon(
                      Icomoon.Mic,
                      color: black,
                      size: 20,
                    ),
                    onPressed: () {
                      if (record.isStopped) {
                        startRecord();
                      } else if (record.isRecording) {
                        stopRecord();
                      }
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  void send() async {
    if (isWriting) {
      var now = DateTime.now().toString();
      firestore
          .collection("Rooms")
          .doc(widget.roomId)
          .collection("messages")
          .add(MessageData(
                  id: widget.roomId,
                  message: messageController.text,
                  messageId: const Uuid().v4(),
                  receiverId: widget.user.uid,
                  senderId: Auth().currentUser!.uid,
                  timestamp: now,
                  type: MessageType.Text,
                  isRead: false)
              .toMap());
      _updateLastMessage(now);
      var msg = messageController.text;
      messageController.clear();
      for (var token in interlocuter!.token!) {
        await sendMessage(token, msg);
      }
      if (context.mounted) {
        setState(() {
          isWriting = false;
        });
      }
    } else {
      sendImage(ImageSource.camera);
      for (var token in interlocuter!.token!) {
        await sendMessage(token, "Sent an image");
      }
    }
  }

  Future<void> initRecord() async {
    super.initState();
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      throw 'permission denied to access microphone';
    }
    await record.openRecorder();
    await record.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  @override
  void dispose() {
    super.dispose();
    record.closeRecorder();
  }

  Future<void> startRecord() async {
    await record.startRecorder(toFile: 'audio');
  }

  Future<void> stopRecord() async {
    final path = await record.stopRecorder();
    final file = File(path!);
    if (kDebugMode) {
      print('file path is : $path');
      print('file location is : $file');
    }
  }

  @override
  void initState() {
    super.initState();

    initRecord();

    if (widget.lastMessages.isNotEmpty) {
      for (var element in widget.lastMessages) {
        try {
          firestore
              .collection("Rooms")
              .doc(widget.roomId)
              .collection("messages")
              .where("isRead", isEqualTo: false)
              .get()
              .then((value) => {
                    for (var ele in value.docs)
                      {
                        if (ele["senderId"] != Auth().currentUser!.uid)
                          {
                            firestore
                                .collection("Rooms")
                                .doc(widget.roomId)
                                .collection("messages")
                                .doc(ele.id)
                                .update({"isRead": true})
                          }
                      }
                  });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      }
    }
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
                interlocuter = UserModel.fromMap(snapshot.data!.docs[0].data());
                return Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: interlocuter!.profilePhoto != null
                              ? NetworkImage(interlocuter!.profilePhoto! != ""
                                  ? interlocuter!.profilePhoto!
                                  : "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile.png?alt=media&token=3b0b8b1e-5b0a-4b0e-9b0a-9b0a9b0a9b0a")
                              : const AssetImage("Assets/Profile.png")
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: interlocuter!.status == "online"
                                  ? Colors.green
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
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
                          interlocuter!.status ?? "error fetching status",
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
      body: StreamBuilder(
          stream: firestore
              .collection("Rooms")
              .doc(widget.roomId)
              .collection("messages")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isNotEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ListView.builder(
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
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        data.senderId == Auth().currentUser!.uid
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                    children: [
                                      if (data.senderId !=
                                          Auth().currentUser!.uid)
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: widget
                                                      .user.profilePhoto !=
                                                  null
                                              ? NetworkImage(widget
                                                          .user.profilePhoto !=
                                                      ""
                                                  ? widget.user.profilePhoto!
                                                  : "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile.png?alt=media&token=3b0b8b1e-5b0a-4b0e-9b0a-9b0a9b0a9b0a")
                                              : const AssetImage(
                                                      "Assets/Profile.png")
                                                  as ImageProvider,
                                        ),
                                      SizedBox(
                                        width: data.senderId ==
                                                Auth().currentUser!.uid
                                            ? 20
                                            : 10,
                                      ),
                                      Flexible(
                                        child: renderMessage(data, context),
                                      ),
                                    ],
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
                            );
                          }),
                    ),
                    thisBottomAppBar()
                  ],
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text("Something went wrong"),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Center(
                      child: Text(
                          "Send Your first Message to ${widget.user.name}!"),
                    ),
                    thisBottomAppBar(),
                  ],
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
