import 'package:flutter/material.dart';

class AppTextStyles {
  const new();

  static const String headingFamily = 'Inter';
  static const String bodyFamily = 'Manrope';

  static const TextStyle h1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 28,
    fontWeight: .w700,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 22,
    fontWeight: .w700,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 18,
    fontWeight: .w600,
  );
  static const TextStyle h4 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 16,
    fontWeight: .w600,
  );
  static const TextStyle button = TextStyle(
    fontFamily: headingFamily,
    fontSize: 16,
    fontWeight: .w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 15,
    fontWeight: .w400,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: .w400,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: .w400,
  );
}
