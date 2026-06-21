import 'package:ascend/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AscendDesignTokens {
  static const double radiusPanel = 24;
  static const double radiusControl = 16;
  static const double radiusBadge = 999;

  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 280);

  static const Color systemLine = AppColors.neonBlue;
  static const Color reward = Color(0xFFE5B95C);
  static const Color risk = Color(0xFFD9566C);
  static const Color vitality = Color(0xFF68C08F);
  static const Color intelligence = Color(0xFF76B7CF);
  static const Color strength = Color(0xFFD9875E);
  static const Color agility = Color(0xFFA28AD6);

  static List<BoxShadow> elevatedSystemShadow(Color accent) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 30,
      offset: const Offset(0, 18),
    ),
    BoxShadow(
      color: accent.withValues(alpha: 0.055),
      blurRadius: 42,
      offset: const Offset(0, 0),
    ),
  ];
}
