import 'package:flutter/material.dart';

/// Freeway Control Panel - Border Radius System
class AppRadius {
  AppRadius._();

  // ============================================
  // RADIUS VALUES
  // ============================================
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double xxl = 20;
  static const double xxxl = 24;
  static const double full = 9999;

  // ============================================
  // BORDER RADIUS OBJECTS
  // ============================================

  // All corners
  static const BorderRadius radiusNone = BorderRadius.zero;
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // Top only (for bottom sheets, top bars)
  static const BorderRadius radiusTopMd = BorderRadius.only(
    topLeft: Radius.circular(md),
    topRight: Radius.circular(md),
  );

  static const BorderRadius radiusTopLg = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  static const BorderRadius radiusTopXl = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // Bottom only
  static const BorderRadius radiusBottomMd = BorderRadius.only(
    bottomLeft: Radius.circular(md),
    bottomRight: Radius.circular(md),
  );

  static const BorderRadius radiusBottomLg = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );

  // ============================================
  // COMPONENT-SPECIFIC RADIUS
  // ============================================
  static const BorderRadius button = radiusMd;
  static const BorderRadius buttonSmall = radiusSm;
  static const BorderRadius buttonLarge = radiusLg;
  static const BorderRadius buttonPill = radiusFull;

  static const BorderRadius input = radiusMd;
  static const BorderRadius card = radiusLg;
  static const BorderRadius cardSmall = radiusMd;
  static const BorderRadius cardLarge = radiusXl;

  static const BorderRadius dialog = radiusXl;
  static const BorderRadius bottomSheet = radiusTopXl;
  static const BorderRadius chip = radiusFull;
  static const BorderRadius badge = radiusXs;
  static const BorderRadius avatar = radiusFull;
  static const BorderRadius tooltip = radiusSm;

  static const BorderRadius iconButton = radiusMd;
  static const BorderRadius searchBar = radiusLg;
  static const BorderRadius snackbar = radiusMd;

  // ============================================
  // SHAPE BUILDERS
  // ============================================
  static RoundedRectangleBorder get cardShape => const RoundedRectangleBorder(
        borderRadius: card,
      );

  static RoundedRectangleBorder get buttonShape => const RoundedRectangleBorder(
        borderRadius: button,
      );

  static RoundedRectangleBorder get dialogShape => const RoundedRectangleBorder(
        borderRadius: dialog,
      );

  static RoundedRectangleBorder get chipShape => const RoundedRectangleBorder(
        borderRadius: chip,
      );
}
