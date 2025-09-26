import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../common/circular_nav_button.dart';

class MemberCarouselHeader extends StatelessWidget {
  final List<dynamic> members;
  final PageController pageController;
  final Function(int) onPageChanged;

  const MemberCarouselHeader({
    super.key,
    required this.members,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) {
                final memberIndex = index % members.length;
                final member = members[memberIndex];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularNavButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    Flexible(
                      child: Text(
                        member.name,
                        style: TSFont.getStyle(
                          context,
                          TSFont.bold.h1.withColor(TSColor.monochrome.black),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    CircularNavButton(
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SmoothPageIndicator(
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
        ],
      ),
    );
  }
}
