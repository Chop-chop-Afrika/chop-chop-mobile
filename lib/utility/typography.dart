import 'package:flutter/material.dart';

import 'iacolors.dart';

/// One type scale for the whole app.
///
/// Before this, sizes were written inline wherever they were needed — twenty
/// distinct values across the Pages folder, some fixed and some a percentage
/// of screen width, which is why headings and their captions ended up the same
/// size and why text grew out of proportion on larger phones. Everything here
/// is in points, so a heading stays a heading on every device.
class IAText {
  /// Hero text. One per screen at most: a product name on its own sheet.
  static TextStyle display({Color? color}) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.25,
        color: color ?? IAColors.black,
      );

  /// Screen sections and the name of the thing you are looking at.
  static TextStyle title({Color? color}) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: color ?? IAColors.black,
      );

  /// Card headings, the row above a price.
  static TextStyle subtitle({Color? color}) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color ?? IAColors.black,
      );

  /// Running text.
  static TextStyle body({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 14,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.45,
        color: color ?? IAColors.black,
      );

  /// Tabs, field labels, the value in a stat.
  static TextStyle label({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 13,
        fontWeight: weight ?? FontWeight.w500,
        height: 1.35,
        color: color ?? IAColors.black,
      );

  /// Supporting detail: the grey line under a name.
  static TextStyle caption({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 12,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.35,
        color: color ?? IAColors.darkGrey,
      );

  /// Smallest readable size. Stat labels, badges.
  static TextStyle micro({Color? color, FontWeight? weight}) => TextStyle(
        fontSize: 11,
        fontWeight: weight ?? FontWeight.w500,
        height: 1.3,
        color: color ?? IAColors.darkGrey,
      );
}
