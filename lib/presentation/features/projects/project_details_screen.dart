import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/datasources/remote/freeway_api.dart';

/// Provider for project usage data
final projectUsageProvider = FutureProvider.autoDispose.family<ProjectUsage, String>((ref, projectId) async {
  final api = ref.watch(freewayApiProvider);
  return api.getProjectUsage(projectId);
});

/// Provider for project logs
final projectLogsProvider = FutureProvider.autoDispose.family<UsageLogsResponse, String>((ref, projectId) async {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(projectUsageProvider(project.id));
              ref.invalidate(projectLogsProvider(project.id));
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectInfo(context),
            const SizedBox(height: 24),
            usageAsync.when(
              data: (usage) => _buildUsageSection(context, usage),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard(context, 'Failed to load usage: $e'),
            ),
            const SizedBox(height: 24),
            logsAsync.when(
              data: (logsResponse) => _buildLogsSection(context, logsResponse),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildErrorCard(context, 'Failed to load logs: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Project Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: project.isActive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
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
            const SizedBox(height: 16),
            _buildInfoRow(context, 'ID', project.id),
            _buildInfoRow(context, 'API Key Prefix', project.apiKeyPrefix),
            _buildInfoRow(context, 'Rate Limit', '${project.rateLimitPerMinute}/min'),
            _buildInfoRow(context, 'Created', dateFormat.format(project.createdAt)),
            _buildInfoRow(context, 'Updated', dateFormat.format(project.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSection(BuildContext context, ProjectUsage usage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Statistics',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatsGrid(context, usage.summary),
        const SizedBox(height: 24),
        if (usage.byModel.isNotEmpty) ...[
          Text(
            'Usage by Model',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildModelUsageChart(context, usage.byModel),
          const SizedBox(height: 12),
          _buildModelUsageTable(context, usage.byModel),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, UsageSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 500 ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
        _StatCard(
          title: 'Total Requests',
          value: _formatNumber(summary.totalRequests),
          icon: Icons.api,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Success Rate',
          value: '${summary.successRate.toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Total Tokens',
          value: _formatNumber(summary.totalTokens),
          icon: Icons.token,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Total Cost',
          value: '\$${summary.totalCostUsd.toStringAsFixed(4)}',
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
        _StatCard(
          title: 'Input Tokens',
          value: _formatNumber(summary.totalInputTokens),
          icon: Icons.input,
          color: Colors.teal,
        ),
        _StatCard(
          title: 'Output Tokens',
          value: _formatNumber(summary.totalOutputTokens),
          icon: Icons.output,
          color: Colors.indigo,
        ),
        _StatCard(
          title: 'Avg Response',
          value: '${summary.avgResponseTimeMs.toStringAsFixed(0)}ms',
          icon: Icons.timer,
          color: Colors.amber,
        ),
        _StatCard(
          title: 'Failed Requests',
          value: _formatNumber(summary.failedRequests),
          icon: Icons.error,
          color: Colors.red,
        ),
      ],
    );
      },
    );
  }

  Widget _buildModelUsageChart(BuildContext context, List<ModelUsageStats> byModel) {
    if (byModel.isEmpty) return const SizedBox.shrink();

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    final totalRequests = byModel.fold<int>(0, (sum, m) => sum + m.requests);
    if (totalRequests == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
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
                        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                        color: colors[index % colors.length],
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 25,
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getModelShortName(model.modelId),
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${model.requests}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildModelUsageTable(BuildContext context, List<ModelUsageStats> byModel) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: model.modelType == 'free'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    model.modelType,
                    style: TextStyle(
                      fontSize: 11,
                      color: model.modelType == 'free' ? Colors.green : Colors.blue,
                    ),
                  ),
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

  Widget _buildLogsSection(BuildContext context, UsageLogsResponse logsResponse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Requests',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${logsResponse.totalCount} total)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (logsResponse.logs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No requests yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...logsResponse.logs.map((log) => _LogTile(log: log)),
      ],
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final UsageLog log;

  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, HH:mm:ss');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          log.success ? Icons.check_circle : Icons.error,
          color: log.success ? Colors.green : Colors.red,
          size: 20,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getModelShortName(log.modelId),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: log.modelType == 'free'
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                log.modelType,
                style: TextStyle(
                  fontSize: 10,
                  color: log.modelType == 'free' ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${dateFormat.format(log.createdAt)} • ${log.totalTokens} tokens • ${log.responseTimeMs}ms',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogDetail(context, 'Request ID', log.requestId ?? 'N/A'),
                _buildLogDetail(context, 'Input Tokens', log.inputTokens.toString()),
                _buildLogDetail(context, 'Output Tokens', log.outputTokens.toString()),
                _buildLogDetail(context, 'Response Time', '${log.responseTimeMs}ms'),
                _buildLogDetail(context, 'Cost', '\$${log.costUsd.toStringAsFixed(8)}'),
                _buildLogDetail(context, 'Finish Reason', log.finishReason ?? 'N/A'),
                if (log.errorMessage != null)
                  _buildLogDetail(context, 'Error', log.errorMessage!, isError: true),
                if (log.responseContent != null && log.responseContent!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Response Preview',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: SelectableText(
                      log.responseContent!.length > 500
                          ? '${log.responseContent!.substring(0, 500)}...'
                          : log.responseContent!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogDetail(BuildContext context, String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isError ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModelShortName(String modelId) {
    final parts = modelId.split('/');
    return parts.length > 1 ? parts.last : modelId;
  }
}
