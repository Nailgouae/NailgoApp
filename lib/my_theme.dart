import 'package:flutter/material.dart';

class MyTheme {
  /*configurable colors stars*/
  // static Color accent_color = Color.fromRGBO(21, 105, 56, 1);
  static Color primary_color = const Color(0xffbf5b04);
  static Color soft_primary_color = const Color(0xffc07c40);
  static Color secondary_color = const Color(0xff34B676);
  static Color low_primary_color = const Color(0x73c07c40);


  static Color splash_screen_color =
      primary_color; // if not sure , use the same color as accent color
  /*configurable colors ends*/

  /*If you are not a developer, do not change the bottom colors*/
  static Color white = const Color.fromRGBO(255, 255, 255, 1);
  static Color light_grey = const Color.fromRGBO(239, 239, 239, 1);
  static Color dark_grey = const Color.fromRGBO(112, 112, 112, 1);
  static Color medium_grey = const Color.fromRGBO(132, 132, 132, 1);
  static Color grey_153 = const Color.fromRGBO(153, 153, 153, 1);
  static Color font_grey = const Color.fromRGBO(73, 73, 73, 1);
  static Color textfield_grey = const Color.fromRGBO(209, 209, 209, 1);
  static Color golden = const Color.fromRGBO(248, 181, 91, 1);
  static Color shimmer_base = Colors.grey.shade50;
  static Color shimmer_highlighted = Colors.grey.shade200;
  static Color textGreen = Color(0xff024a59);

//testing shimmer
  /*static Color shimmer_base = Colors.redAccent;
  static Color shimmer_highlighted = Colors.yellow;*/
}
