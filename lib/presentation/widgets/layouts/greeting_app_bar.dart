import 'package:flutter/material.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/parent_model.dart';

class GreetingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ParentModel currentUser;

  const GreetingAppBar({super.key, required this.currentUser});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat pagi';
    } else if (hour < 15) {
      return 'Selamat siang';
    } else if (hour < 18) {
      return 'Selamat sore';
    } else {
      return 'Selamat malam';
    }
  }

  String get _displayName {
    switch (currentUser.role) {
      case ParentRole.ibu:
        return 'Ibu ${currentUser.name.split(' ').first}';
      case ParentRole.ayah:
        return 'Ayah ${currentUser.name.split(' ').first}';
      default:
        return currentUser.name.split(' ').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TSColor.monochrome.white,
        boxShadow: TSShadow.shadows.weight500,
      ),
      child: AppBar(
        backgroundColor: TSColor.monochrome.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting,
              style: getResponsiveTextStyle(
                context,
                TSFont.regular.body.withColor(TSColor.monochrome.black),
              ),
            ),
            Text(
              _displayName,
              style: getResponsiveTextStyle(
                context,
                TSFont.bold.large.withColor(TSColor.monochrome.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
