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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Configuration Section (read-only from .env)
            _buildSectionHeader(context, 'API Configuration'),
            const SizedBox(height: 8),
            Text(
              'Loaded from .env file',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ConfigItem(
                      label: 'API Endpoint',
                      value: config.endpoint,
                      icon: Icons.link,
                    ),
                    const Divider(height: 24),
                    _ConfigItem(
                      label: 'Admin API Key',
                      value: config.apiKey.isNotEmpty
                          ? '${config.apiKey.substring(0, 8)}...'
                          : 'Not configured',
                      icon: Icons.key,
                      isSecret: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_connectionSuccess)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                        if (_connectionError != null)
                          const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionSuccess
                                ? 'Connected'
                                : _connectionError != null
                                    ? 'Connection failed'
                                    : config.isConfigured
                                        ? 'Ready to connect'
                                        : 'Not configured',
                            style: TextStyle(
                              color: _connectionSuccess
                                  ? Colors.green
                                  : _connectionError != null
                                      ? Colors.red
                                      : null,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed:
                              _isTestingConnection ? null : _testConnection,
                          icon: _isTestingConnection
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.wifi_tethering),
                          label: Text(_isTestingConnection
                              ? 'Testing...'
                              : 'Test Connection'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Theme'),
                    subtitle: Text(_getThemeModeLabel(themeMode)),
                    trailing: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // About Section
            _buildSectionHeader(context, 'About'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Freeway Control Panel'),
                    subtitle: Text('Version 1.0.0'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.code),
                    title: Text('Built with Flutter'),
                    subtitle: Text('Cross-platform control panel'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }
}

class _ConfigItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSecret;

  const _ConfigItem({
    required this.label,
    required this.value,
    required this.icon,
    this.isSecret = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: isSecret ? null : 'monospace',
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
