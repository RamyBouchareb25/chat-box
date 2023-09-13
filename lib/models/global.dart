import 'package:chat_app/Classes/custom_page_route.dart';
import 'package:chat_app/Pages/home_page.dart';
import 'package:chat_app/Pages/settings.dart';
import 'package:chat_app/models/google_sign_in.dart';
import 'package:chat_app/widget_tree.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/icomoon_icons.dart';

const MaterialColor primarySwatch = MaterialColor(0xFF24786D, <int, Color>{
  50: Color(0xFF24F86D),
  100: Color(0xFF24F86D),
  200: Color(0xFF24E86D),
  300: Color(0xFF24D86D),
  400: Color(0xFF24C86D),
  500: Color(0xFF24B86D),
  600: Color(0xFF24A86D),
  700: Color(0xFF24986D),
  800: Color(0xFF24886D),
  900: Color(0xFF24786D),
});

const Color primaryColor = Color(0xFF24786D);
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

Widget bottomNavBar({selectedPage, required BuildContext context}) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.grey,
    iconSize: 20,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icomoon.Chats3),
        label: "Chats",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icomoon.Calls),
        label: "Calls",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icomoon.User),
        label: "People",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icomoon.Settings),
        label: "Settings",
      ),
    ],
    currentIndex: selectedPage,
    onTap: (value) {
      switch (value) {
        case 0:
          // Navigator.popUntil(context, (route) => !route.isCurrent);
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => const Home()));
          Navigator.pushReplacement(
              context,
              CustomPageRoute(
                child: const Home(),
                axis: AxisDirection.left,
              ));
          break;
        case 1:
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => const Home()));
          break;
        case 2:
          // Navigator.push(
          //     context, MaterialPageRoute(builder: (context) => const Home()));
          break;
        case 3:
          // Navigator.popUntil(context, (route) => !route.isCurrent);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => const SettingsPage()));
          Navigator.pushReplacement(
              context,
              CustomPageRoute(
                child: const SettingsPage(),
                axis: AxisDirection.right,
              ));
          break;
        default:
      }
    },
  );
}

Widget thirdPartyConnect(Color stroke, BuildContext context, String token) {
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
              AuthGoogle().signInWithGoogle(token: token).then((value) => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WidgetTree(
                                  token: token,
                                )))
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
