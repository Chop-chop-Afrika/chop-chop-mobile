import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SizesExt on num{
  //double get pW => ScreenUtil.defaultSize.width * this / 100;
  double get pW => ScreenUtil().screenWidth * this / 100;
  //double get pH => ScreenUtil().screenHeight * this / 100;
  double get pH => ScreenUtil.defaultSize.height * this / 100;
  Expanded get flex => Expanded(flex: this.toInt(), child: Container(),);
}
extension spaces on num{
  SizedBox get gap => SizedBox.square(dimension: this.h.pH);
}

double totalAppHeight(BuildContext context){
  double totalAppHeight = MediaQuery.of(context).size.height;
  return totalAppHeight;
}
double totalAppWidth(BuildContext context){
  double totalAppWidth = MediaQuery.of(context).size.width;
  return totalAppWidth;
}

//to account for tablets
extension DeviceTypeExtension on BuildContext {
  bool get isTablet {
    final size = MediaQuery.of(this).size;
    final diagonal = sqrt((size.width * size.width) + (size.height * size.height));
    return diagonal > 1100.0; // heuristic: > 1100dp = tablet
  }

  bool get isPhone => !isTablet;
}