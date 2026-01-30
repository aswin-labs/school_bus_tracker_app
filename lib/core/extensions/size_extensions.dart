import 'package:flutter/widgets.dart';
import '../responsive/responsive.dart';

extension SizeExtension on num {
  // for spacing widgets
  SizedBox get h => SizedBox(height: Responsive.h(toDouble()));
  SizedBox get w => SizedBox(width: Responsive.w(toDouble()));

  // for numeric values (padding, radius, fontSize, etc.)
  double get hp => Responsive.h(toDouble());
  double get wp => Responsive.w(toDouble());
}
