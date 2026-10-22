import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyHeadingTwo extends StatelessWidget {
  const MyHeadingTwo({
    super.key,
    required this.text,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 24,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    );
  }
}
