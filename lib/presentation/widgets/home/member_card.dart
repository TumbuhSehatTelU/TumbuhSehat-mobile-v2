import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';

class MemberCard extends StatelessWidget {
  final dynamic member;
  final PageController pageController;

  const MemberCard({
    super.key,
    required this.member,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final bool isChild = member is ChildModel;

    final Color color1 = isChild
        ? TSColor.mainTosca.primary
        : TSColor.secondaryGreen.primary;
    final Color color2 = isChild
        ? TSColor.mainTosca.shade100
        : TSColor.secondaryGreen.shade100;
    final Color color3 = isChild
        ? TSColor.mainTosca.shade200
        : TSColor.secondaryGreen.shade200;
    final Color color4 = isChild
        ? TSColor.mainTosca.shade400
        : TSColor.secondaryGreen.shade400;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(64),
        bottomRight: Radius.circular(64),
      ),
      child: MeshGradient(
        points: [
          MeshGradientPoint(position: const Offset(0, 0.2), color: color1),
          MeshGradientPoint(position: const Offset(1, 0.4), color: color2),
          MeshGradientPoint(position: const Offset(0.2, 1), color: color3),
          MeshGradientPoint(position: const Offset(0.8, 0.8), color: color4),
        ],
        options: MeshGradientOptions(blend: 3.5),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
                style: getResponsiveTextStyle(
                  context,
                  TSFont.regular.h3.withColor(TSColor.monochrome.black),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(
                    icon: Icons.arrow_back,
                    onPressed: () {
                      final currentPage = pageController.page!.round();
                      pageController.animateToPage(
                        currentPage - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  Flexible(
                    child: Text(
                      member.name,
                      style: getResponsiveTextStyle(
                        context,
                        TSFont.bold.h1.withColor(TSColor.monochrome.black),
                      ),
                    ),
                  ),
                  _buildNavButton(
                    icon: Icons.arrow_forward,
                    onPressed: () {
                      final currentPage = pageController.page!.round();
                      pageController.animateToPage(
                        currentPage + 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: TSColor.monochrome.pureWhite,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: TSColor.monochrome.black, size: 24),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
