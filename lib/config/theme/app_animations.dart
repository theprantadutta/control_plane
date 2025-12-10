import 'package:flutter/material.dart';

/// Freeway Control Panel - Animation System
/// Consistent timing and curves for all animations
class AppAnimations {
  AppAnimations._();

  // ============================================
  // DURATION CONSTANTS
  // ============================================

  /// Instant - No animation (0ms)
  static const Duration durationInstant = Duration.zero;

  /// Fastest - Micro-interactions, hover states (100ms)
  static const Duration durationFastest = Duration(milliseconds: 100);

  /// Fast - Quick transitions, tooltips (150ms)
  static const Duration durationFast = Duration(milliseconds: 150);

  /// Normal - Standard UI transitions (200ms)
  static const Duration durationNormal = Duration(milliseconds: 200);

  /// Medium - Page transitions, modals (300ms)
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// Slow - Complex animations (400ms)
  static const Duration durationSlow = Duration(milliseconds: 400);

  /// Slower - Entrance animations (500ms)
  static const Duration durationSlower = Duration(milliseconds: 500);

  /// Slowest - Large page transitions (600ms)
  static const Duration durationSlowest = Duration(milliseconds: 600);

  // ============================================
  // STAGGER DELAYS
  // ============================================

  /// Stagger for list items (50ms between each)
  static const Duration staggerFast = Duration(milliseconds: 50);

  /// Normal stagger (75ms)
  static const Duration staggerNormal = Duration(milliseconds: 75);

  /// Slow stagger for emphasis (100ms)
  static const Duration staggerSlow = Duration(milliseconds: 100);

  // ============================================
  // CURVE DEFINITIONS
  // ============================================

  /// Standard easing - default for most animations
  static const Curve curveStandard = Curves.easeInOut;

  /// Emphasized - for important state changes
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  /// Decelerate - elements coming into view
  static const Curve curveDecelerate = Curves.decelerate;

  /// Accelerate - elements leaving view
  static const Curve curveAccelerate = Curves.easeIn;

  /// Entrance - elements appearing (decelerating)
  static const Curve curveEntrance = Curves.easeOutCubic;

  /// Exit - elements disappearing (accelerating)
  static const Curve curveExit = Curves.easeInCubic;

  /// Bounce - playful interactions
  static const Curve curveBounce = Curves.bounceOut;

  /// Elastic - spring-like animations
  static const Curve curveElastic = Curves.elasticOut;

  /// Sharp - quick, snappy transitions
  static const Curve curveSharp = Curves.easeOutQuart;

  /// Smooth - gradual, flowing animations
  static const Curve curveSmooth = Curves.easeInOutQuart;

  /// Linear - constant rate (use sparingly)
  static const Curve curveLinear = Curves.linear;

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  static const Duration pageTransitionDuration = durationMedium;
  static const Curve pageTransitionCurve = curveEmphasized;

  // ============================================
  // SHIMMER/LOADING ANIMATIONS
  // ============================================

  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration pulseLoadingDuration = Duration(milliseconds: 1000);
  static const Duration spinnerDuration = Duration(milliseconds: 1200);

  // ============================================
  // HOVER/FOCUS ANIMATIONS
  // ============================================

  static const Duration hoverDuration = durationFast;
  static const Curve hoverCurve = curveStandard;

  static const Duration focusDuration = durationNormal;
  static const Curve focusCurve = curveEntrance;

  // ============================================
  // TOAST/SNACKBAR ANIMATIONS
  // ============================================

  static const Duration toastEnterDuration = durationMedium;
  static const Duration toastExitDuration = durationNormal;
  static const Duration toastDisplayDuration = Duration(milliseconds: 4000);

  // ============================================
  // MODAL/DIALOG ANIMATIONS
  // ============================================

  static const Duration modalEnterDuration = durationMedium;
  static const Duration modalExitDuration = durationNormal;
  static const Curve modalEnterCurve = curveEntrance;
  static const Curve modalExitCurve = curveExit;

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Create a staggered delay for list items
  static Duration staggerDelay(int index, {Duration delay = staggerFast}) {
    return delay * index;
  }

  /// Get total animation duration for staggered list
  static Duration totalStaggerDuration(
    int itemCount, {
    Duration itemDuration = durationMedium,
    Duration stagger = staggerFast,
  }) {
    return itemDuration + (stagger * (itemCount - 1));
  }
}
