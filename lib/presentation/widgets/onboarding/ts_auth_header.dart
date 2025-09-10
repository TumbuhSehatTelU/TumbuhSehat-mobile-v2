import 'package:flutter/material.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../gen/assets.gen.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;

        return Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            // LOGO TUMBUH SEHAT
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                Assets.images.logo.svg(height: isTablet ? 180 : 120),
                const Spacer(flex: 2),
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "T",
                          style: getResponsiveTextStyle(
                            context,
                            TSFont.extraBold.h0.withColor(
                              TSColor.mainTosca.primary,
                            ),
                          ),
                        ),
                        Text(
                          "umbuh",
                          style: getResponsiveTextStyle(
                            context,
                            TSFont.extraBold.h0.withColor(
                              TSColor.monochrome.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Row(
                        children: [
                          Text(
                            "S",
                            style: getResponsiveTextStyle(
                              context,
                              TSFont.extraBold.h0.withColor(
                                TSColor.secondaryGreen.shade400,
                              ),
                            ),
                          ),
                          Text(
                            "ehat",
                            style: getResponsiveTextStyle(
                              context,
                              TSFont.extraBold.h0.withColor(
                                TSColor.monochrome.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 3),
              ],
            ),
            // END OF LOGO
          ],
        );
      },
    );
  }
}
