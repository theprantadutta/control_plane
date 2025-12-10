import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../shared/components/data_display/app_badge.dart';
import '../../shared/components/data_display/detail_row.dart';
import '../../shared/components/feedback/empty_state.dart';
import '../../shared/components/feedback/error_state.dart';
import '../../shared/widgets/animated_list_item.dart';
import '../../shared/widgets/shimmer_loading.dart';

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Free models provider
final freeModelsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) return null;

  return api.getAllFreeModels();
});

/// Paid models provider
final paidModelsProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) return null;

  return api.getAllPaidModels();
});

/// Selected free model provider
final selectedFreeModelProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) return null;

  return api.getSelectedFreeModel();
});

/// Selected paid model provider
final selectedPaidModelProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) return null;

  return api.getSelectedPaidModel();
});

class ModelsScreen extends ConsumerStatefulWidget {
  const ModelsScreen({super.key});

  @override
  ConsumerState<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends ConsumerState<ModelsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(freeModelsProvider);
    ref.invalidate(paidModelsProvider);
    ref.invalidate(selectedFreeModelProvider);
    ref.invalidate(selectedPaidModelProvider);
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(apiConfigProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!config.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Models')),
        body: EmptyState(
          icon: Icons.settings_outlined,
          title: 'Configure API Connection',
          description:
              'Go to Settings to configure your Freeway API endpoint and admin key.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshAll,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(isDark),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _FreeModelsTab(),
                _PaidModelsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final freeModels = ref.watch(freeModelsProvider);
    final paidModels = ref.watch(paidModelsProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceOverlayDark
            : AppColors.surfaceOverlayLight,
        borderRadius: AppRadius.radiusXl,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          borderRadius: AppRadius.radiusXl,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? AppColors.slate900 : Colors.white,
        unselectedLabelColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 18),
                AppSpacing.gapH8,
                const Text('Free'),
                if (freeModels.hasValue && freeModels.value != null) ...[
                  AppSpacing.gapH6,
                  _TabCount(
                    count: freeModels.value!.models.length,
                    isSelected: _tabController.index == 0,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond_rounded, size: 18),
                AppSpacing.gapH8,
                const Text('Paid'),
                if (paidModels.hasValue && paidModels.value != null) ...[
                  AppSpacing.gapH6,
                  _TabCount(
                    count: paidModels.value!.models.length,
                    isSelected: _tabController.index == 1,
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: AppSpacing.cardPadding,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: TextField(
          controller: _searchController,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search models...',
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() {});
            ref.read(searchQueryProvider.notifier).state = value;
          },
        ),
      ),
    );
  }
}

class _TabCount extends StatelessWidget {
  final int count;
  final bool isSelected;
  final bool isDark;

  const _TabCount({
    required this.count,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        count.toString(),
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected
              ? (isDark ? AppColors.slate900 : Colors.white)
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
      ),
    );
  }
}

class _FreeModelsTab extends ConsumerWidget {
  const _FreeModelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(freeModelsProvider);
    final selectedAsync = ref.watch(selectedFreeModelProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    final selectedModelId = selectedAsync.whenOrNull(data: (d) => d?.modelId);

    return modelsAsync.when(
      data: (data) {
        if (data == null) {
          return const EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Not Configured',
            description: 'API connection is not configured.',
          );
        }

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _ModelsList(
          models: filtered,
          isFree: true,
          selectedModelId: selectedModelId,
          searchQuery: searchQuery,
          onSelectModel: (model) => _selectModel(context, ref, model),
        );
      },
      loading: () => const _ModelsLoadingState(),
      error: (error, _) => ErrorState(
        title: 'Failed to load models',
        message: error.toString(),
        onRetry: () => ref.invalidate(freeModelsProvider),
      ),
    );
  }

  Future<void> _selectModel(
    BuildContext context,
    WidgetRef ref,
    ModelInfo model,
  ) async {
    final api = ref.read(freewayApiProvider);

    try {
      final result = await api.setSelectedFreeModel(model.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                AppSpacing.gapH8,
                Expanded(child: Text(result.message)),
              ],
            ),
            backgroundColor: AppColors.success500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
        ref.invalidate(selectedFreeModelProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                AppSpacing.gapH8,
                Expanded(child: Text('Failed to select model: $e')),
              ],
            ),
            backgroundColor: AppColors.error500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
      }
    }
  }
}

class _PaidModelsTab extends ConsumerWidget {
  const _PaidModelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(paidModelsProvider);
    final selectedAsync = ref.watch(selectedPaidModelProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    final selectedModelId = selectedAsync.whenOrNull(data: (d) => d?.modelId);

    return modelsAsync.when(
      data: (data) {
        if (data == null) {
          return const EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Not Configured',
            description: 'API connection is not configured.',
          );
        }

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _ModelsList(
          models: filtered,
          isFree: false,
          selectedModelId: selectedModelId,
          searchQuery: searchQuery,
          onSelectModel: (model) => _selectModel(context, ref, model),
        );
      },
      loading: () => const _ModelsLoadingState(),
      error: (error, _) => ErrorState(
        title: 'Failed to load models',
        message: error.toString(),
        onRetry: () => ref.invalidate(paidModelsProvider),
      ),
    );
  }

  Future<void> _selectModel(
    BuildContext context,
    WidgetRef ref,
    ModelInfo model,
  ) async {
    final api = ref.read(freewayApiProvider);

    try {
      final result = await api.setSelectedPaidModel(model.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                AppSpacing.gapH8,
                Expanded(child: Text(result.message)),
              ],
            ),
            backgroundColor: AppColors.success500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
        ref.invalidate(selectedPaidModelProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white, size: 20),
                AppSpacing.gapH8,
                Expanded(child: Text('Failed to select model: $e')),
              ],
            ),
            backgroundColor: AppColors.error500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          ),
        );
      }
    }
  }
}

class _ModelsLoadingState extends StatelessWidget {
  const _ModelsLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSpacing.cardPadding,
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerCard(height: 140),
      ),
    );
  }
}

class _ModelsList extends StatelessWidget {
  final List<ModelInfo> models;
  final bool isFree;
  final String? selectedModelId;
  final String searchQuery;
  final Function(ModelInfo) onSelectModel;

  const _ModelsList({
    required this.models,
    required this.isFree,
    required this.selectedModelId,
    required this.searchQuery,
    required this.onSelectModel,
  });

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: searchQuery.isNotEmpty ? 'No Results' : 'No Models',
        description: searchQuery.isNotEmpty
            ? 'No models match your search "$searchQuery"'
            : 'No models available in this category.',
      );
    }

    return ListView.builder(
      padding: AppSpacing.cardPadding,
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        final isSelected = model.id == selectedModelId;

        return ScaleInCard(
          index: index,
          child: _ModelCard(
            model: model,
            isFree: isFree,
            isSelected: isSelected,
            onSelect: () => onSelectModel(model),
          ),
        );
      },
    );
  }
}

class _ModelCard extends StatefulWidget {
  final ModelInfo model;
  final bool isFree;
  final bool isSelected;
  final VoidCallback? onSelect;

  const _ModelCard({
    required this.model,
    required this.isFree,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<_ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<_ModelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = widget.isSelected
        ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

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
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.card,
            border: Border.all(
              color: borderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
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
              onTap: () => _showModelDetails(context),
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Status indicator
                        if (widget.isSelected)
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: _PulsingDot(
                              color: isDark
                                  ? AppColors.success400
                                  : AppColors.success600,
                            ),
                          ),
                        // Model name
                        Expanded(
                          child: Text(
                            widget.model.name,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Status badge
                        if (widget.isSelected)
                          AppBadge(
                            label: 'Active',
                            variant: BadgeVariant.success,
                            icon: Icons.check_circle_rounded,
                            size: BadgeSize.small,
                          )
                        else
                          AppBadge(
                            label: widget.isFree ? 'Free' : 'Paid',
                            variant: widget.isFree
                                ? BadgeVariant.success
                                : BadgeVariant.primary,
                            size: BadgeSize.small,
                          ),
                      ],
                    ),
                    AppSpacing.gapV8,

                    // Model ID
                    Text(
                      widget.model.id,
                      style: AppTypography.codeSmall.copyWith(
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapV12,

                    // Info chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (widget.model.contextLength != null)
                          _ModelInfoChip(
                            icon: Icons.memory_rounded,
                            label: _formatContextLength(widget.model.contextLength!),
                            isDark: isDark,
                          ),
                        _ModelInfoChip(
                          icon: Icons.payments_rounded,
                          label: widget.isFree
                              ? 'Free'
                              : '\$${widget.model.pricing.prompt}/M',
                          isDark: isDark,
                          color: widget.isFree ? AppColors.success500 : null,
                        ),
                        if (widget.model.description != null &&
                            widget.model.description!.isNotEmpty)
                          _ModelInfoChip(
                            icon: Icons.info_outline_rounded,
                            label: 'Details',
                            isDark: isDark,
                          ),
                      ],
                    ),

                    // Select button (if not selected)
                    if (!widget.isSelected && widget.onSelect != null) ...[
                      AppSpacing.gapV12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: widget.onSelect,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Select'),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatContextLength(int length) {
    if (length >= 1000000) {
      return '${(length / 1000000).toStringAsFixed(0)}M ctx';
    } else if (length >= 1000) {
      return '${(length / 1000).toStringAsFixed(0)}K ctx';
    }
    return '$length ctx';
  }

  void _showModelDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusXl),
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.model.name,
                style: AppTypography.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
            if (widget.isSelected)
              AppBadge(
                label: 'Active',
                variant: BadgeVariant.success,
                icon: Icons.check_circle_rounded,
                size: BadgeSize.medium,
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailRow(
                label: 'Model ID',
                value: widget.model.id,
                monospace: true,
                copyable: true,
              ),
              if (widget.model.contextLength != null)
                DetailRow(
                  label: 'Context Length',
                  value: '${widget.model.contextLength!.toString()} tokens',
                ),
              DetailRow(
                label: 'Prompt Price',
                value: widget.isFree ? 'Free' : '\$${widget.model.pricing.prompt}/M tokens',
              ),
              DetailRow(
                label: 'Completion Price',
                value: widget.isFree ? 'Free' : '\$${widget.model.pricing.completion}/M tokens',
              ),
              if (widget.model.description != null &&
                  widget.model.description!.isNotEmpty) ...[
                AppSpacing.gapV16,
                Text(
                  'Description',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                AppSpacing.gapV4,
                Text(
                  widget.model.description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          if (!widget.isSelected && widget.onSelect != null)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onSelect!();
              },
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Select Model'),
            ),
        ],
      ),
    );
  }
}

class _ModelInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _ModelInfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceOverlayDark
            : AppColors.surfaceOverlayLight,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
