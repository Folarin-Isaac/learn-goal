import 'package:flutter/material.dart';
import 'package:lengoal/core/theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // The bright blue used for links, tab labels and secondary actions.
  // AppColors.accentBlue is too dark to read on the dark background, so dark
  // mode swaps in the same light brand blue as the theme's primary.
  Color get accentForeground =>
      isDarkMode ? AppColors.brandBlueOnDark : AppColors.accentBlue;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

  void unfocus() => FocusScope.of(this).unfocus();
}
