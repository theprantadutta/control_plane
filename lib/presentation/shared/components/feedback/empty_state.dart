import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';

/// Size variants for empty state
enum EmptyStateSize { compact, normal, large }

/// An empty state component for displaying when no content is available.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.size = EmptyStateSize.normal,
  });

  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  final EmptyStateSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sizing = _getSizing();

    return Center(
      child: Padding(
        padding: sizing.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(sizing.iconPadding),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: sizing.iconSize,
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: sizing.spacing),
            Text(
              title,
              style: sizing.titleStyle.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: sizing.descriptionSpacing),
              Text(
                description!,
                style: sizing.descriptionStyle.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: sizing.actionSpacing),
              action!,
            ],
          ],
        ),
      ),
    );
  }

  _EmptyStateSizing _getSizing() {
    return switch (size) {
      EmptyStateSize.compact => _EmptyStateSizing(
          padding: AppSpacing.insetSm,
          iconSize: 32,
          iconPadding: 12,
          spacing: AppSpacing.sm,
          descriptionSpacing: AppSpacing.xxs,
          actionSpacing: AppSpacing.sm,
          titleStyle: AppTypography.titleSmall,
          descriptionStyle: AppTypography.bodySmall,
        ),
      EmptyStateSize.normal => _EmptyStateSizing(
          padding: AppSpacing.insetLg,
          iconSize: 48,
          iconPadding: 16,
          spacing: AppSpacing.lg,
          descriptionSpacing: AppSpacing.xs,
          actionSpacing: AppSpacing.lg,
          titleStyle: AppTypography.titleMedium,
          descriptionStyle: AppTypography.bodyMedium,
        ),
      EmptyStateSize.large => _EmptyStateSizing(
          padding: AppSpacing.insetXl,
          iconSize: 64,
          iconPadding: 20,
          spacing: AppSpacing.xl,
          descriptionSpacing: AppSpacing.sm,
          actionSpacing: AppSpacing.xl,
          titleStyle: AppTypography.titleLarge,
          descriptionStyle: AppTypography.bodyLarge,
        ),
    };
  }
}

class _EmptyStateSizing {
  const _EmptyStateSizing({
    required this.padding,
    required this.iconSize,
    required this.iconPadding,
    required this.spacing,
    required this.descriptionSpacing,
    required this.actionSpacing,
    required this.titleStyle,
    required this.descriptionStyle,
  });

  final EdgeInsets padding;
  final double iconSize;
  final double iconPadding;
  final double spacing;
  final double descriptionSpacing;
  final double actionSpacing;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
}
