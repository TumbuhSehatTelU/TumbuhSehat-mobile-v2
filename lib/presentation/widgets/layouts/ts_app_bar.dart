import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';

class TSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackButtonPressed;
  final bool showBackButton;
  final TextStyle? tsFont;

  const TSAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackButtonPressed,
    this.showBackButton = true,
    this.tsFont,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        boxShadow: TSShadow.shadows.weight500,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                title,
                style: getResponsiveTextStyle(
                  context,
                  tsFont ?? TSFont.bold.h2,
                ),
              ),

              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: TSColor.monochrome.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: TSShadow.shadows.weight500,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed:
                          onBackButtonPressed ??
                          () => Navigator.of(context).pop(),
                    ),
                  ),
                ),

              if (actions != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
