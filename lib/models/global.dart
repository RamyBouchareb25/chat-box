import 'package:chat_app/models/google_sign_in.dart';
import 'package:chat_app/widget_tree.dart';
import 'package:flutter/material.dart';

const Color primaryColor = Color.fromRGBO(36, 120, 109, 1);
const Color black = Color.fromRGBO(12, 19, 16, 1);
const Color grey = Color.fromARGB(255, 121, 124, 123);
const Color dark = Color.fromARGB(252, 18, 20, 20);
const Color light = Color.fromARGB(255, 242, 247, 251);
const Color grey2 = Color(0xFFF2F7FB);
AppBar appBar(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: const Icon(
        Icons.arrow_back,
        color: black,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}

Widget thirdPartyConnect(Color stroke, BuildContext context) {
  return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            elevation: 0,
            heroTag: "Facebook",
            backgroundColor: Colors.transparent,
            onPressed: () {},
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: stroke)),
            child: Image.asset("Assets/Facebook.png"),
          ),
          FloatingActionButton(
            elevation: 0,
            heroTag: "Google",
            backgroundColor: Colors.transparent,
            onPressed: () {
              AuthGoogle().signInWithGoogle().then((value) => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WidgetTree()))
                  });
            },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: stroke)),
            child: Image.asset("Assets/Google.png"),
          ),
          FloatingActionButton(
            elevation: 0,
            heroTag: "Apple",
            backgroundColor: Colors.transparent,
            onPressed: () {},
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: BorderSide(color: stroke)),
            child: Image.asset(stroke != Colors.white
                ? "Assets/AppleDark.png"
                : "Assets/Apple.png"),
          ),
        ],
      ));
}
