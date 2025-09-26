// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../cubit/beranda/beranda_cubit.dart';
import '../../widgets/home/skeletons/recommendation_card_skeleton.dart';
import '../../widgets/home/skeletons/weekly_chart_skeleton.dart';
import '../../widgets/home/weekly_calory_chart.dart';
import '../../widgets/layouts/greeting_app_bar.dart';
import '../../widgets/home/member_carousel.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/recommendation/meal_recommendation_card.dart';
import 'calory_history_screen.dart';
import 'nutrition_detail_recommendation_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  PageController? _pageController;
  int _currentPageIndex = 0;
  List<dynamic> _allMembers = [];

  @override
  void initState() {
    super.initState();
    context.read<BerandaCubit>().loadBerandaData();
  }

  @override
  void dispose() {
    _pageController?.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: context.watch<BerandaCubit>().state is BerandaLoaded
          ? GreetingAppBar(
              loggedInUser:
                  (context.read<BerandaCubit>().state as BerandaLoaded)
                      .family
                      .parents
                      .first,
              displayedMember:
                  (context.read<BerandaCubit>().state as BerandaLoaded)
                      .currentUser,
            )
          : null,
      body: BlocConsumer<BerandaCubit, BerandaState>(
        listener: (context, state) {
          if (state is BerandaLoaded && _pageController == null) {
            _allMembers = [...state.family.children, ...state.family.parents];
            _currentPageIndex = state.initialMemberIndex;
            _pageController = PageController(
              viewportFraction: 1.0,
              initialPage: _allMembers.length * 100 + _currentPageIndex,
            );
            setState(() {});
          }
        },
        builder: (context, state) {
          if (_pageController == null || state is BerandaInitial) {
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
            if (_pageController == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final hour = DateTime.now().hour;
            String title;
            RecommendationModel recommendationToShow;
            bool isForToday;

            if (hour < 22) {
              title = 'Rekomendasi Asupan Gizi';
              recommendationToShow = state.recommendationForToday;
              isForToday = true;
            } else {
              title = 'Rekomendasi Asupan Gizi\nHari Esok';
              recommendationToShow = state.recommendationForTomorrow;
              isForToday = false;
            }
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
                      pageController: _pageController!,
                      onPageChanged: (index) {
                        final memberIndex = index % _allMembers.length;
                        context.read<BerandaCubit>().changeMember(
                          _allMembers[memberIndex],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (state.isChangingMember)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          WeeklyChartSkeleton(),
                          SizedBox(height: 24),
                          RecommendationCardSkeleton(),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        _buildWeeklyHistorySection(
                          context: context,
                          title: 'Kebutuhan Kalori Mingguan',
                          buttonText: 'Lihat Riwayat Kalori',
                          onPressed: _navigateToHistory,
                        ),
                        const SizedBox(height: 48),
                        _buildRecommendationSection(
                          context,
                          title: title,
                          recommendation: recommendationToShow,
                          isForToday: isForToday,
                          currentMemberName: state.currentUser.name,
                        ),
                        const SizedBox(height: 124),
                      ],
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

  Widget _buildRecommendationSection(
    BuildContext context, {
    required String title,
    required RecommendationModel recommendation,
    required bool isForToday,
    required String currentMemberName,
  }) {
    final relevantMealTime = getNextRelevantMealTime(
      recommendation,
      isForToday: isForToday,
    );

    final List<RecommendedFood> recommendedFoods = relevantMealTime != null
        ? recommendation.meals[relevantMealTime] ?? []
        : [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TSFont.getStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.black),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          if (relevantMealTime != null && recommendedFoods.isNotEmpty)
            MealRecommendationCard(
              mealTime: relevantMealTime,
              recommendedFoods: recommendedFoods,
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: TSColor.monochrome.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: TSShadow.shadows.weight400,
              ),
              child: Center(
                child: Text(
                  isForToday
                      ? 'Anda telah memenuhi\nkebutuhan gizi hari ini.'
                      : 'Sarapan untuk esok hari.',
                  style: TSFont.getStyle(context, TSFont.semiBold.large),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          const SizedBox(height: 16),
          TSButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NutritionDetailRecommendationScreen(
                    initialMemberName: currentMemberName,
                  ),
                ),
              );
            },
            text: 'Lihat Detail',
            textStyle: TSFont.getStyle(
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

  Widget _buildWeeklyHistorySection({
    required BuildContext context,
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
            style: TSFont.getStyle(
              context,
              TSFont.bold.h2.withColor(TSColor.monochrome.black),
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<BerandaCubit, BerandaState>(
            builder: (context, state) {
              if (state is BerandaLoaded) {
                return WeeklyCaloryChart(
                  dailyIntakes: state.weeklySummary.dailyIntakes,
                  akg: state.weeklySummary.akgStandard,
                );
              }
              return Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('Memuat data chart...')),
              );
            },
          ),
          const SizedBox(height: 16),
          TSButton(
            onPressed: onPressed,
            text: buttonText,
            textStyle: TSFont.getStyle(
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
