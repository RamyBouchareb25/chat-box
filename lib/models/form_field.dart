import 'package:flutter/material.dart';

import 'global.dart';

class CustomFormField extends StatelessWidget {
  const CustomFormField(
      {super.key,
      required this.label,
      required this.validator,
      required this.controller,
      required this.onChanged,
      required this.obscureText});

  final String label;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final void Function() onChanged;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
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
            obscureText: obscureText,
            controller: controller,
            onChanged: (value) {
              onChanged();
            },
            validator: validator,
            cursorHeight: 25,
            decoration: const InputDecoration(
                border: UnderlineInputBorder(borderSide: BorderSide())),
          ),
        ),
      ],
    );
  }
}
