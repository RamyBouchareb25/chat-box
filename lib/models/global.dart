import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF24786D);
const Color black = Color.fromRGBO(12, 19, 16, 1);
const Color grey = Color.fromARGB(255, 121, 124, 123);
const Color dark = Color.fromARGB(252, 18, 20, 20);
const Color light = Color.fromARGB(255, 242, 247, 251);

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
