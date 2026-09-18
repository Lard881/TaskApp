import 'package:flutter/material.dart';

/// Brand palette tokens for PlanPal.
/// All raw color values live here; the theme references these constants.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF4F6EF7);
  static const Color primaryMuted = Color(0xFF9BAFF9);

  // ── Priority ─────────────────────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFEF4444);   // red
  static const Color priorityMedium = Color(0xFFF59E0B); // amber
  static const Color priorityLow = Color(0xFF22C55E);    // green

  // ── Light theme surfaces ──────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1D2E);
  static const Color lightOnSurfaceMuted = Color(0xFF6B7280);

  // ── Dark theme surfaces ───────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1C1F2E);
  static const Color darkOnSurface = Color(0xFFF1F3FF);
  static const Color darkOnSurfaceMuted = Color(0xFF9CA3AF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color logOutRed = Color(0xFFEF4444);

  // ── Avatar placeholder backgrounds (cycling palette) ─────────────────────
  static const List<Color> avatarBackgrounds = [
    Color(0xFF6366F1), // indigo
    Color(0xFF8B5CF6), // violet
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
    Color(0xFFF97316), // orange
    Color(0xFF0EA5E9), // sky
  ];
}
