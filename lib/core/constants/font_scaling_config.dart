class FontScalingConfig {
  // ========== BASELINE DEVICE ==========
  // Reference: Medium Phone Emulator (412dp x 915dp)
  static const double baselineWidth = 412.0;
  static const double baselineHeight = 915.0;

  // ========== SCALE FACTOR LIMITS ==========
  static const double minScaleFactor = 0.82;
  static const double maxScaleFactor = 1.25;

  // ========== ADAPTIVE FONT SCALING ==========
  // Smaller fonts scale less aggressively than larger fonts
  static const Map<String, double> fontSizeMultipliers = {
    'h0': 1.0, // 36px - scale normally
    'h1': 1.0, // 28px - scale normally
    'h2': 0.98, // 22px - scale slightly less
    'h3': 0.96, // 18px - scale less
    'large': 0.94, // 16px - scale even less
    'body': 0.92, // 14px - scale conservatively
    'small': 0.90, // 12px - scale most conservatively
  };

  // ========== WIDTH BREAKPOINTS ==========
  // For granular control across device widths
  static const Map<String, double> widthBreakpoints = {
    'tiny': 320.0, // Very small phones
    'small': 360.0, // Small phones (your 6.4" problem device)
    'medium': 375.0, // iPhone standard
    'standard': 390.0, // Modern standard
    'large': 412.0, // Your emulator (baseline)
    'xlarge': 428.0, // Large phones (your 6.8" device)
    'tablet': 600.0, // Tablets
  };

  // ========== ZONE SCALE FACTORS ==========
  // Manual overrides for specific width zones
  static const Map<String, double> zoneScaleFactors = {
    'tiny': 0.85, // 320-360dp
    'small': 0.90, // 360-375dp  <- Target untuk fix device 6.4"
    'medium': 0.95, // 375-390dp
    'standard': 1.0, // 390-412dp
    'large': 1.0, // 412-428dp  (baseline)
    'xlarge': 1.05, // 428-600dp
    'tablet': 1.2, // 600dp+
  };

  // ========== SCALING MODE ==========
  static const bool useRatioScaling =
      true; // true = smooth ratio, false = zone-based
  static const bool useAdaptiveFontScaling = true; // Apply fontSizeMultipliers

  // ========== SYSTEM TEXT SCALE ==========
  static const bool neutralizeSystemTextScale =
      true; // Force textScaleFactor = 1.0
  static const double forcedTextScaleFactor = 1.0;
}
