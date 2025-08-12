import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getBaseSize(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.8; // Small screens
    } else if (screenWidth < 900) {
      return baseSize; // Medium screens
    } else {
      return baseSize * 1.2; // Large screens
    }
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 48.0; // Small screens
    } else if (screenWidth < 900) {
      return 56.0; // Medium screens
    } else {
      return 64.0; // Large screens
    }
  }

  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseElevation * 0.8; // Small screens
    } else if (screenWidth < 900) {
      return baseElevation; // Medium screens
    } else {
      return baseElevation * 1.2; // Large screens
    }
  }

  static BorderRadius getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return BorderRadius.circular(baseRadius * 0.8); // Small screens
    } else if (screenWidth < 900) {
      return BorderRadius.circular(baseRadius); // Medium screens
    } else {
      return BorderRadius.circular(baseRadius * 1.2); // Large screens
    }
  }

  static EdgeInsets getResponsiveMargin(BuildContext context, {double? all, double? horizontal, double? vertical}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double multiplier = 1.0;
    
    if (screenWidth < 600) {
      multiplier = 0.8; // Small screens
    } else if (screenWidth < 900) {
      multiplier = 1.0; // Medium screens
    } else {
      multiplier = 1.2; // Large screens
    }

    if (all != null) {
      return EdgeInsets.all(all * multiplier);
    } else if (horizontal != null && vertical != null) {
      return EdgeInsets.symmetric(horizontal: horizontal * multiplier, vertical: vertical * multiplier);
    } else if (horizontal != null) {
      return EdgeInsets.symmetric(horizontal: horizontal * multiplier);
    } else if (vertical != null) {
      return EdgeInsets.symmetric(vertical: vertical * multiplier);
    }
    
    return EdgeInsets.zero;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {double? horizontal, double? vertical}) {
    final screenWidth = MediaQuery.of(context).size.width;
    double multiplier = 1.0;
    
    if (screenWidth < 600) {
      multiplier = 0.8; // Small screens
    } else if (screenWidth < 900) {
      multiplier = 1.0; // Medium screens
    } else {
      multiplier = 1.2; // Large screens
    }

    if (horizontal != null && vertical != null) {
      return EdgeInsets.symmetric(horizontal: horizontal * multiplier, vertical: vertical * multiplier);
    } else if (horizontal != null) {
      return EdgeInsets.symmetric(horizontal: horizontal * multiplier);
    } else if (vertical != null) {
      return EdgeInsets.symmetric(vertical: vertical * multiplier);
    }
    
    return EdgeInsets.zero;
  }

  static double getResponsiveBorderWidth(BuildContext context, double baseWidth) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseWidth * 0.8; // Small screens
    } else if (screenWidth < 900) {
      return baseWidth; // Medium screens
    } else {
      return baseWidth * 1.2; // Large screens
    }
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSize * 0.8; // Small screens
    } else if (screenWidth < 900) {
      return baseSize; // Medium screens
    } else {
      return baseSize * 1.2; // Large screens
    }
  }

  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return baseSpacing * 0.8; // Small screens
    } else if (screenWidth < 900) {
      return baseSpacing; // Medium screens
    } else {
      return baseSpacing * 1.2; // Large screens
    }
  }
}
