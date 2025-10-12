import 'package:flutter/material.dart';

import '../constants/font_scaling_config.dart';

class TextScaleWrapper extends StatelessWidget {
  final Widget child;

  const TextScaleWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!FontScalingConfig.neutralizeSystemTextScale) {
      return child;
    }

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(FontScalingConfig.forcedTextScaleFactor)),
      child: child,
    );
  }
}
