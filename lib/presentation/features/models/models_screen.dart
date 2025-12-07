import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../data/datasources/remote/freeway_api.dart';

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

class ModelsScreen extends ConsumerWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(apiConfigProvider);

    if (!config.isConfigured) {
      return Scaffold(
        appBar: AppBar(title: const Text('Models')),
        body: _buildConfigurePrompt(context),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Models'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(freeModelsProvider);
                ref.invalidate(paidModelsProvider);
                ref.invalidate(selectedFreeModelProvider);
                ref.invalidate(selectedPaidModelProvider);
              },
              tooltip: 'Refresh',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Free'),
              Tab(text: 'Paid'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchBar(context, ref),
            const Expanded(
              child: TabBarView(
                children: [
                  _FreeModelsTab(),
                  _PaidModelsTab(),
                ],
              ),
            ),
          ],
        ),
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
        decoration: InputDecoration(
          hintText: 'Search models...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
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
          return const Center(child: Text('Not configured'));
        }

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _buildModelsList(context, ref, filtered, true, selectedModelId);
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
              onPressed: () => ref.invalidate(freeModelsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsList(BuildContext context, WidgetRef ref, List<ModelInfo> models, bool isFree, String? selectedModelId) {
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
        final isSelected = model.id == selectedModelId;
        return _ModelTile(
          model: model,
          isFree: isFree,
          isSelected: isSelected,
          onSelect: () => _selectModel(context, ref, model),
        );
      },
    );
  }

  Future<void> _selectModel(BuildContext context, WidgetRef ref, ModelInfo model) async {
    final api = ref.read(freewayApiProvider);

    try {
      final result = await api.setSelectedFreeModel(model.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(selectedFreeModelProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select model: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
          return const Center(child: Text('Not configured'));
        }

        final filtered = data.models.where((m) {
          if (searchQuery.isEmpty) return true;
          return m.name.toLowerCase().contains(searchQuery) ||
              m.id.toLowerCase().contains(searchQuery);
        }).toList();

        return _buildModelsList(context, ref, filtered, false, selectedModelId);
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
              onPressed: () => ref.invalidate(paidModelsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelsList(BuildContext context, WidgetRef ref, List<ModelInfo> models, bool isFree, String? selectedModelId) {
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
        final isSelected = model.id == selectedModelId;
        return _ModelTile(
          model: model,
          isFree: isFree,
          isSelected: isSelected,
          onSelect: () => _selectModel(context, ref, model),
        );
      },
    );
  }

  Future<void> _selectModel(BuildContext context, WidgetRef ref, ModelInfo model) async {
    final api = ref.read(freewayApiProvider);

    try {
      final result = await api.setSelectedPaidModel(model.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(selectedPaidModelProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select model: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _ModelTile extends StatelessWidget {
  final ModelInfo model;
  final bool isFree;
  final bool isSelected;
  final VoidCallback? onSelect;

  const _ModelTile({
    required this.model,
    required this.isFree,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: isSelected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: primaryColor, width: 2),
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: isSelected
            ? Icon(Icons.check_circle, color: primaryColor)
            : null,
        title: Row(
          children: [
            Expanded(
              child: Text(
                model.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryColor : null,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              model.id,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (model.contextLength != null)
                  _InfoChip(
                    icon: Icons.memory,
                    label: '${model.contextLength} tokens',
                  ),
                _InfoChip(
                  icon: Icons.attach_money,
                  label: isFree
                      ? 'Free'
                      : '\$${model.pricing.prompt}/\$${model.pricing.completion}',
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
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(model.name)),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(dialogContext).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'ID', value: model.id),
            if (model.contextLength != null)
              _DetailRow(
                  label: 'Context Length', value: '${model.contextLength} tokens'),
            _DetailRow(label: 'Prompt Price', value: '\$${model.pricing.prompt}'),
            _DetailRow(
                label: 'Completion Price', value: '\$${model.pricing.completion}'),
            if (model.description != null) ...[
              const SizedBox(height: 16),
              Text(
                'Description',
                style: Theme.of(dialogContext).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(model.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          if (!isSelected && onSelect != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onSelect!();
              },
              icon: const Icon(Icons.check),
              label: const Text('Select'),
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
