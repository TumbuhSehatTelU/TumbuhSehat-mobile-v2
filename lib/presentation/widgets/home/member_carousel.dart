// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/theme/ts_color.dart';
import 'member_card.dart';

class MemberCarousel extends StatelessWidget {
  final List<dynamic> members;
  final PageController pageController;
  final Function(int) onPageChanged;

  const MemberCarousel({
    super.key,
    required this.members,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();
    final int itemCount = members.length * 1000;
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final memberIndex = index % members.length;
              return MemberCard(
                member: members[memberIndex],
                pageController: pageController,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SmoothPageIndicator(
              controller: pageController,
              count: members.length,
              onDotClicked: (index) {
                final currentPage = pageController.page!.floor();
                final currentMemberIndex = currentPage % members.length;
                final pageOffset = currentPage - currentMemberIndex;
                pageController.animateToPage(
                  pageOffset + index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: TSColor.mainTosca.shade500,
                dotColor: TSColor.monochrome.pureWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
