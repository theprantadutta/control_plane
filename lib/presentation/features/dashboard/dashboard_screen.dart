import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';

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
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardDataProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !config.isConfigured
          ? _buildConfigurePrompt(context)
          : dashboardData.when(
              data: (data) =>
                  data == null ? _buildConfigurePrompt(context) : _buildDashboard(context, data),
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
              'Failed to load data',
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
              onPressed: () => ref.invalidate(dashboardDataProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Map<String, dynamic> data) {
    final freeModel = data['freeModel'] as SelectedModelResponse;
    final paidModel = data['paidModel'] as SelectedModelResponse;
    final summary = data['summary'] as GlobalSummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards
          _buildStatsSection(context, summary),
          const SizedBox(height: 24),

          // Selected models
          Text(
            'Selected Models',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          _buildModelsSection(context, freeModel, paidModel),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, GlobalSummary summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              title: 'Total Projects',
              value: summary.totalProjects.toString(),
              icon: Icons.folder,
              color: Colors.blue,
            ),
            _StatCard(
              title: 'Active Projects',
              value: summary.activeProjects.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            _StatCard(
              title: 'Requests Today',
              value: summary.totalRequestsToday.toString(),
              icon: Icons.trending_up,
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Cost This Month',
              value: '\$${summary.totalCostThisMonthUsd.toStringAsFixed(2)}',
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }

  Widget _buildModelsSection(
    BuildContext context,
    SelectedModelResponse freeModel,
    SelectedModelResponse paidModel,
  ) {
    return Row(
      children: [
        Expanded(
          child: _ModelCard(
            title: 'Free Model',
            model: freeModel,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModelCard(
            title: 'Paid Model',
            model: paidModel,
            color: Colors.blue,
          ),
        ),
      ],
    );
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String title;
  final SelectedModelResponse model;
  final Color color;

  const _ModelCard({
    required this.title,
    required this.model,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              model.modelInfo?.name ?? model.selectedModel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (model.modelInfo != null) ...[
              const SizedBox(height: 8),
              Text(
                'Context: ${model.modelInfo!.contextLength.toString()} tokens',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Price: \$${model.modelInfo!.promptPrice}/prompt, \$${model.modelInfo!.completionPrice}/completion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
