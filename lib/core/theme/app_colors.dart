import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// Changing any color here will update it across the entire app.
class AppColors {
  // ── BRAND & PRIMARY ──────────────────────────────────────────────
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color accent = Color(0xFF3B82F6);

  // ── ROUTE TYPE COLORS ─────────────────────────────────────────────
  static const Color pickupColor = Color(0xFF2563EB);
  static const Color pickupColorDark = Color(0xFF1D4ED8);
  static const Color dropColor = Color(0xFFF04545);
  static const Color dropColorDark = Color(0xFFDC2626);

  // ── GRADIENT COLOR LISTS ─────────────────────────────────────────
  static const List<Color> primaryColors = [primary, primaryDark];
  static const List<Color> primaryAccentColors = [Color(0xFF3B82F6), Color(0xFF6366F1)];
  static const List<Color> pickupColors = [pickupColor, pickupColorDark];
  static const List<Color> dropColors = [dropColor, dropColorDark];

  // ── BRAND GRADIENTS (Ready-to-use LinearGradient objects) ────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryColors,
  );

  static const LinearGradient primaryGradientAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryAccentColors,
  );

  static const LinearGradient pickupGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: pickupColors,
  );

  static const LinearGradient dropGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: dropColors,
  );

  // ── BACKGROUNDS & SURFACES ────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color cardBg = Color(0xFFF8FAFC);
  static const Color cardBgWhite = Colors.white;
  static const Color inputBg = Color(0xFFF8FAFC);
  static const Color dialogBg = Colors.white;

  // Dark Mode Surfaces
  static const Color scaffoldBgDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardBgDark = Color(0xFF1E293B);
  static const Color inputBgDark = Color(0xFF334155);

  // ── TYPOGRAPHY & TEXT ────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // Dark Mode Text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // ── BORDERS & DIVIDERS ───────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocused = Color(0xFF3B82F6);
  static const Color divider = Color(0xFFE2E8F0);

  // Dark Mode Borders
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerDark = Color(0xFF334155);

  // ── SEMANTIC & STATUS COLORS ─────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successLight = Color(0xFFD1FAE5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── AVATAR ACCENT COLORS ─────────────────────────────────────────
  static const List<List<Color>> avatarColorPairs = [
    [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    [Color(0xFFF59E0B), Color(0xFFF97316)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFEC4899), Color(0xFFEF4444)],
  ];
}
