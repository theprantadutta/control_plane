import 'package:flutter/material.dart';

/// Freeway Control Panel - Spacing System
/// Based on 4px base unit with named semantic constants
class AppSpacing {
  AppSpacing._();

  // ============================================
  // BASE UNIT
  // ============================================
  static const double unit = 4.0;

  // ============================================
  // SPACING SCALE (4px increments)
  // ============================================
  static const double space0 = 0;
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  static const double space20 = 80;
  static const double space24 = 96;

  // ============================================
  // SEMANTIC NAMING
  // ============================================
  static const double none = space0;
  static const double xxxs = space1;
  static const double xxs = space2;
  static const double xs = space3;
  static const double sm = space4;
  static const double md = space5;
  static const double lg = space6;
  static const double xl = space8;
  static const double xxl = space10;
  static const double xxxl = space12;
  static const double huge = space16;
  static const double massive = space20;

  // ============================================
  // INSETS (PADDING)
  // ============================================

  // All sides
  static const EdgeInsets insetNone = EdgeInsets.zero;
  static const EdgeInsets insetXxs = EdgeInsets.all(xxs);
  static const EdgeInsets insetXs = EdgeInsets.all(xs);
  static const EdgeInsets insetSm = EdgeInsets.all(sm);
  static const EdgeInsets insetMd = EdgeInsets.all(md);
  static const EdgeInsets insetLg = EdgeInsets.all(lg);
  static const EdgeInsets insetXl = EdgeInsets.all(xl);
  static const EdgeInsets insetXxl = EdgeInsets.all(xxl);

  // Horizontal only
  static const EdgeInsets insetHorizontalXxs =
      EdgeInsets.symmetric(horizontal: xxs);
  static const EdgeInsets insetHorizontalXs =
      EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets insetHorizontalSm =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets insetHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets insetHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets insetHorizontalXl =
      EdgeInsets.symmetric(horizontal: xl);

  // Vertical only
  static const EdgeInsets insetVerticalXxs =
      EdgeInsets.symmetric(vertical: xxs);
  static const EdgeInsets insetVerticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets insetVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets insetVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets insetVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets insetVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // ============================================
  // COMPONENT-SPECIFIC SPACING
  // ============================================

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(sm);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(xs);

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xs,
  );

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xs,
  );

  static const EdgeInsets buttonPaddingSmall = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );

  static const EdgeInsets buttonPaddingLarge = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: sm,
  );

  // Input field padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: 14,
  );

  // Screen/page padding
  static const EdgeInsets screenPadding = EdgeInsets.all(sm);
  static const EdgeInsets screenPaddingLarge = EdgeInsets.all(lg);
  static const EdgeInsets screenPaddingDesktop = EdgeInsets.all(xl);

  // ============================================
  // GAPS (for Row, Column, Wrap)
  // ============================================
  static const double gapXxs = xxs;
  static const double gapXs = xs;
  static const double gapSm = sm;
  static const double gapMd = md;
  static const double gapLg = lg;
  static const double gapXl = xl;

  // SizedBox helpers for gaps
  static const SizedBox gapH4 = SizedBox(width: xxxs);
  static const SizedBox gapH6 = SizedBox(width: 6);
  static const SizedBox gapH8 = SizedBox(width: xxs);
  static const SizedBox gapH12 = SizedBox(width: xs);
  static const SizedBox gapH16 = SizedBox(width: sm);
  static const SizedBox gapH20 = SizedBox(width: md);
  static const SizedBox gapH24 = SizedBox(width: lg);
  static const SizedBox gapH32 = SizedBox(width: xl);

  static const SizedBox gapV4 = SizedBox(height: xxxs);
  static const SizedBox gapV8 = SizedBox(height: xxs);
  static const SizedBox gapV12 = SizedBox(height: xs);
  static const SizedBox gapV16 = SizedBox(height: sm);
  static const SizedBox gapV20 = SizedBox(height: md);
  static const SizedBox gapV24 = SizedBox(height: lg);
  static const SizedBox gapV32 = SizedBox(height: xl);
  static const SizedBox gapV40 = SizedBox(height: xxl);
  static const SizedBox gapV48 = SizedBox(height: xxxl);

  // ============================================
  // ICON SIZES
  // ============================================
  static const double iconXs = 14;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double iconXxl = 48;
  static const double iconHuge = 64;
}
