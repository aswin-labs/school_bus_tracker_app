import 'package:flutter/widgets.dart';

class Responsive {
  static late double _width;
  static late double _height;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _width = size.width;
    _height = size.height;
  }

  static double w(double percent) => _width * percent / 100;
  static double h(double percent) => _height * percent / 100;
}
