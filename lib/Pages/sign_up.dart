import 'package:chat_app/models/form_field.dart';
import 'package:chat_app/models/global.dart';
import 'package:chat_app/widget_tree.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/auth.dart';

enum FormTypes {
  email,
  password,
  name,
}

class SignUp extends StatefulWidget {
  const SignUp({super.key,required this.token});
  final String token;
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? errorMessage;

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: controllerEMail.text,
        password: controllerPassword.text,
        name: controllerName.text,
        token: "",
      );
      Auth().currentUser!.updatePhotoURL(
          "https://firebasestorage.googleapis.com/v0/b/chatbox-3dac1.appspot.com/o/Images%2FProfile-Dark.png?alt=media&token=14a7aa82-5323-4903-90fc-a2738bd42577");
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  final TextEditingController controllerPassword = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerEMail = TextEditingController();
  final TextEditingController controllerConfirmPassword =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
  final bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Sign Up with Email",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const Text(
                "Get chatting with friends and family today by signing up for our chat app!",
                style: TextStyle(
                  color: grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Form(
              key: formKey,
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomFormField(
                        obscureText: false,
                        label: "Your Name",
                        validator: (value) {
                          return value!.length < 3
                              ? "Name must be at least 3 characters long"
                              : null;
                        },
                        controller: controllerName,
                        onChanged: _validateForm),
                    CustomFormField(
                        obscureText: false,
                        label: "Your E-Mail",
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
                          return value!.length < 8
                              ? "Password must be at least 8 characters long"
                              : null;
                        },
                        controller: controllerPassword,
                        onChanged: _validateForm),
                    CustomFormField(
                      label: "Confirm Password",
                      validator: (value) {
                        return value! != controllerPassword.text
                            ? "Password must be the same !"
                            : null;
                      },
                      controller: controllerConfirmPassword,
                      onChanged: _validateForm,
                      obscureText: true,
                    ),
                  ],
                ),
              )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
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
              if (formKey.currentState!.validate()) {
                createUserWithEmailAndPassword().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WidgetTree(
                                token: widget.token,
                              )));
                });
              }
            },
            child: _isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text("Create Account"),
          ),
        ],
      ),
    );
  }

  void _validateForm() {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isFormValid = true;
      });
    } else {
      setState(() {
        _isFormValid = false;
      });
    }
  }
}
