import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyHeadingOne extends StatelessWidget {
  const MyHeadingOne({
    super.key,
    required this.text,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: const TextStyle(
        fontSize: 28,
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    );
  }
}
