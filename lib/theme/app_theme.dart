import 'package:flutter/cupertino.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = CupertinoColors.systemBlue;
  static const Color backgroundColor = CupertinoColors.systemBackground;
  static const Color secondaryBackgroundColor = CupertinoColors.secondarySystemBackground;
  static const Color labelColor = CupertinoColors.label;
  static const Color secondaryLabelColor = CupertinoColors.secondaryLabel;
  
  // Text Styles
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: CupertinoColors.label,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: CupertinoColors.label,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 17,
    color: CupertinoColors.label,
  );
  
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    color: CupertinoColors.secondaryLabel,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    color: CupertinoColors.secondaryLabel,
  );
  
  // Spacing
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  
  // Border radius
  static const double smallRadius = 6.0;
  static const double mediumRadius = 10.0;
  static const double largeRadius = 16.0;
}
