/// Layout and sizing constants for PlanPal.
/// Using named constants avoids magic numbers scattered across widgets.
abstract final class AppSizes {
  // ── Touch targets (WCAG 2.5.5 / Req 27.3) ────────────────────────────────
  static const double minTouchTarget = 44.0;

  // ── Avatars ───────────────────────────────────────────────────────────────
  static const double avatarSmall = 32.0;   // task list assignee
  static const double avatarMedium = 48.0;  // conversation item
  static const double avatarLarge = 80.0;   // profile screen

  // ── Spacing ───────────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceS = 8.0;
  static const double spaceM = 16.0;
  static const double spaceL = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border radii ──────────────────────────────────────────────────────────
  static const double radiusS = 6.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;
  static const double radiusFull = 999.0; // pill / fully rounded

  // ── Priority badge ────────────────────────────────────────────────────────
  static const double badgePaddingH = 8.0;
  static const double badgePaddingV = 3.0;

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  static const double bottomNavHeight = 60.0;

  // ── Cards / tiles ─────────────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double metricTileWidth = 72.0;

  // ── Font size helpers ─────────────────────────────────────────────────────
  static const double fontBody = 14.0;
  static const double fontHeading = 18.0;  // body + 4dp (Req 11.1, 16.3)
  static const double fontTitle = 22.0;
  static const double fontSmall = 12.0;

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const double dividerThickness = 1.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 20.0;
  static const double iconSizeL = 24.0;
}
