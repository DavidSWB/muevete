import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class MyQuizoptionButton extends StatelessWidget {
  const MyQuizoptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 0.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primaryDark : Colors.grey.shade200,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      color: isSelected ? AppColors.cardBlue : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppColors.primaryDark : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primaryDark : AppColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
