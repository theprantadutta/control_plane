import 'package:flutter/material.dart';

/// Freeway Control Panel - Shadows & Elevation System
/// Designed for both light and dark modes with subtle, modern shadows
class AppShadows {
  AppShadows._();

  // ============================================
  // ELEVATION LEVELS - LIGHT MODE
  // ============================================

  /// No shadow - flat elements
  static const List<BoxShadow> noneLight = [];

  /// Extra small - subtle depth for hover states
  static const List<BoxShadow> xsLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Small - default card shadow (Stripe-style)
  static const List<BoxShadow> smLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium - elevated cards, dropdowns
  static const List<BoxShadow> mdLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 16,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];

  /// Large - modals, dialogs
  static const List<BoxShadow> lgLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 8),
    ),
  ];

  /// Extra large - floating elements, popovers
  static const List<BoxShadow> xlLight = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 12,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 32,
      spreadRadius: -8,
      offset: Offset(0, 16),
    ),
  ];

  // ============================================
  // ELEVATION LEVELS - DARK MODE
  // ============================================

  static const List<BoxShadow> noneDark = [];

  /// XS - Very subtle glow
  static const List<BoxShadow> xsDark = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Small - Default card
  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium - Elevated surfaces
  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  /// Large - Modals
  static const List<BoxShadow> lgDark = [
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
  ];

  /// XL - Floating elements
  static const List<BoxShadow> xlDark = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x60000000),
      blurRadius: 48,
      offset: Offset(0, 24),
    ),
  ];

  // ============================================
  // GLOW EFFECTS (for interactive states)
  // ============================================

  /// Primary button focus glow
  static List<BoxShadow> get primaryGlowLight => [
        const BoxShadow(
          color: Color(0x408B5CF6), // 25% purple500
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get primaryGlowDark => [
        const BoxShadow(
          color: Color(0x60A78BFA), // 37% purple400
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  /// Success state glow
  static List<BoxShadow> get successGlow => [
        const BoxShadow(
          color: Color(0x4010B981),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Error state glow
  static List<BoxShadow> get errorGlow => [
        const BoxShadow(
          color: Color(0x40F43F5E),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get shadow list based on elevation and theme
  static List<BoxShadow> getShadow(
    ShadowElevation elevation, {
    required bool isDark,
  }) {
    switch (elevation) {
      case ShadowElevation.none:
        return isDark ? noneDark : noneLight;
      case ShadowElevation.xs:
        return isDark ? xsDark : xsLight;
      case ShadowElevation.sm:
        return isDark ? smDark : smLight;
      case ShadowElevation.md:
        return isDark ? mdDark : mdLight;
      case ShadowElevation.lg:
        return isDark ? lgDark : lgLight;
      case ShadowElevation.xl:
        return isDark ? xlDark : xlLight;
    }
  }

  /// Get primary glow based on theme
  static List<BoxShadow> getPrimaryGlow({required bool isDark}) {
    return isDark ? primaryGlowDark : primaryGlowLight;
  }
}

/// Shadow elevation levels
enum ShadowElevation {
  none,
  xs,
  sm,
  md,
  lg,
  xl,
}
