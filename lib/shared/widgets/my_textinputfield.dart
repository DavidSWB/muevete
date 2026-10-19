import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextinputfield extends StatelessWidget {
  const MyTextinputfield({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
  });

    final TextEditingController controller;
    final String hintText;
    final bool obscureText;
    final TextInputType? keyboardType;
    final List<TextInputFormatter>? inputFormatters;
    final bool readOnly;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        readOnly: readOnly,
        style: const TextStyle(height: 1),
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          hintText: hintText,
          filled: readOnly,
          fillColor: readOnly ? Colors.grey.shade100 : null,
        ),
      ),
    );
  }
}