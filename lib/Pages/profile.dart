import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  Widget item() {
    return Container(
      color: Colors.white,
      child: const ListTile(
        title: Text(
          "data",
          style: TextStyle(color: Color.fromARGB(255, 106, 106, 106)),
        ),
        subtitle: Text(
          "data",
          style: TextStyle(color: black, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: black,
      appBar: DefaultAppBar(title: "", context: context),
      body: SafeArea(
          top: true,
          child: Column(
            children: [
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
                        delegate: SliverChildListDelegate.fixed([item()])),
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
