import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muevete/shared/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.isDestructive = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.primaryDark;
    final iconBgColor =
        isDestructive ? AppColors.errorSoft : AppColors.cardBlue;

    return ListTile(
      minVerticalPadding: 14,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: icon != null
          ? Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDestructive ? AppColors.error : AppColors.textMuted,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
