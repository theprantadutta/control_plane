import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import 'base_card.dart';

/// Direction of the trend indicator
enum TrendDirection { up, down, neutral }

/// Data for displaying a trend indicator
class TrendData {
  const TrendData({
    required this.percentage,
    required this.direction,
    this.label,
  });

  final double percentage;
  final TrendDirection direction;
  final String? label;
}

/// A stat card component for displaying metrics with optional trend indicators.
/// Inspired by Stripe/Vercel dashboard stat cards.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.trend,
    this.subtitle,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final TrendData? trend;
  final String? subtitle;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    return BaseCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? AppSpacing.xs : AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(compact ? 6 : 8),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: compact ? 16 : 20,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: (compact ? AppTypography.statSmall : AppTypography.statMedium)
                .copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTypography.caption.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ],
          if (trend != null) ...[
            const SizedBox(height: 4),
            _buildTrend(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTrend(BuildContext context) {
    final color = switch (trend!.direction) {
      TrendDirection.up => AppColors.successLight,
      TrendDirection.down => AppColors.errorLight,
      TrendDirection.neutral => AppColors.slate400,
    };

    final iconData = switch (trend!.direction) {
      TrendDirection.up => Icons.trending_up,
      TrendDirection.down => Icons.trending_down,
      TrendDirection.neutral => Icons.remove,
    };

    return Row(
      children: [
        Icon(iconData, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '${trend!.percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (trend!.label != null) ...[
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              trend!.label!,
              style: AppTypography.caption.copyWith(
                color: AppColors.slate400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
