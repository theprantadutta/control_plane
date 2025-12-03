import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shimmer loading placeholder
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: highlightColor,
        );
  }
}

/// Shimmer card placeholder
class ShimmerCard extends StatelessWidget {
  final double height;

  const ShimmerCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoading(width: 150, height: 20),
            const SizedBox(height: 12),
            const ShimmerLoading(width: double.infinity, height: 16),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 200, height: 16),
          ],
        ),
      ),
    );
  }
}

/// Shimmer stat card placeholder
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

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
                const ShimmerLoading(width: 80, height: 14),
                ShimmerLoading(width: 20, height: 20, borderRadius: 10),
              ],
            ),
            const ShimmerLoading(width: 60, height: 28),
          ],
        ),
      ),
    );
  }
}

/// Loading grid for dashboard stats
class ShimmerStatsGrid extends StatelessWidget {
  final int count;

  const ShimmerStatsGrid({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
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
          children: List.generate(count, (_) => const ShimmerStatCard()),
        );
      },
    );
  }
}

/// Loading list for projects/models
class ShimmerList extends StatelessWidget {
  final int count;

  const ShimmerList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ShimmerCard(),
      ),
    );
  }
}
