import 'package:chat_app/Pages/search.dart';
import 'package:chat_app/auth.dart';
import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/icomoon_icons.dart';

class DefaultAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DefaultAppBar(
      {super.key, required this.title, required this.context, this.image});
  final String title;
  final BuildContext context;
  final ImageProvider? image;
  @override
  Size get preferredSize => Size(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * 0.1);

  @override
  State<DefaultAppBar> createState() => _DefaultAppBarState();
}

class _DefaultAppBarState extends State<DefaultAppBar> {
  final bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: PopupMenuButton(
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(
                  enabled: _enabled,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Auth().signOut();
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
              ];
            },
            child: Hero(
                tag: "User Photo",
                child: CircleAvatar(
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  // backgroundColor: Colors.transparent,
                  foregroundImage: widget.image ??
                      Image.asset("Assets/Profile-Dark.png") as ImageProvider,
                )),
          ),
        )
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 10, top: 10),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: grey, width: 1)),
          child: IconButton(
            icon: const Icon(Icomoon.search),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const SearchPage();
                },
              ));
            },
          ),
        ),
      ),
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(widget.title),
      ),
    );
  }
}
