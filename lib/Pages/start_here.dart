import 'package:chat_app/Pages/log_in.dart';
import 'package:chat_app/Pages/sign_up.dart';
import 'package:chat_app/models/global.dart';
import 'package:flutter/material.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage("Assets/Background.png"),
              fit: BoxFit.fitHeight),
        ),
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset("Assets/Small-Logo.png"),
                const Text(
                  "Connect friends",
                  style: TextStyle(
                      fontSize: 75,
                      color: Colors.white,
                      fontWeight: FontWeight.normal),
                ),
                const Text(
                  "easily & quickly",
                  style: TextStyle(
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const Text(
                  "Our chat app is the perfect way to stay connected with friends and family.",
                  style: TextStyle(color: grey, fontSize: 20),
                ),
                thirdPartyConnect(Colors.white, context),
                Image.asset("Assets/Or.png"),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * 0.8, 50),
                      foregroundColor: black,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      textStyle: const TextStyle(
                          color: black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()));
                  },
                  child: const Text("sign up with mail"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Existing account?",
                      style: TextStyle(color: grey, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()));
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
