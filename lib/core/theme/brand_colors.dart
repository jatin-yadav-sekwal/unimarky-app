import 'dart:ui';

/// UniMARKY brand colors — matches the web app's CSS variables.
class BrandColors {
  BrandColors._();

  // ── Primary palette ──
  static const Color navy   = Color(0xFF2C3D73);
  static const Color orange = Color(0xFFF15B42);
  static const Color yellow = Color(0xFFFFD372);
  static const Color pink   = Color(0xFFF49CC4);
  static const Color blue   = Color(0xFF7CAADC);

  // ── Semantic ──
  static const Color primary     = orange;
  static const Color secondary   = yellow;
  static const Color accent      = pink;
  static const Color foreground  = navy;
  static const Color muted       = blue;

  // ── Neutrals ──
  static const Color background     = Color(0xFFFAFAFA);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color border         = Color(0xFFE5E7EB);
  static const Color textPrimary    = Color(0xFF1F2937);
  static const Color textSecondary  = Color(0xFF6B7280);

  // ── Dark mode neutrals ──
  static const Color darkBackground    = Color(0xFF111827);
  static const Color darkSurface       = Color(0xFF1F2937);
  static const Color darkBorder        = Color(0xFF374151);
  static const Color darkTextPrimary   = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
}
