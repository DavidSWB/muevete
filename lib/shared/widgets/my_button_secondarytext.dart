import 'package:flutter/material.dart';

class MyButtonSecondarytext extends StatelessWidget {
  const MyButtonSecondarytext({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
