import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';

/// A key-value detail row component for displaying information.
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 120,
    this.selectable = false,
    this.monospace = false,
    this.trailing,
    this.isError = false,
    this.copyable = false,
  });

  final String label;
  final String value;
  final double labelWidth;
  final bool selectable;
  final bool monospace;
  final Widget? trailing;
  final bool isError;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final labelColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final valueColor = isError
        ? (isDark ? AppColors.errorDark : AppColors.errorLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final valueStyle = monospace
        ? AppTypography.codeMedium.copyWith(color: valueColor)
        : AppTypography.bodyMedium.copyWith(color: valueColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          AppSpacing.gapH12,
          Expanded(
            child: selectable
                ? SelectableText(value, style: valueStyle)
                : Text(value, style: valueStyle),
          ),
          if (copyable) ...[
            AppSpacing.gapH8,
            _CopyButton(value: value),
          ],
          if (trailing != null) ...[
            AppSpacing.gapH8,
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.value});

  final String value;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IconButton(
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey(_copied),
          size: 16,
          color: _copied
              ? AppColors.successLight
              : (isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight),
        ),
      ),
      tooltip: _copied ? 'Copied!' : 'Copy',
      iconSize: 16,
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
      padding: EdgeInsets.zero,
    );
  }
}
