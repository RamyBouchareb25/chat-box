import 'package:chat_app/models/form_field.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/widget_tree.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? errorMessage;

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEMailAndPassword(
          email: controllerEMail.text, password: controllerPassword.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController controllerEMail = TextEditingController();
  final TextEditingController controllerPassword = TextEditingController();
  bool _isFormValid = false;
  bool _isLoading = false;
  void _validateForm() {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isFormValid = true;
      });
    } else {
      setState(() {
        _isFormValid = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              "Log in to Chatbox",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Welcome back! Sign in using your social account or email to continue us",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            thirdPartyConnect(black, context),
            Image.asset("Assets/OrDark.png"),
            Form(
                key: formkey,
                child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CustomFormField(
                          obscureText: false,
                          label: "Your email",
                          validator: (value) {
                            return EmailValidator.validate(value!)
                                ? null
                                : "Please enter a valid email";
                          },
                          controller: controllerEMail,
                          onChanged: _validateForm),
                      CustomFormField(
                          obscureText: true,
                          label: "Password",
                          validator: (value) {
                            return value!.isEmpty
                                ? "You Must Enter Your Password"
                                : null;
                          },
                          controller: controllerPassword,
                          onChanged: _validateForm),
                    ],
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.8, 50),
                    foregroundColor: _isFormValid ? Colors.white : grey,
                    backgroundColor: _isFormValid ? primaryColor : light,
                    elevation: 0,
                    textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                onPressed: () {
                  if (formkey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    signInWithEmailAndPassword().then((value) {
                      if (errorMessage == null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WidgetTree()));
                      } else {
                        if (kDebugMode) {
                          print(errorMessage);
                        }
                        setState(() {
                          _isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(errorMessage ?? "Unknown Error")));
                        errorMessage = null;
                      }
                    });
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Log In"),
              ),
            ),
            TextButton(
                onPressed: () {
                  Auth().resetPass();
                },
                child: const Text("Forgot Password?",
                    style: TextStyle(color: primaryColor, fontSize: 15))),
          ],
        ),
      ),
    );
  }
}
