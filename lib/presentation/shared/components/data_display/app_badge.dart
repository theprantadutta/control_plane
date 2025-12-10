import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';

/// Badge variants for different semantic meanings
enum BadgeVariant { success, warning, error, info, neutral, primary }

/// Badge sizes
enum BadgeSize { small, medium, large }

/// A badge/chip component for status indicators.
/// Inspired by Vercel's badge design.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
    this.size = BadgeSize.medium,
    this.outlined = false,
    this.onTap,
  });

  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final BadgeSize size;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final colors = _getColors(isDark);
    final sizing = _getSizing();

    final badge = Container(
      padding: sizing.padding,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : colors.background,
        borderRadius: AppRadius.radiusXs,
        border: outlined ? Border.all(color: colors.foreground, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: sizing.iconSize,
              color: colors.foreground,
            ),
            SizedBox(width: sizing.spacing),
          ],
          Text(
            label,
            style: sizing.textStyle.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXs,
        child: badge,
      );
    }

    return badge;
  }

  _BadgeColors _getColors(bool isDark) {
    return switch (variant) {
      BadgeVariant.success => _BadgeColors(
          foreground: isDark ? AppColors.success400 : AppColors.success600,
          background: isDark
              ? AppColors.success500.withValues(alpha: 0.15)
              : AppColors.success50,
        ),
      BadgeVariant.warning => _BadgeColors(
          foreground: isDark ? AppColors.warning400 : AppColors.warning600,
          background: isDark
              ? AppColors.warning500.withValues(alpha: 0.15)
              : AppColors.warning50,
        ),
      BadgeVariant.error => _BadgeColors(
          foreground: isDark ? AppColors.error400 : AppColors.error600,
          background: isDark
              ? AppColors.error500.withValues(alpha: 0.15)
              : AppColors.error50,
        ),
      BadgeVariant.info => _BadgeColors(
          foreground: isDark ? AppColors.info400 : AppColors.info600,
          background: isDark
              ? AppColors.info500.withValues(alpha: 0.15)
              : AppColors.info50,
        ),
      BadgeVariant.neutral => _BadgeColors(
          foreground: isDark ? AppColors.zinc400 : AppColors.slate600,
          background: isDark
              ? AppColors.zinc800
              : AppColors.slate100,
        ),
      BadgeVariant.primary => _BadgeColors(
          foreground: isDark ? AppColors.purple400 : AppColors.purple600,
          background: isDark
              ? AppColors.purple500.withValues(alpha: 0.15)
              : AppColors.purple50,
        ),
    };
  }

  _BadgeSizing _getSizing() {
    return switch (size) {
      BadgeSize.small => _BadgeSizing(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          textStyle: AppTypography.overline,
          iconSize: 10,
          spacing: AppSpacing.xxxs,
        ),
      BadgeSize.medium => _BadgeSizing(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          textStyle: AppTypography.labelSmall,
          iconSize: 12,
          spacing: AppSpacing.xxxs,
        ),
      BadgeSize.large => _BadgeSizing(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          textStyle: AppTypography.labelMedium,
          iconSize: 14,
          spacing: AppSpacing.xxs,
        ),
    };
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.foreground,
    required this.background,
  });

  final Color foreground;
  final Color background;
}

class _BadgeSizing {
  const _BadgeSizing({
    required this.padding,
    required this.textStyle,
    required this.iconSize,
    required this.spacing,
  });

  final EdgeInsets padding;
  final TextStyle textStyle;
  final double iconSize;
  final double spacing;
}
