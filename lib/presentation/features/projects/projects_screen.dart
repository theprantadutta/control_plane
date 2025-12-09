import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';

/// Projects provider
final projectsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) return null;

  return api.getProjects();
});

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(apiConfigProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(projectsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: config.isConfigured
          ? FloatingActionButton(
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      body: !config.isConfigured
          ? _buildConfigurePrompt(context)
          : projectsAsync.when(
              data: (data) {
                if (data == null) return _buildConfigurePrompt(context);
                return _buildProjectsList(context, ref, data);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildError(context, ref, error),
            ),
    );
  }

  Widget _buildConfigurePrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Configure API Connection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Settings to configure your Freeway API endpoint and admin key.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load projects',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(projectsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList(
      BuildContext context, WidgetRef ref, List<Project> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Projects Yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first project to get started.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _ProjectTile(
          project: project,
          onEdit: () => _showEditDialog(context, ref, project),
          onRotateKey: () => _showRotateKeyDialog(context, ref, project),
          onDelete: () => _showDeleteDialog(context, ref, project),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final rateLimitController = TextEditingController(text: '60');
    // Store the parent context before showing the dialog
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                hintText: 'My Project',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rateLimitController,
              decoration: const InputDecoration(
                labelText: 'Rate Limit (per minute)',
                hintText: '60',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;

              Navigator.of(dialogContext).pop();

              try {
                final api = ref.read(freewayApiProvider);
                final project = await api.createProject(
                  name: nameController.text,
                  rateLimitPerMinute:
                      int.tryParse(rateLimitController.text) ?? 60,
                );

                ref.invalidate(projectsProvider);

                // Show the API key dialog - use parentContext since dialogContext is popped
                if (parentContext.mounted && project.apiKey != null && project.apiKey!.isNotEmpty) {
                  _showApiKeyDialog(parentContext, project.apiKey!);
                } else if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(
                      content: Text('Project created but API key was not returned. Try rotating the key.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Failed to create project: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Project project) {
    final nameController = TextEditingController(text: project.name);
    final rateLimitController =
        TextEditingController(text: project.rateLimitPerMinute.toString());
    var isActive = project.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateLimitController,
                decoration: const InputDecoration(
                  labelText: 'Rate Limit (per minute)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: isActive,
                onChanged: (value) => setState(() => isActive = value),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  final api = ref.read(freewayApiProvider);
                  await api.updateProject(
                    project.id,
                    name: nameController.text,
                    isActive: isActive,
                    rateLimitPerMinute:
                        int.tryParse(rateLimitController.text) ?? 60,
                  );

                  ref.invalidate(projectsProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Project updated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update project: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRotateKeyDialog(
      BuildContext context, WidgetRef ref, Project project) {
    // Store the parent context before showing the dialog
    final parentContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rotate API Key'),
        content: Text(
          'This will invalidate the current API key for "${project.name}" and generate a new one. '
          'Any applications using the old key will stop working.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                final api = ref.read(freewayApiProvider);
                final result = await api.rotateApiKey(project.id);

                ref.invalidate(projectsProvider);

                // Use parentContext to show the API key dialog
                if (parentContext.mounted && result.apiKey.isNotEmpty) {
                  _showApiKeyDialog(parentContext, result.apiKey);
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('Failed to rotate key: $e')),
                  );
                }
              }
            },
            child: const Text('Rotate Key'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
          'Are you sure you want to delete "${project.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                final api = ref.read(freewayApiProvider);
                await api.deleteProject(project.id);

                ref.invalidate(projectsProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project deleted')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete project: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, String apiKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Save Your API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is your API key. It will only be shown once!\n'
              'Store it securely.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      apiKey,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: apiKey));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('API key copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I have saved the key'),
          ),
        ],
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onRotateKey;
  final VoidCallback onDelete;

  const _ProjectTile({
    required this.project,
    required this.onEdit,
    required this.onRotateKey,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: project.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    project.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: project.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoItem(
                  icon: Icons.key,
                  label: 'Key prefix: ${project.apiKeyPrefix}',
                ),
                const SizedBox(width: 16),
                _InfoItem(
                  icon: Icons.speed,
                  label: '${project.rateLimitPerMinute}/min',
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.calendar_today,
              label: 'Created: ${dateFormat.format(project.createdAt)}',
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onRotateKey,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Rotate Key'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
                  label: Text('Delete',
                      style: TextStyle(color: Colors.red.shade400)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
