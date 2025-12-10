import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../shared/components/cards/stat_card.dart';
import '../../shared/components/data_display/app_badge.dart';
import '../../shared/components/feedback/empty_state.dart';
import '../../shared/components/feedback/error_state.dart';
import '../../shared/components/navigation/section_header.dart';
import '../../shared/widgets/animated_list_item.dart';
import '../../shared/widgets/shimmer_loading.dart';

/// Dashboard data provider
final dashboardDataProvider = FutureProvider.autoDispose((ref) async {
  final api = ref.watch(freewayApiProvider);
  final config = ref.watch(apiConfigProvider);

  if (!config.isConfigured) {
    return null;
  }

  try {
    final freeModel = await api.getSelectedFreeModel();
    final paidModel = await api.getSelectedPaidModel();
    final summary = await api.getGlobalSummary();

    return {
      'freeModel': freeModel,
      'paidModel': paidModel,
      'summary': summary,
    };
  } catch (e) {
    rethrow;
  }
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(apiConfigProvider);
    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(dashboardDataProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !config.isConfigured
          ? _buildConfigurePrompt(context)
          : dashboardData.when(
              data: (data) => data == null
                  ? _buildConfigurePrompt(context)
                  : _buildDashboard(context, data),
              loading: () => _buildLoading(context),
              error: (error, _) => _buildError(context, ref, error),
            ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerStatsGrid(count: 4),
          AppSpacing.gapV24,
          const ShimmerLoading(width: 150, height: 24),
          AppSpacing.gapV12,
          Row(
            children: const [
              Expanded(child: ShimmerCard(height: 160)),
              SizedBox(width: 12),
              Expanded(child: ShimmerCard(height: 160)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurePrompt(BuildContext context) {
    return EmptyState(
      icon: Icons.settings_outlined,
      title: 'Configure API Connection',
      description:
          'Go to Settings to configure your Freeway API endpoint and admin key.',
      action: FilledButton.icon(
        onPressed: () {
          // Navigate to settings - handled by parent navigation
        },
        icon: const Icon(Icons.settings_rounded, size: 18),
        label: const Text('Open Settings'),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return ErrorState(
      title: 'Failed to load dashboard',
      message: error.toString(),
      onRetry: () => ref.invalidate(dashboardDataProvider),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data) {
    final freeModel = data['freeModel'] as SelectedModelResponse;
    final paidModel = data['paidModel'] as SelectedModelResponse;
    final summary = data['summary'] as GlobalSummary;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards with staggered animation
          _buildStatsSection(context, summary, isDark),
          AppSpacing.gapV32,

          // Selected models section
          SectionHeader(
            title: 'Selected Models',
            subtitle: 'Currently active AI models',
            icon: Icons.auto_awesome_rounded,
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          AppSpacing.gapV12,
          _buildModelsSection(context, freeModel, paidModel, isDark),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, GlobalSummary summary, bool isDark) {
    final stats = [
      _StatData(
        'Total Projects',
        summary.totalProjects.toString(),
        Icons.folder_rounded,
        isDark ? AppColors.purple400 : AppColors.purple600,
      ),
      _StatData(
        'Active Projects',
        summary.activeProjects.toString(),
        Icons.check_circle_rounded,
        isDark ? AppColors.success400 : AppColors.success600,
      ),
      _StatData(
        'Requests Today',
        _formatNumber(summary.totalRequestsToday),
        Icons.trending_up_rounded,
        isDark ? AppColors.info400 : AppColors.info600,
      ),
      _StatData(
        'Cost This Month',
        '\$${summary.totalCostThisMonthUsd.toStringAsFixed(2)}',
        Icons.payments_rounded,
        isDark ? AppColors.warning400 : AppColors.warning600,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.xs,
          crossAxisSpacing: AppSpacing.xs,
          childAspectRatio: 1.5,
          children: stats.asMap().entries.map((entry) {
            return ScaleInCard(
              index: entry.key,
              child: StatCard(
                title: entry.value.title,
                value: entry.value.value,
                icon: entry.value.icon,
                iconColor: entry.value.color,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildModelsSection(
    BuildContext context,
    SelectedModelResponse freeModel,
    SelectedModelResponse paidModel,
    bool isDark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ScaleInCard(
                  index: 4,
                  child: _ModelCard(
                    title: 'Free Model',
                    model: freeModel,
                    variant: BadgeVariant.success,
                    isDark: isDark,
                  ),
                ),
              ),
              AppSpacing.gapH12,
              Expanded(
                child: ScaleInCard(
                  index: 5,
                  child: _ModelCard(
                    title: 'Paid Model',
                    model: paidModel,
                    variant: BadgeVariant.primary,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            ScaleInCard(
              index: 4,
              child: _ModelCard(
                title: 'Free Model',
                model: freeModel,
                variant: BadgeVariant.success,
                isDark: isDark,
              ),
            ),
            AppSpacing.gapV12,
            ScaleInCard(
              index: 5,
              child: _ModelCard(
                title: 'Paid Model',
                model: paidModel,
                variant: BadgeVariant.primary,
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatData(this.title, this.value, this.icon, this.color);
}

class _ModelCard extends StatelessWidget {
  final String title;
  final SelectedModelResponse model;
  final BadgeVariant variant;
  final bool isDark;

  const _ModelCard({
    required this.title,
    required this.model,
    required this.variant,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppBadge(
                label: title,
                variant: variant,
                size: BadgeSize.medium,
              ),
              const Spacer(),
              _PulsingDot(
                color: variant == BadgeVariant.success
                    ? AppColors.success500
                    : AppColors.purple500,
              ),
            ],
          ),
          AppSpacing.gapV16,
          Text(
            model.modelName,
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.gapV8,
          Text(
            model.modelId,
            style: AppTypography.codeSmall.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.gapV12,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (model.contextLength != null)
                _InfoChip(
                  icon: Icons.memory_rounded,
                  label: '${_formatContextLength(model.contextLength!)} ctx',
                  isDark: isDark,
                ),
              _InfoChip(
                icon: Icons.attach_money_rounded,
                label: variant == BadgeVariant.success
                    ? 'Free'
                    : '\$${model.pricing.prompt}/M',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatContextLength(int length) {
    if (length >= 1000000) {
      return '${(length / 1000000).toStringAsFixed(0)}M';
    } else if (length >= 1000) {
      return '${(length / 1000).toStringAsFixed(0)}K';
    }
    return length.toString();
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceOverlayDark : AppColors.surfaceOverlayLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _animation.value * 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}
