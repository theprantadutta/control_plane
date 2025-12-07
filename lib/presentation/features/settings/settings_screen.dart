import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../providers/theme_provider.dart';

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
          const SnackBar(
            content: Text('Connection successful!'),
            backgroundColor: Colors.green,
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
            backgroundColor: Colors.red,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Configuration Section
          _SectionHeader(
            title: 'API Configuration',
            subtitle: 'Connection settings from .env file',
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.link,
                  iconColor: colorScheme.primary,
                  title: 'API Endpoint',
                  subtitle: config.endpoint.isNotEmpty
                      ? config.endpoint
                      : 'Not configured',
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.key,
                  iconColor: colorScheme.secondary,
                  title: 'Admin API Key',
                  subtitle: config.apiKey.isNotEmpty
                      ? '${config.apiKey.substring(0, 8)}...'
                      : 'Not configured',
                ),
                const Divider(height: 1, indent: 56),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _ConnectionStatus(
                        isSuccess: _connectionSuccess,
                        hasError: _connectionError != null,
                        isConfigured: config.isConfigured,
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed:
                            _isTestingConnection ? null : _testConnection,
                        icon: _isTestingConnection
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.wifi_tethering, size: 18),
                        label: Text(
                            _isTestingConnection ? 'Testing...' : 'Test'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          const _SectionHeader(
            title: 'Appearance',
            subtitle: 'Customize the look and feel',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Theme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ThemeSelector(
                    currentMode: themeMode,
                    onChanged: (mode) {
                      ref.read(themeModeProvider.notifier).setThemeMode(mode);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          const _SectionHeader(
            title: 'About',
            subtitle: 'App information',
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  iconColor: colorScheme.tertiary,
                  title: 'Freeway Control Panel',
                  subtitle: 'Version 1.0.0',
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.flutter_dash,
                  iconColor: Colors.blue,
                  title: 'Built with Flutter',
                  subtitle: 'Cross-platform mobile & desktop',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: title.contains('Endpoint') ? 'monospace' : null,
          fontSize: 13,
        ),
      ),
      trailing: trailing,
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final bool isSuccess;
  final bool hasError;
  final bool isConfigured;

  const _ConnectionStatus({
    required this.isSuccess,
    required this.hasError,
    required this.isConfigured,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String text;

    if (isSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
      text = 'Connected';
    } else if (hasError) {
      icon = Icons.error;
      color = Colors.red;
      text = 'Failed';
    } else if (isConfigured) {
      icon = Icons.radio_button_unchecked;
      color = Colors.grey;
      text = 'Ready';
    } else {
      icon = Icons.warning_amber;
      color = Colors.orange;
      text = 'Not configured';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            icon: Icons.light_mode,
            label: 'Light',
            isSelected: currentMode == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeOption(
            icon: Icons.brightness_auto,
            label: 'System',
            isSelected: currentMode == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ThemeOption(
            icon: Icons.dark_mode,
            label: 'Dark',
            isSelected: currentMode == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
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

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Use onPrimaryContainer for selected state (proper contrast on primaryContainer bg)
    final selectedColor = colorScheme.onPrimaryContainer;
    final unselectedColor = colorScheme.onSurfaceVariant;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? selectedColor : unselectedColor,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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
