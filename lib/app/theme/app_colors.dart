import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color canvas = Color(0xFFFDF8F5);          // Coral Cream Canvas
  static const Color surface = Color(0xFFFFFFFF);         // Pure White Cards/Sheets
  static const Color ink = Color(0xFF1E1B1A);             // Deep Dark Cocoa Text
  static const Color muted = Color(0xFF484551);           // Material on-surface-variant (DESIGN.md #484551)
  static const Color faint = Color(0xFF797582);           // Material outline (DESIGN.md #797582)
  static const Color primary = Color(0xFF372475);         // Deep Purple Brand Mark/Titles
  static const Color violet = Color(0xFF4D41DF);          // Electric Violet Secondary (DESIGN.md #4d41df)
  static const Color cta = Color(0xFFEF8A62);             // Brand Coral CTA
  static const Color success = Color(0xFF10B981);         // Emerald Green Success
  static const Color danger = Color(0xFFBA1A1A);          // Crimson Red Danger (DESIGN.md #ba1a1a)
  static const Color pending = Color(0xFFD97706);         // Amber Pending (DESIGN.md Amber/Outline)
  static const Color border = Color(0x141E1B1A);          // Subtle Cocoa border

  // Pastel Blobs (for atmospheric background)
  static const Color blobCoral = Color(0x40F5C4B3);       // Coral orange (25% opacity)
  static const Color blobLavender = Color(0x33C8C5F8);    // Lavender violet (20% opacity)
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(
      color: Color(0x0A1E1B1A),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get navShadow => const [
    BoxShadow(
      color: Color(0x0A1E1B1A),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];

  static List<BoxShadow> get floatingShadow => const [
    BoxShadow(
      color: Color(0x101E1B1A),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}
