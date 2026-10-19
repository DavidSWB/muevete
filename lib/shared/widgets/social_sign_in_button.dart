import 'package:flutter/material.dart';

/// A platform-styled button for social authentication providers.
class SocialSignInButton extends StatelessWidget {
  const SocialSignInButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.iconAsset,
    this.iconWidget,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  /// Path to a local asset image (e.g. 'assets/images/google_logo.png').
  final String? iconAsset;

  /// A custom widget to use as the icon instead of [iconAsset].
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Material(
        color: Colors.white,
        elevation: 1,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: isLoading ? null : onTap,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 50,
              maxHeight: 60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  if (iconWidget != null)
                    iconWidget!
                  else if (iconAsset != null)
                    Image.asset(iconAsset!, width: 22, height: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
