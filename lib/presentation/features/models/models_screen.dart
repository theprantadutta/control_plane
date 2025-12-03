import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';

/// Selected tab provider
final selectedTabProvider = StateProvider<int>((ref) => 0);

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

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(apiConfigProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(freeModelsProvider);
              ref.invalidate(paidModelsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: null,
          tabs: const [
            Tab(text: 'Free'),
            Tab(text: 'Paid'),
          ],
          onTap: (index) =>
              ref.read(selectedTabProvider.notifier).state = index,
        ),
      ),
      body: !config.isConfigured
          ? _buildConfigurePrompt(context)
          : Column(
              children: [
                _buildSearchBar(context, ref),
                Expanded(
                  child: selectedTab == 0
                      ? _buildFreeModels(context, ref)
                      : _buildPaidModels(context, ref),
                ),
              ],
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

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search models...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
      ),
    );
  }

  Widget _buildFreeModels(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(freeModelsProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return modelsAsync.when(
      data: (data) {
        if (data == null) return _buildConfigurePrompt(context);

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _buildModelsList(context, filtered, true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, ref, error),
    );
  }

  Widget _buildPaidModels(BuildContext context, WidgetRef ref) {
    final modelsAsync = ref.watch(paidModelsProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return modelsAsync.when(
      data: (data) {
        if (data == null) return _buildConfigurePrompt(context);

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _buildModelsList(context, filtered, false);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildError(context, ref, error),
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
              'Failed to load models',
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
              onPressed: () {
                ref.invalidate(freeModelsProvider);
                ref.invalidate(paidModelsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsList(
      BuildContext context, List<ModelInfo> models, bool isFree) {
    if (models.isEmpty) {
      return Center(
        child: Text(
          'No models found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: models.length,
      itemBuilder: (context, index) {
        final model = models[index];
        return _ModelTile(model: model, isFree: isFree);
      },
    );
  }
}

class _ModelTile extends StatelessWidget {
  final ModelInfo model;
  final bool isFree;

  const _ModelTile({required this.model, required this.isFree});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          model.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              model.id,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.memory,
                  label: '${model.contextLength} tokens',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.attach_money,
                  label: isFree
                      ? 'Free'
                      : '\$${model.promptPrice}/\$${model.completionPrice}',
                  color: isFree ? Colors.green : null,
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showModelDetails(context, model),
      ),
    );
  }

  void _showModelDetails(BuildContext context, ModelInfo model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(model.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'ID', value: model.id),
            _DetailRow(
                label: 'Context Length', value: '${model.contextLength} tokens'),
            _DetailRow(label: 'Prompt Price', value: '\$${model.promptPrice}'),
            _DetailRow(
                label: 'Completion Price', value: '\$${model.completionPrice}'),
            if (model.description != null) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(model.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
