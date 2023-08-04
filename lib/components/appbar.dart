import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/icomoon_icons.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DefaultAppBar(
      {super.key, required this.title, required this.context, this.image});
  final String title;
  final BuildContext context;
  final Image? image;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: Hero(
              tag: "User Photo",
              child: CircleAvatar(
                foregroundColor: Colors.transparent,
                backgroundColor: Colors.white,
                // backgroundColor: Colors.transparent,
                child: image ?? Image.asset("Assets/Profile-Dark.png"),
              )),
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
            onPressed: () {},
          ),
        ),
      ),
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(title),
      ),
    );
  }

  @override
  Size get preferredSize => Size(MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height * 0.1);
}
