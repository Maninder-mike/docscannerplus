import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool showArrow;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: titleColor ?? theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          if (onTap != null && showArrow) ...[
            if (trailing != null) const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
              size: 20,
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
