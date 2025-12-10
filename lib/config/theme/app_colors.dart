import 'package:flutter/material.dart';

/// Freeway Control Panel - Design System Colors
/// Purple/Violet color scheme inspired by Stripe + Vercel dashboards
class AppColors {
  AppColors._();

  // ============================================
  // PRIMARY - Purple/Violet Spectrum
  // ============================================

  static const Color purple50 = Color(0xFFF5F3FF);
  static const Color purple100 = Color(0xFFEDE9FE);
  static const Color purple200 = Color(0xFFDDD6FE);
  static const Color purple300 = Color(0xFFC4B5FD);
  static const Color purple400 = Color(0xFFA78BFA);
  static const Color purple500 = Color(0xFF8B5CF6);
  static const Color purple600 = Color(0xFF7C3AED);
  static const Color purple700 = Color(0xFF6D28D9);
  static const Color purple800 = Color(0xFF5B21B6);
  static const Color purple900 = Color(0xFF4C1D95);

  // Primary assignments
  static const Color primaryLight = purple600;
  static const Color primaryDark = purple400;

  // ============================================
  // SECONDARY - Indigo (complementary)
  // ============================================

  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);

  static const Color secondaryLight = indigo500;
  static const Color secondaryDark = indigo400;

  // ============================================
  // SEMANTIC COLORS
  // ============================================

  // Success - Emerald
  static const Color success50 = Color(0xFFECFDF5);
  static const Color success100 = Color(0xFFD1FAE5);
  static const Color success400 = Color(0xFF34D399);
  static const Color success500 = Color(0xFF10B981);
  static const Color success600 = Color(0xFF059669);

  static const Color successLight = success500;
  static const Color successDark = success400;

  // Warning - Amber
  static const Color warning50 = Color(0xFFFFFBEB);
  static const Color warning100 = Color(0xFFFEF3C7);
  static const Color warning400 = Color(0xFFFBBF24);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning600 = Color(0xFFD97706);

  static const Color warningLight = warning500;
  static const Color warningDark = warning400;

  // Error - Rose
  static const Color error50 = Color(0xFFFFF1F2);
  static const Color error100 = Color(0xFFFFE4E6);
  static const Color error400 = Color(0xFFFB7185);
  static const Color error500 = Color(0xFFF43F5E);
  static const Color error600 = Color(0xFFE11D48);
  static const Color error900 = Color(0xFF881337);

  static const Color errorLight = error500;
  static const Color errorDark = error400;

  // Info - Cyan
  static const Color info50 = Color(0xFFECFEFF);
  static const Color info100 = Color(0xFFCFFAFE);
  static const Color info400 = Color(0xFF22D3EE);
  static const Color info500 = Color(0xFF06B6D4);
  static const Color info600 = Color(0xFF0891B2);

  static const Color infoLight = info500;
  static const Color infoDark = info400;

  // ============================================
  // NEUTRAL COLORS (Slate palette)
  // ============================================

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate950 = Color(0xFF020617);

  // Zinc (for dark mode)
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  // Light mode
  static const Color backgroundLight = Color(0xFFFAFAFB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceOverlayLight = Color(0xFFF4F4F5);

  // Dark mode (Vercel-style)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF0A0A0A);
  static const Color surfaceElevatedDark = Color(0xFF141414);
  static const Color surfaceOverlayDark = Color(0xFF1C1C1C);

  // ============================================
  // TEXT COLORS
  // ============================================

  // Light mode
  static const Color textPrimaryLight = slate900;
  static const Color textSecondaryLight = slate600;
  static const Color textTertiaryLight = slate400;
  static const Color textDisabledLight = slate300;

  // Dark mode
  static const Color textPrimaryDark = slate50;
  static const Color textSecondaryDark = zinc400;
  static const Color textTertiaryDark = zinc500;
  static const Color textDisabledDark = zinc600;

  // ============================================
  // BORDER COLORS
  // ============================================

  static const Color borderLight = slate200;
  static const Color borderSubtleLight = slate100;
  static const Color borderFocusLight = purple500;

  static const Color borderDark = zinc800;
  static const Color borderSubtleDark = Color(0xFF1C1C1C);
  static const Color borderFocusDark = purple400;

  // ============================================
  // CHART/DATA VISUALIZATION COLORS
  // ============================================

  static const List<Color> chartColors = [
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFF43F5E), // Rose
    Color(0xFF6366F1), // Indigo
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
  ];

  static const List<Color> chartColorsLight = [
    Color(0xFF7C3AED), // Purple 600
    Color(0xFF0891B2), // Cyan 600
    Color(0xFF059669), // Emerald 600
    Color(0xFFD97706), // Amber 600
    Color(0xFFE11D48), // Rose 600
    Color(0xFF4F46E5), // Indigo 600
    Color(0xFFDB2777), // Pink 600
    Color(0xFF0D9488), // Teal 600
  ];

  static const List<Color> chartColorsDark = [
    Color(0xFFA78BFA), // Purple 400
    Color(0xFF22D3EE), // Cyan 400
    Color(0xFF34D399), // Emerald 400
    Color(0xFFFBBF24), // Amber 400
    Color(0xFFFB7185), // Rose 400
    Color(0xFF818CF8), // Indigo 400
    Color(0xFFF472B6), // Pink 400
    Color(0xFF2DD4BF), // Teal 400
  ];

  // ============================================
  // GRADIENTS
  // ============================================

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple500, indigo500],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple400, purple600],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success400, success600],
  );

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get chart color by index (loops if needed)
  static Color getChartColor(int index, {bool isDark = false}) {
    final colors = isDark ? chartColorsDark : chartColorsLight;
    return colors[index % colors.length];
  }

  /// Get semantic color with opacity for backgrounds
  static Color withBackgroundOpacity(Color color, {bool isDark = false}) {
    return color.withValues(alpha: isDark ? 0.15 : 0.1);
  }
}
