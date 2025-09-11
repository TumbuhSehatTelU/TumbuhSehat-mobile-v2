import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';

import '../../../core/theme/ts_color.dart';
import '../../cubit/beranda/beranda_cubit.dart';
import '../../widgets/layouts/greeting_app_bar.dart';
import '../../widgets/home/member_carousel.dart';
import '../../widgets/common/ts_button.dart';
import 'calory_history_screen.dart';
import 'nutrition_detail_recommendation_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
  List<dynamic> _allMembers = [];

  @override
  void initState() {
    super.initState();
    context.read<BerandaCubit>().loadBerandaData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToHistory() {
    if (_allMembers.isNotEmpty) {
      final memberIndex = _currentPageIndex % _allMembers.length;
      final currentMember = _allMembers[memberIndex];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CaloryHistoryScreen(initialMemberName: currentMember.name),
        ),
      );
    }
  }

  void _navigateToDetailsRecommendation() {
    if (_allMembers.isNotEmpty) {
      final memberIndex = _currentPageIndex % _allMembers.length;
      final currentMember = _allMembers[memberIndex];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NutritionDetailRecommendationScreen(
            memberName: currentMember.name,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: context.watch<BerandaCubit>().state is BerandaLoaded
          ? GreetingAppBar(
              currentUser: (context.read<BerandaCubit>().state as BerandaLoaded)
                  .currentUser,
            )
          : null,
      body: BlocConsumer<BerandaCubit, BerandaState>(
        listener: (context, state) {
          if (state is BerandaLoaded) {
            if (_allMembers.isEmpty) {
              setState(() {
                _allMembers = [
                  ...state.family.children,
                  ...state.family.parents,
                ];
                int initialPage = 0;
                if (_allMembers.isNotEmpty) {
                  final int itemCount = _allMembers.length * 1000;
                  initialPage = (itemCount / 2).floor();

                  final remainder = initialPage % _allMembers.length;
                  initialPage -= remainder;
                }
                _pageController = PageController(
                  viewportFraction: 1.0,
                  initialPage: initialPage,
                );
                _currentPageIndex = 0;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is BerandaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BerandaError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(state.message),
              ),
            );
          }
          if (state is BerandaLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(64),
                        bottomRight: Radius.circular(64),
                      ),
                      boxShadow: TSShadow.shadows.weight500,
                    ),
                    child: MemberCarousel(
                      members: _allMembers,
                      pageController: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildContentSection(
                    title: 'Kebutuhan Kalori Mingguan',
                    buttonText: 'Lihat Riwayat Kalori',
                    onPressed: _navigateToHistory,
                  ),
                  const SizedBox(height: 24),
                  _buildContentSection(
                    title: 'Rekomendasi Asupan Gizi',
                    buttonText: 'Lihat Detail',
                    onPressed: _navigateToDetailsRecommendation,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: getResponsiveTextStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.black),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Text('Postpone')),
          ),
          const SizedBox(height: 16),
          TSButton(
            onPressed: onPressed,
            text: buttonText,
            textStyle: getResponsiveTextStyle(
              context,
              TSFont.bold.large.withColor(TSColor.monochrome.black),
            ),
            boxShadow: TSShadow.shadows.weight400,
            backgroundColor: TSColor.secondaryGreen.primary,
            contentColor: TSColor.monochrome.black,
            borderColor: Colors.transparent,
            width: double.infinity,
            customBorderRadius: 240,
          ),
        ],
      ),
    );
  }
}
