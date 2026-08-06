import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled? onTap: null,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 30,
          maxHeight: 60,
          minWidth: 100,
        ),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: enabled? AppColors.primary : AppColors.disabledBg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : AppColors.disabledFg,
            fontSize: 23,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      ),
    );
  }
}