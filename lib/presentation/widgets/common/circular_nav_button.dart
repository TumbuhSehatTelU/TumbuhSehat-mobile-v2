import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';

class CircularNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CircularNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: TSColor.monochrome.pureWhite,
        shape: BoxShape.circle,
        boxShadow: TSShadow.shadows.weight100,
      ),
      child: IconButton(
        icon: Icon(icon, color: TSColor.monochrome.black, size: 24),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
