import 'package:chat_app/models/global.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

enum FormTypes {
  email,
  password,
  name,
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController controllerPassword = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isFormValid = false;
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
                    _buildName(),
                    _buildEMail(),
                    _buildPassword(),
                    _buildConfirmPassword(),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUp(),
                        fullscreenDialog: true));
              }
            },
            child: const Text("Create Account"),
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

  Widget _buildConfirmPassword() {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Confirm Password",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            onChanged: (value) {
              _validateForm();
            },
            validator: (value) {
              return value! != controllerPassword.text
                  ? "Password must be the same !"
                  : null;
            },
            cursorHeight: 25,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide())),
          ),
        ),
      ],
    );
  }

  Widget _buildPassword() {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Password",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            onChanged: (value) {
              _validateForm();
            },
            controller: controllerPassword,
            validator: (value) {
              return value!.length < 8
                  ? "Password must be at least 8 characters long"
                  : null;
            },
            cursorHeight: 25,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide())),
          ),
        ),
      ],
    );
  }

  Widget _buildEMail() {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Your email",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            onChanged: (value) {
              _validateForm();
            },
            validator: (value) {
              return EmailValidator.validate(value!)
                  ? null
                  : "Please enter a valid email";
            },
            cursorHeight: 25,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide())),
          ),
        ),
      ],
    );
  }

  Widget _buildName() {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
            child: const Text(
              "Your Name",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15)),
          child: TextFormField(
            onChanged: (value) {
              _validateForm();
            },
            validator: (value) {
              return value!.length < 3
                  ? "Name must be at least 3 characters long"
                  : null;
            },
            cursorHeight: 25,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide())),
          ),
        ),
      ],
    );
  }
}
