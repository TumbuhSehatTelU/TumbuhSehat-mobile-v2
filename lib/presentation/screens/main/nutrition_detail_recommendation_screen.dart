import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../injection_container.dart';
import '../../cubit/recommendation/recommendation_cubit.dart';
import '../../widgets/history/member_carousel_header.dart';
import '../../widgets/recommendation/day_selector.dart';
import '../../widgets/recommendation/meal_recommendation_card.dart';

class NutritionDetailRecommendationScreen extends StatefulWidget {
  final dynamic initialMember;

  const NutritionDetailRecommendationScreen({
    super.key,
    required this.initialMember,
  });

  @override
  State<NutritionDetailRecommendationScreen> createState() =>
      _NutritionDetailRecommendationScreenState();
}

class _NutritionDetailRecommendationScreenState
    extends State<NutritionDetailRecommendationScreen> {
  late final PageController _pageController;
  List<dynamic> _allMembers = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<RecommendationCubit>()..loadInitialData(widget.initialMember),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Rekomendasi Gizi'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocConsumer<RecommendationCubit, RecommendationState>(
          listener: (context, state) {
            if (state is RecommendationLoaded && _allMembers.isEmpty) {
              _allMembers = state.allMembers;
              final initialIndex = _allMembers.indexWhere(
                (m) => m.name == widget.initialMember.name,
              );
              final validIndex = initialIndex != -1 ? initialIndex : 0;
              final initialPage = _allMembers.length * 100 + validIndex;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _pageController.hasClients) {
                  _pageController.jumpToPage(initialPage);
                }
              });
              setState(() {});
            }
          },
          builder: (context, state) {
            final isChild =
                state is RecommendationLoaded &&
                state.currentMember is ChildModel;
            final color1 = isChild
                ? TSColor.mainTosca.shade500
                : TSColor.secondaryGreen.shade500;
            final color2 = isChild
                ? TSColor.secondaryGreen.shade500
                : TSColor.mainTosca.shade500;

            return Stack(
              children: [
                Positioned.fill(
                  child: MeshGradient(
                    points: [
                      MeshGradientPoint(
                        position: const Offset(0.1, 0.2),
                        color: color1,
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.9, 0.8),
                        color: color2,
                      ),
                    ],
                    options: MeshGradientOptions(blend: 5),
                  ),
                ),

                if (state is RecommendationLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                if (state is RecommendationError)
                  Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                if (state is RecommendationLoaded)
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SafeArea(
                          child: MemberCarouselHeader(
                            members: _allMembers,
                            pageController: _pageController,
                            onPageChanged: (index) {
                              final memberIndex = index % _allMembers.length;
                              context.read<RecommendationCubit>().changeMember(
                                _allMembers[memberIndex],
                              );
                            },
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  DaySelector(
                                    onDaySelected: (day) => context
                                        .read<RecommendationCubit>()
                                        .changeDay(day),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildTotalCalories(state.recommendation),
                                  const SizedBox(height: 16),
                                  ..._buildMealCards(
                                    state.recommendation.meals,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalCalories(RecommendationModel recommendation) {
    final totalCalories = recommendation.meals.values
        .expand((foods) => foods)
        .fold<double>(0, (sum, item) {
          final grams = item.quantity * item.urt.grams;
          return sum + (item.food.calories * (grams / 100.0));
        });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Kalori',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          '${totalCalories.toStringAsFixed(0)} kkal',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<Widget> _buildMealCards(Map<MealTime, List<RecommendedFood>> meals) {
    final sortedMealTimes = meals.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return sortedMealTimes.map((mealTime) {
      return MealRecommendationCard(
        mealTime: mealTime,
        recommendedFoods: meals[mealTime]!,
      );
    }).toList();
  }
}
