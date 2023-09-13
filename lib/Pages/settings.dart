import 'package:chat_app/auth.dart';
import 'package:chat_app/components/appbar.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/models/icomoon_icons.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Classes/settings_list.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = Auth.userModel!;
  SettingsList settingsList = SettingsList(titles: [
    "Account",
    "Chat",
    "Notifications",
    "Help",
    "Storage And Data",
    "Invite a Friend"
  ], subtitles: [
    "Privacy, security, change number",
    "Theme, wallpapers, chat history",
    "Message, group & others",
    "Help Center, contact us, privacy policy",
    "Network usage, Storage usage",
    "Share ChatApp, Tell your friends"
  ], icons: [
    Icomoon.keys,
    Icomoon.chat,
    Icomoon.Notification,
    Icomoon.help,
    Icomoon.data,
    Icomoon.User
  ]);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: DefaultAppBar(
        title: "Settings",
        context: context,
      ),
      body: Column(
        children: [
          Container(
            height: 50.0, // Adjust the height as needed
            decoration: const BoxDecoration(
                // color: grey, // Change the color as desired
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
                      border: Border.all(color: Colors.grey[350]!, width: 1)),
                ),
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                    delegate: SliverChildListDelegate.fixed(<Widget>[
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                    NetworkImage(user.profilePhoto!),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name!,
                                      style: const TextStyle(
                                          color: black, fontSize: 20),
                                    ),
                                    Text(
                                      "Bio Coming Soon !",
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icomoon.Qr_Code,
                              color: primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ])),
                SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 12,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          onTap: () {},
                          leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                settingsList.icons[index],
                                color: black,
                              )),
                          title: Text(settingsList.titles[index]),
                          subtitle: Text(settingsList.subtitles[index]),
                        ),
                      ),
                    ],
                  );
                }, childCount: settingsList.titles.length)),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: bottomNavBar(context: context, selectedPage: 3),
    );
  }
}
