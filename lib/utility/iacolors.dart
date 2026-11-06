import 'package:flutter/material.dart';

class IAColors {
  static Color primary = const Color(0xFFE45D31);
  static Color veryLightGrey = const Color(0xFFf5f5f5);
  static Color lightGrey = const Color(0xFFe0e0e0);
  static Color grey = const Color(0xFF9e9e9e);
  static Color appBarLightGrey = const Color(0xFFE0E0E0);
  static Color darkGrey = const Color(0xFF616161);
  static Color veryDarkGrey = const Color(0xFF424242);
  static Color dialogDark = const Color(0xFF484848);
  // the grey every form field is filled with
  static Color fieldFill = const Color(0xFFEEEEEE);
  // the near-black the Figma sets headings, body copy and field labels in.
  // Pure black is harsher than anything in the design.
  static Color ink = const Color(0xFF1E1E1E);
  // destructive actions, kept apart from the brand orange
  static Color danger = const Color(0xFFD32F2F);
  static Color aiBlue = const Color(0xff1BB6E9);

  // blue
  static Color blue = Colors.blue.shade200;

  // Primary (based on #E45D31, sampled from the Figma). The whole ramp is the
  // same hue and saturation at descending lightness, so the tints stay in
  // step with the base rather than drifting from it.
  static Color primary_10 = const Color(0xFFF8D8CD);
  static Color primary_20 = const Color(0xFFF3B8A5);
  static Color primary_30 = const Color(0xFFEE987C);
  static Color primary_40 = const Color(0xFFE97854);
  static Color primary_50 = const Color(0xFFE45D31); // Base
  static Color primary_60 = const Color(0xFFCB461B);
  static Color primary_dark = const Color(0xFFB03D17);
  static Color primary_80 = const Color(0xFF8C3012);
  static Color primary_90 = const Color(0xFF68240E);
  static Color primary_100 = const Color(0xFF3F1608);

  static Color white = const Color(0xFFFFFFFF);
  static Color black = const Color(0xFF000000);

  static Color secondary = const Color(0xFF005EC4);
  static Color secondary_10 = const Color(0xFFCCE2FF);
  static Color secondary_20 = const Color(0xFF99C5FF);
  static Color secondary_30 = const Color(0xFF66A8FF);
  static Color secondary_40 = const Color(0xFF338BFF);
  static Color secondary_50 = const Color(0xFF006EFF);
  static Color secondary_60 = const Color(0xFF005AC4);
  static Color secondary_70 = const Color(0xFF0046FF);
  static Color secondary_80 = const Color(0xFF0032FF);
  static Color secondary_90 = const Color(0xFF001BFF);
  static Color secondary_100 = const Color(0xFF0007FF);
  static Color secondary_dark = const Color(0xFF0000CC);
}
