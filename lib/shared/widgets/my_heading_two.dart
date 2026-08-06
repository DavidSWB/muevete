import 'package:flutter/material.dart';

class MyHeadingTwo extends StatelessWidget {
  const MyHeadingTwo({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 21,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
