import 'package:flutter/cupertino.dart';

class GlobalProps {
  static const double radiusSmall = 5;
  static const double radius = 10;
  static const double radiusBig = 20;
  static const double radiusLarge = 30;

  static RoundedRectangleBorder get roundedBorderSmall => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSmall));

  static RoundedRectangleBorder get roundedBorder => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  static RoundedRectangleBorder get roundedBorderBig => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusBig));

  static RoundedRectangleBorder get roundedBorderLarge => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLarge));

  static Duration get animationDuration => const Duration(milliseconds: 300);
}
