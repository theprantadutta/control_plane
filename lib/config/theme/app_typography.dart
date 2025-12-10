import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Freeway Control Panel - Typography System
/// Based on Inter font with a modern type scale
class AppTypography {
  AppTypography._();

  // ============================================
  // FONT FAMILY
  // ============================================
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // Monospace font for code/technical data
  static String get monoFontFamily => GoogleFonts.jetBrainsMono().fontFamily!;

  // ============================================
  // FONT WEIGHTS
  // ============================================
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // ============================================
  // LINE HEIGHTS
  // ============================================
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.625;
  static const double lineHeightLoose = 2.0;

  // ============================================
  // LETTER SPACING
  // ============================================
  static const double letterSpacingTight = -0.02;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.025;
  static const double letterSpacingWidest = 0.05;

  // ============================================
  // TYPE SCALE
  // ============================================

  // Display styles (hero sections, large headings)
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: bold,
        letterSpacing: -0.25,
        height: lineHeightTight,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: bold,
        letterSpacing: 0,
        height: lineHeightTight,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: lineHeightTight,
      );

  // Headline styles (section headings)
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.25,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.286,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.333,
      );

  // Title styles (card titles, list headers)
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.273,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: semiBold,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: semiBold,
        letterSpacing: 0.1,
        height: 1.429,
      );

  // Body styles (main content)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: regular,
        letterSpacing: 0.15,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0.25,
        height: 1.429,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.333,
      );

  // Label styles (buttons, form labels, chips)
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: medium,
        letterSpacing: 0.1,
        height: 1.429,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.333,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: medium,
        letterSpacing: 0.5,
        height: 1.455,
      );

  // Caption/Overline styles
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0.4,
        height: 1.333,
      );

  static TextStyle get overline => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: medium,
        letterSpacing: 1.5,
        height: 1.6,
      );

  // ============================================
  // SPECIALIZED STYLES
  // ============================================

  // Stat/metric values (dashboard numbers)
  static TextStyle get statLarge => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: bold,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get statMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: bold,
        letterSpacing: -0.25,
        height: 1.2,
      );

  static TextStyle get statSmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: semiBold,
        letterSpacing: 0,
        height: 1.4,
      );

  // Code/monospace text
  static TextStyle get codeLarge => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get codeMedium => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.5,
      );

  static TextStyle get codeSmall => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: regular,
        letterSpacing: 0,
        height: 1.5,
      );

  // ============================================
  // TEXT THEME BUILDER
  // ============================================

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
