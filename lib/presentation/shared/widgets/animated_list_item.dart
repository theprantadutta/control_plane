import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated list item wrapper for staggered animations
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay * index)
        .fadeIn(duration: duration)
        .slideX(begin: 0.1, end: 0, duration: duration, curve: Curves.easeOut);
  }
}

/// Fade in animation for screen content
class FadeInContent extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInContent({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: duration)
        .slideY(begin: 0.05, end: 0, duration: duration, curve: Curves.easeOut);
  }
}

/// Scale in animation for cards
class ScaleInCard extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const ScaleInCard({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay * index)
        .fadeIn(duration: duration)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.easeOut,
        );
  }
}
