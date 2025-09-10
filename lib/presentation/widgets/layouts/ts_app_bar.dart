import 'package:flutter/material.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_color.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_shadow.dart';

class TSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackButtonPressed;
  final bool showBackButton;

  const TSAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onBackButtonPressed,
    this.showBackButton = true,
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
                style: getResponsiveTextStyle(context, TSFont.bold.h1),
              ),

              if (showBackButton)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: TSColor.monochrome.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: TSShadow.shadows.weight400,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
