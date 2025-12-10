import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';
import '../../../data/datasources/remote/freeway_api.dart';
import '../../shared/components/cards/stat_card.dart';
import '../../shared/components/data_display/app_badge.dart';
import '../../shared/components/data_display/detail_row.dart';
import '../../shared/components/feedback/empty_state.dart';
import '../../shared/components/navigation/section_header.dart';
import '../../shared/widgets/animated_list_item.dart';
import '../../shared/widgets/shimmer_loading.dart';

/// Provider for project usage data
final projectUsageProvider =
    FutureProvider.autoDispose.family<ProjectUsage, String>((ref, projectId) async {
  final api = ref.watch(freewayApiProvider);
  return api.getProjectUsage(projectId);
});

/// Provider for project logs
final projectLogsProvider =
    FutureProvider.autoDispose.family<UsageLogsResponse, String>((ref, projectId) async {
  final api = ref.watch(freewayApiProvider);
  return api.getProjectLogs(projectId, limit: 100);
});

class ProjectDetailsScreen extends ConsumerWidget {
  final Project project;

  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usageAsync = ref.watch(projectUsageProvider(project.id));
    final logsAsync = ref.watch(projectLogsProvider(project.id));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(projectUsageProvider(project.id));
              ref.invalidate(projectLogsProvider(project.id));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Info Header
            _ProjectInfoCard(project: project, isDark: isDark),
            AppSpacing.gapV24,

            // Usage Statistics
            usageAsync.when(
              data: (usage) => _UsageSection(usage: usage, isDark: isDark),
              loading: () => _buildUsageLoading(),
              error: (e, _) => _buildErrorCard(
                context,
                'Failed to load usage statistics',
                e.toString(),
                isDark,
              ),
            ),
            AppSpacing.gapV24,

            // Request Logs
            logsAsync.when(
              data: (logsResponse) =>
                  _LogsSection(logsResponse: logsResponse, isDark: isDark),
              loading: () => _buildLogsLoading(),
              error: (e, _) => _buildErrorCard(
                context,
                'Failed to load logs',
                e.toString(),
                isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerLoading(width: 150, height: 24),
        AppSpacing.gapV12,
        const ShimmerStatsGrid(count: 8),
      ],
    );
  }

  Widget _buildLogsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerLoading(width: 150, height: 24),
        AppSpacing.gapV12,
        ...List.generate(
          3,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: ShimmerCard(height: 80),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    String message,
    bool isDark,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.error500.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.error500.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppColors.error500),
          AppSpacing.gapH12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.error500,
                  ),
                ),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectInfoCard extends StatelessWidget {
  final Project project;
  final bool isDark;

  const _ProjectInfoCard({
    required this.project,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                      .withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(
                  Icons.folder_rounded,
                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                  size: 24,
                ),
              ),
              AppSpacing.gapH12,
              Expanded(
                child: Text(
                  'Project Information',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
              AppBadge(
                label: project.isActive ? 'Active' : 'Inactive',
                variant:
                    project.isActive ? BadgeVariant.success : BadgeVariant.neutral,
                icon: project.isActive
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_rounded,
                size: BadgeSize.medium,
              ),
            ],
          ),
          AppSpacing.gapV16,
          DetailRow(label: 'Project ID', value: project.id, monospace: true, copyable: true),
          DetailRow(label: 'API Key Prefix', value: project.apiKeyPrefix, monospace: true),
          DetailRow(label: 'Rate Limit', value: '${project.rateLimitPerMinute} requests/min'),
          DetailRow(label: 'Created', value: dateFormat.format(project.createdAt)),
          DetailRow(label: 'Updated', value: dateFormat.format(project.updatedAt)),
        ],
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  final ProjectUsage usage;
  final bool isDark;

  const _UsageSection({
    required this.usage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Usage Statistics',
          subtitle: 'Analytics and performance metrics',
          icon: Icons.analytics_rounded,
        ),
        AppSpacing.gapV12,
        _buildStatsGrid(context, usage.summary),
        if (usage.byModel.isNotEmpty) ...[
          AppSpacing.gapV24,
          const SectionHeader(
            title: 'Usage by Model',
            subtitle: 'Request distribution across models',
            icon: Icons.pie_chart_rounded,
          ),
          AppSpacing.gapV12,
          _buildModelUsageChart(context, usage.byModel),
          AppSpacing.gapV12,
          _buildModelUsageTable(context, usage.byModel),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, UsageSummary summary) {
    final stats = [
      _StatInfo(
        'Total Requests',
        _formatNumber(summary.totalRequests),
        Icons.api_rounded,
        isDark ? AppColors.info400 : AppColors.info600,
      ),
      _StatInfo(
        'Success Rate',
        '${summary.successRate.toStringAsFixed(1)}%',
        Icons.check_circle_rounded,
        isDark ? AppColors.success400 : AppColors.success600,
      ),
      _StatInfo(
        'Total Tokens',
        _formatNumber(summary.totalTokens),
        Icons.memory_rounded,
        isDark ? AppColors.warning400 : AppColors.warning600,
      ),
      _StatInfo(
        'Total Cost',
        '\$${summary.totalCostUsd.toStringAsFixed(4)}',
        Icons.payments_rounded,
        isDark ? AppColors.purple400 : AppColors.purple600,
      ),
      _StatInfo(
        'Input Tokens',
        _formatNumber(summary.totalInputTokens),
        Icons.input_rounded,
        isDark ? AppColors.info400 : AppColors.info600,
      ),
      _StatInfo(
        'Output Tokens',
        _formatNumber(summary.totalOutputTokens),
        Icons.output_rounded,
        isDark ? AppColors.indigo400 : AppColors.indigo600,
      ),
      _StatInfo(
        'Avg Response',
        '${summary.avgResponseTimeMs.toStringAsFixed(0)}ms',
        Icons.timer_rounded,
        isDark ? AppColors.warning400 : AppColors.warning600,
      ),
      _StatInfo(
        'Failed',
        _formatNumber(summary.failedRequests),
        Icons.error_rounded,
        isDark ? AppColors.error400 : AppColors.error600,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount =
            constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
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

  Widget _buildModelUsageChart(BuildContext context, List<ModelUsageStats> byModel) {
    if (byModel.isEmpty) return const SizedBox.shrink();

    final totalRequests = byModel.fold<int>(0, (sum, m) => sum + m.requests);
    if (totalRequests == 0) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: SizedBox(
        height: 220,
        child: Row(
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: byModel.asMap().entries.map((entry) {
                    final index = entry.key;
                    final model = entry.value;
                    final percentage = model.requests / totalRequests * 100;
                    return PieChartSectionData(
                      value: model.requests.toDouble(),
                      title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
                      color: AppColors.chartColors[index % AppColors.chartColors.length],
                      radius: 60,
                      titleStyle: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            AppSpacing.gapH16,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: byModel.asMap().entries.map((entry) {
                    final index = entry.key;
                    final model = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors
                                  .chartColors[index % AppColors.chartColors.length],
                              borderRadius: AppRadius.radiusXs,
                            ),
                          ),
                          AppSpacing.gapH8,
                          Expanded(
                            child: Text(
                              _getModelShortName(model.modelId),
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${model.requests}',
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelUsageTable(BuildContext context, List<ModelUsageStats> byModel) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: AppTypography.labelMedium.copyWith(
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          columns: const [
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Requests'), numeric: true),
            DataColumn(label: Text('Tokens'), numeric: true),
            DataColumn(label: Text('Cost'), numeric: true),
          ],
          rows: byModel.map((model) {
            return DataRow(cells: [
              DataCell(
                Tooltip(
                  message: model.modelId,
                  child: Text(
                    _getModelShortName(model.modelId),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                AppBadge(
                  label: model.modelType,
                  variant: model.modelType == 'free'
                      ? BadgeVariant.success
                      : BadgeVariant.primary,
                  size: BadgeSize.small,
                ),
              ),
              DataCell(Text(_formatNumber(model.requests))),
              DataCell(Text(_formatNumber(model.tokens))),
              DataCell(Text('\$${model.costUsd.toStringAsFixed(6)}')),
            ]);
          }).toList(),
        ),
      ),
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

  String _getModelShortName(String modelId) {
    final parts = modelId.split('/');
    return parts.length > 1 ? parts.last : modelId;
  }
}

class _StatInfo {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatInfo(this.title, this.value, this.icon, this.color);
}

class _LogsSection extends StatelessWidget {
  final UsageLogsResponse logsResponse;
  final bool isDark;

  const _LogsSection({
    required this.logsResponse,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Requests',
          subtitle: '${logsResponse.totalCount} total requests',
          icon: Icons.history_rounded,
        ),
        AppSpacing.gapV12,
        if (logsResponse.logs.isEmpty)
          EmptyState(
            icon: Icons.inbox_rounded,
            title: 'No Requests Yet',
            description: 'Requests will appear here once this project starts receiving traffic.',
          )
        else
          ...logsResponse.logs.asMap().entries.map((entry) {
            return ScaleInCard(
              index: entry.key,
              child: _LogCard(log: entry.value, isDark: isDark),
            );
          }),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  final UsageLog log;
  final bool isDark;

  const _LogCard({
    required this.log,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, HH:mm:ss');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: AppSpacing.cardPadding,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (log.success ? AppColors.success500 : AppColors.error500)
                  .withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(
              log.success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: log.success ? AppColors.success500 : AppColors.error500,
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  _getModelShortName(log.modelId),
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppBadge(
                label: log.modelType,
                variant: log.modelType == 'free'
                    ? BadgeVariant.success
                    : BadgeVariant.primary,
                size: BadgeSize.small,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${dateFormat.format(log.createdAt)} • ${log.totalTokens} tokens • ${log.responseTimeMs}ms',
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
          children: [
            _LogDetailSection(log: log, isDark: isDark),
          ],
        ),
      ),
    );
  }

  String _getModelShortName(String modelId) {
    final parts = modelId.split('/');
    return parts.length > 1 ? parts.last : modelId;
  }
}

class _LogDetailSection extends StatelessWidget {
  final UsageLog log;
  final bool isDark;

  const _LogDetailSection({
    required this.log,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.insetSm,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceOverlayDark
                : AppColors.surfaceOverlayLight,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Column(
            children: [
              _buildDetailRow('Request ID', log.requestId ?? 'N/A'),
              _buildDetailRow('Input Tokens', log.inputTokens.toString()),
              _buildDetailRow('Output Tokens', log.outputTokens.toString()),
              _buildDetailRow('Response Time', '${log.responseTimeMs}ms'),
              _buildDetailRow('Cost', '\$${log.costUsd.toStringAsFixed(8)}'),
              _buildDetailRow('Finish Reason', log.finishReason ?? 'N/A'),
              if (log.errorMessage != null)
                _buildDetailRow('Error', log.errorMessage!, isError: true),
            ],
          ),
        ),
        if (log.responseContent != null && log.responseContent!.isNotEmpty) ...[
          AppSpacing.gapV12,
          Text(
            'Response Preview',
            style: AppTypography.labelMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          AppSpacing.gapV8,
          Container(
            width: double.infinity,
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
            child: SelectableText(
              log.responseContent!.length > 500
                  ? '${log.responseContent!.substring(0, 500)}...'
                  : log.responseContent!,
              style: AppTypography.codeSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: isError
                    ? AppColors.error500
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
