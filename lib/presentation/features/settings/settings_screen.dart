import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../providers/theme_provider.dart';
import '../../shared/components/data_display/app_badge.dart';
import '../../shared/components/navigation/section_header.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isTestingConnection = false;
  bool _connectionSuccess = false;
  String? _connectionError;

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionSuccess = false;
      _connectionError = null;
    });

    try {
      final api = ref.read(freewayApiProvider);
      await api.getGlobalSummary();

      setState(() {
        _connectionSuccess = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection successful!'),
            backgroundColor: AppColors.success500,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _connectionError = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: AppColors.error500,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTestingConnection = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final config = ref.watch(apiConfigProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // API Configuration Section
          SectionHeader(
            title: 'API Configuration',
            subtitle: 'Connection settings from .env file',
            icon: Icons.dns_rounded,
          ),
          AppSpacing.gapV12,
          _buildConnectionCard(config, isDark),

          AppSpacing.gapV32,

          // Appearance Section
          SectionHeader(
            title: 'Appearance',
            subtitle: 'Customize the look and feel',
            icon: Icons.palette_rounded,
          ),
          AppSpacing.gapV12,
          _buildThemeCard(themeMode, isDark),

          AppSpacing.gapV32,

          // About Section
          SectionHeader(
            title: 'About',
            subtitle: 'App information',
            icon: Icons.info_rounded,
          ),
          AppSpacing.gapV12,
          _buildAboutCard(isDark),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(ApiConfig config, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.link_rounded,
            iconColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            title: 'API Endpoint',
            subtitle: config.endpoint.isNotEmpty
                ? config.endpoint
                : 'Not configured',
            isMonospace: true,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _SettingsTile(
            icon: Icons.key_rounded,
            iconColor: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
            title: 'Admin API Key',
            subtitle: config.apiKey.isNotEmpty
                ? '${config.apiKey.substring(0, 8)}${'•' * 8}'
                : 'Not configured',
            isMonospace: true,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                _ConnectionStatus(
                  isSuccess: _connectionSuccess,
                  hasError: _connectionError != null,
                  isConfigured: config.isConfigured,
                  isDark: isDark,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _isTestingConnection ? null : _testConnection,
                  icon: _isTestingConnection
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark
                                ? AppColors.slate900
                                : Colors.white,
                          ),
                        )
                      : const Icon(Icons.wifi_tethering_rounded, size: 18),
                  label: Text(
                    _isTestingConnection ? 'Testing...' : 'Test Connection',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(ThemeMode themeMode, bool isDark) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dark_mode_rounded,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  size: 20,
                ),
              ),
              AppSpacing.gapH12,
              Text(
                'Theme Mode',
                style: AppTypography.titleSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          AppSpacing.gapV20,
          _ThemeSelector(
            currentMode: themeMode,
            onChanged: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.auto_awesome_rounded,
            iconColor: isDark ? AppColors.purple400 : AppColors.purple600,
            title: 'Freeway Control Panel',
            subtitle: 'Version 1.0.0',
            isDark: isDark,
          ),
          Divider(
            height: 1,
            indent: 56,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _SettingsTile(
            icon: Icons.flutter_dash,
            iconColor: AppColors.info500,
            title: 'Built with Flutter',
            subtitle: 'Cross-platform mobile & desktop',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isMonospace;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isMonospace = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          AppSpacing.gapH12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: (isMonospace ? AppTypography.codeSmall : AppTypography.bodySmall)
                      .copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool isSuccess;
  final bool hasError;
  final bool isConfigured;
  final bool isDark;

  const _ConnectionStatus({
    required this.isSuccess,
    required this.hasError,
    required this.isConfigured,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    BadgeVariant variant;
    IconData icon;
    String text;

    if (isSuccess) {
      variant = BadgeVariant.success;
      icon = Icons.check_circle_rounded;
      text = 'Connected';
    } else if (hasError) {
      variant = BadgeVariant.error;
      icon = Icons.error_rounded;
      text = 'Failed';
    } else if (isConfigured) {
      variant = BadgeVariant.neutral;
      icon = Icons.radio_button_unchecked_rounded;
      text = 'Ready';
    } else {
      variant = BadgeVariant.warning;
      icon = Icons.warning_amber_rounded;
      text = 'Not configured';
    }

    return AppBadge(
      label: text,
      variant: variant,
      icon: icon,
      size: BadgeSize.medium,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;
  final bool isDark;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: currentMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
            isDark: isDark,
          ),
        ),
        AppSpacing.gapH8,
        Expanded(
          child: _ThemeOption(
            icon: Icons.brightness_auto_rounded,
            label: 'System',
            isSelected: currentMode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
            isDark: isDark,
          ),
        ),
        AppSpacing.gapH8,
        Expanded(
          child: _ThemeOption(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedBg = isDark ? AppColors.purple900 : AppColors.purple100;
    final unselectedBg = isDark
        ? AppColors.surfaceOverlayDark
        : AppColors.surfaceOverlayLight;
    final selectedColor = isDark ? AppColors.purple300 : AppColors.purple700;
    final unselectedColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Material(
      color: isSelected ? selectedBg : unselectedBg,
      borderRadius: AppRadius.radiusLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: AppRadius.radiusLg,
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.purple400 : AppColors.purple300)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
