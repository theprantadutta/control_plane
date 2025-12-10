import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../shared/components/data_display/app_badge.dart';
import '../../shared/components/feedback/empty_state.dart';
import '../../shared/components/feedback/error_state.dart';
import '../../shared/widgets/animated_list_item.dart';
import '../../shared/widgets/shimmer_loading.dart';
import 'project_details_screen.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(projectsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: config.isConfigured
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create'),
              backgroundColor:
                  isDark ? AppColors.primaryDark : AppColors.primaryLight,
              foregroundColor: isDark ? AppColors.slate900 : Colors.white,
            )
          : null,
      body: !config.isConfigured
          ? const EmptyState(
              icon: Icons.settings_outlined,
              title: 'Configure API Connection',
              description:
                  'Go to Settings to configure your Freeway API endpoint and admin key.',
            )
          : projectsAsync.when(
              data: (data) {
                if (data == null) {
                  return const EmptyState(
                    icon: Icons.cloud_off_rounded,
                    title: 'Not Configured',
                    description: 'API connection is not configured.',
                  );
                }
                return _buildProjectsList(context, ref, data, isDark);
              },
              loading: () => _buildLoadingState(),
              error: (error, _) => ErrorState(
                title: 'Failed to load projects',
                message: error.toString(),
                onRetry: () => ref.invalidate(projectsProvider),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: 4,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerCard(height: 180),
      ),
    );
  }

  Widget _buildProjectsList(
    BuildContext context,
    WidgetRef ref,
    List<Project> projects,
    bool isDark,
  ) {
    if (projects.isEmpty) {
      return EmptyState(
        icon: Icons.folder_off_rounded,
        title: 'No Projects Yet',
        description: 'Create your first project to get started.',
        action: FilledButton.icon(
          onPressed: () => _showCreateDialog(context, ref),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Create Project'),
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.screenPadding,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ScaleInCard(
          index: index,
          child: _ProjectCard(
            project: project,
            isDark: isDark,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProjectDetailsScreen(project: project),
              ),
            ),
            onEdit: () => _showEditDialog(context, ref, project),
            onRotateKey: () => _showRotateKeyDialog(context, ref, project),
            onDelete: () => _showDeleteDialog(context, ref, project),
          ),
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final rateLimitController = TextEditingController(text: '60');
    final parentContext = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                    .withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.folder_rounded,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                size: 20,
              ),
            ),
            AppSpacing.gapH12,
            Text(
              'Create Project',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StyledTextField(
              controller: nameController,
              label: 'Project Name',
              hint: 'My Project',
              isDark: isDark,
              autofocus: true,
            ),
            AppSpacing.gapV16,
            _StyledTextField(
              controller: rateLimitController,
              label: 'Rate Limit (per minute)',
              hint: '60',
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
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

                if (parentContext.mounted &&
                    project.apiKey != null &&
                    project.apiKey!.isNotEmpty) {
                  _showApiKeyDialog(parentContext, project.apiKey!);
                } else if (parentContext.mounted) {
                  _showSnackBar(
                    parentContext,
                    'Project created but API key was not returned.',
                    isWarning: true,
                  );
                }
              } catch (e) {
                if (parentContext.mounted) {
                  _showSnackBar(
                    parentContext,
                    'Failed to create project: $e',
                    isError: true,
                  );
                }
              }
            },
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.secondaryDark
                          : AppColors.secondaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: isDark
                      ? AppColors.secondaryDark
                      : AppColors.secondaryLight,
                  size: 20,
                ),
              ),
              AppSpacing.gapH12,
              Text(
                'Edit Project',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StyledTextField(
                controller: nameController,
                label: 'Project Name',
                hint: '',
                isDark: isDark,
              ),
              AppSpacing.gapV16,
              _StyledTextField(
                controller: rateLimitController,
                label: 'Rate Limit (per minute)',
                hint: '60',
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapV16,
              Container(
                padding: AppSpacing.insetSm,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceOverlayDark
                      : AppColors.surfaceOverlayLight,
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.power_settings_new_rounded,
                      size: 20,
                      color: isActive
                          ? AppColors.success500
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                    AppSpacing.gapH12,
                    Expanded(
                      child: Text(
                        'Project Status',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Switch.adaptive(
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      activeTrackColor: isDark
                          ? AppColors.success400
                          : AppColors.success600,
                      activeThumbColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
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
                    _showSnackBar(context, 'Project updated successfully');
                  }
                } catch (e) {
                  if (context.mounted) {
                    _showSnackBar(
                      context,
                      'Failed to update project: $e',
                      isError: true,
                    );
                  }
                }
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRotateKeyDialog(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    final parentContext = context;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning500.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.warning500,
                size: 20,
              ),
            ),
            AppSpacing.gapH12,
            Text(
              'Rotate API Key',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Text(
          'This will invalidate the current API key for "${project.name}" and generate a new one.\n\n'
          'Any applications using the old key will stop working.',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                final api = ref.read(freewayApiProvider);
                final result = await api.rotateApiKey(project.id);

                ref.invalidate(projectsProvider);

                if (parentContext.mounted && result.apiKey.isNotEmpty) {
                  _showApiKeyDialog(parentContext, result.apiKey);
                }
              } catch (e) {
                if (parentContext.mounted) {
                  _showSnackBar(
                    parentContext,
                    'Failed to rotate key: $e',
                    isError: true,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning500,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Rotate Key'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error500.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error500,
                size: 20,
              ),
            ),
            AppSpacing.gapH12,
            Text(
              'Delete Project',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"?\n\n'
          'This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();

              try {
                final api = ref.read(freewayApiProvider);
                await api.deleteProject(project.id);

                ref.invalidate(projectsProvider);

                if (context.mounted) {
                  _showSnackBar(context, 'Project deleted');
                }
              } catch (e) {
                if (context.mounted) {
                  _showSnackBar(
                    context,
                    'Failed to delete project: $e',
                    isError: true,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error500,
            ),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, String apiKey) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning500.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Icon(
                Icons.key_rounded,
                color: AppColors.warning500,
                size: 20,
              ),
            ),
            AppSpacing.gapH12,
            Text(
              'Save Your API Key',
              style: AppTypography.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.insetSm,
              decoration: BoxDecoration(
                color: AppColors.warning500.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: AppColors.warning500.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_rounded,
                    color: AppColors.warning500,
                    size: 18,
                  ),
                  AppSpacing.gapH8,
                  Expanded(
                    child: Text(
                      'This key will only be shown once!',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.warning600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapV16,
            Container(
              padding: AppSpacing.insetSm,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceOverlayDark
                    : AppColors.surfaceOverlayLight,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      apiKey,
                      style: AppTypography.codeMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: apiKey));
                      _showSnackBar(context, 'API key copied to clipboard');
                    },
                    tooltip: 'Copy',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('I have saved the key'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    final color = isError
        ? AppColors.error500
        : isWarning
            ? AppColors.warning500
            : AppColors.success500;
    final icon = isError
        ? Icons.error_rounded
        : isWarning
            ? Icons.warning_rounded
            : Icons.check_circle_rounded;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            AppSpacing.gapH8,
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Project project;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onRotateKey;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onRotateKey,
    required this.onDelete,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.01, 1.01, 1.0)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: widget.isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (widget.isDark
                              ? AppColors.primaryDark
                              : AppColors.primaryLight)
                          .withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.card,
              onTap: widget.onTap,
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (widget.isDark
                                    ? AppColors.primaryDark
                                    : AppColors.primaryLight)
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadius.radiusMd,
                          ),
                          child: Icon(
                            Icons.folder_rounded,
                            color: widget.isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                            size: 20,
                          ),
                        ),
                        AppSpacing.gapH12,
                        Expanded(
                          child: Text(
                            widget.project.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        AppBadge(
                          label: widget.project.isActive ? 'Active' : 'Inactive',
                          variant: widget.project.isActive
                              ? BadgeVariant.success
                              : BadgeVariant.neutral,
                          icon: widget.project.isActive
                              ? Icons.check_circle_rounded
                              : Icons.pause_circle_rounded,
                          size: BadgeSize.medium,
                        ),
                      ],
                    ),
                    AppSpacing.gapV16,

                    // Info chips
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _ProjectInfoChip(
                          icon: Icons.key_rounded,
                          label: widget.project.apiKeyPrefix,
                          isDark: widget.isDark,
                        ),
                        _ProjectInfoChip(
                          icon: Icons.speed_rounded,
                          label: '${widget.project.rateLimitPerMinute}/min',
                          isDark: widget.isDark,
                        ),
                        _ProjectInfoChip(
                          icon: Icons.calendar_today_rounded,
                          label: dateFormat.format(widget.project.createdAt),
                          isDark: widget.isDark,
                        ),
                      ],
                    ),
                    AppSpacing.gapV16,

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _ActionButton(
                          icon: Icons.edit_rounded,
                          label: 'Edit',
                          onTap: widget.onEdit,
                          isDark: widget.isDark,
                        ),
                        AppSpacing.gapH8,
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'Rotate Key',
                          onTap: widget.onRotateKey,
                          isDark: widget.isDark,
                        ),
                        AppSpacing.gapH8,
                        _ActionButton(
                          icon: Icons.delete_rounded,
                          label: 'Delete',
                          onTap: widget.onDelete,
                          isDark: widget.isDark,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _ProjectInfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.surfaceOverlayDark : AppColors.surfaceOverlayLight,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppColors.error500
        : (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: AppTypography.labelMedium,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final bool autofocus;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.autofocus = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        AppSpacing.gapV8,
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.surfaceOverlayDark
                : AppColors.surfaceOverlayLight,
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.radiusLg,
              borderSide: BorderSide(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
