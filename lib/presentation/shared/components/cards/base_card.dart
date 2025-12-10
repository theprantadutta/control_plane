import 'package:flutter/material.dart';

import '../../../../config/theme/app_animations.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_radius.dart';
import '../../../../config/theme/app_shadows.dart';
import '../../../../config/theme/app_spacing.dart';

/// A base card component with hover effects and consistent styling.
/// Foundation for all card variants in the design system.
class BaseCard extends StatefulWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.enableHover = true,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final bool enableHover;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool elevated;

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor = widget.backgroundColor ??
        (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final effectiveBorderColor = widget.selected
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : widget.borderColor ??
            (isDark ? AppColors.borderDark : AppColors.borderLight);

    final effectiveBorderWidth = widget.selected ? 2.0 : widget.borderWidth;

    final shadows = widget.elevated || _isHovered
        ? AppShadows.getShadow(ShadowElevation.md, isDark: isDark)
        : AppShadows.getShadow(ShadowElevation.sm, isDark: isDark);

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: widget.enableHover ? (_) => setState(() => _isHovered = true) : null,
        onExit: widget.enableHover ? (_) => setState(() => _isHovered = false) : null,
        child: AnimatedContainer(
          duration: AppAnimations.hoverDuration,
          curve: AppAnimations.hoverCurve,
          transform: _isHovered && widget.enableHover
              ? Matrix4.diagonal3Values(1.01, 1.01, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: widget.borderRadius ?? AppRadius.card,
            border: Border.all(
              color: effectiveBorderColor,
              width: effectiveBorderWidth,
            ),
            boxShadow: shadows,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: widget.borderRadius ?? AppRadius.card,
              child: Padding(
                padding: widget.padding ?? AppSpacing.cardPadding,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
