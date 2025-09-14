import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_text_style.dart';
import 'package:mobile_tumbuh_sehat_v2/presentation/widgets/layouts/ts_app_bar.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/daily_detail_model.dart';
import '../../../injection_container.dart';
import '../../cubit/daily_detail/daily_detail_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/detail/meal_time_expansion_tile.dart';
import '../../widgets/history/member_carousel_header.dart';

class DailyConsumptionDetailScreen extends StatefulWidget {
  final dynamic member;
  final DateTime date;

  const DailyConsumptionDetailScreen({
    super.key,
    required this.member,
    required this.date,
  });

  @override
  State<DailyConsumptionDetailScreen> createState() =>
      _DailyConsumptionDetailScreenState();
}

class _DailyConsumptionDetailScreenState
    extends State<DailyConsumptionDetailScreen> {
  late final PageController _pageController;
  List<dynamic> _allMembers = [];
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selectedDate = widget.date;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final cubit = context.read<DailyDetailCubit>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      cubit.changeDate(picked);
    }
  }

  List<Color> _getGradientColors({required bool isChild}) {
    if (isChild) {
      return [
        TSColor.mainTosca.shade100,
        TSColor.mainTosca.shade400,
        TSColor.mainTosca.shade200,
        TSColor.mainTosca.primary,
        TSColor.secondaryGreen.shade200,
        TSColor.mainTosca.primary,
      ];
    } else {
      return [
        TSColor.secondaryGreen.primary,
        TSColor.secondaryGreen.shade200,
        TSColor.secondaryGreen.shade200,
        TSColor.secondaryGreen.shade500,
        TSColor.mainTosca.shade200,
        TSColor.secondaryGreen.shade100,
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DailyDetailCubit>()..loadInitialData(widget.member, _selectedDate),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: TSAppBar(title: 'Detail Konsumsi Gizi', tsFont: TSFont.bold.h2),
        body: BlocConsumer<DailyDetailCubit, DailyDetailState>(
          listener: (context, state) {
            if (state is DailyDetailLoaded && _allMembers.isEmpty) {
              _allMembers = state.allMembers;
              final initialIndex = _allMembers.indexWhere(
                (m) => m.name == widget.member.name,
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
            bool isChild = false;
            if (state is DailyDetailLoaded) {
              isChild = state.currentMember is ChildModel;
            } else {
              isChild = widget.member is ChildModel;
            }
            final gradientColors = _getGradientColors(isChild: isChild);

            return Stack(
              children: [
                Positioned.fill(
                  child: MeshGradient(
                    points: [
                      MeshGradientPoint(
                        position: const Offset(0, 0.2),
                        color: gradientColors[0],
                      ),
                      MeshGradientPoint(
                        position: const Offset(1, 0.4),
                        color: gradientColors[1],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.2, 1),
                        color: gradientColors[2],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.8, 0.8),
                        color: gradientColors[3],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.8, 0.5),
                        color: gradientColors[4],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.9, 0.1),
                        color: gradientColors[5],
                      ),
                    ],
                    options: MeshGradientOptions(blend: 3),
                  ),
                ),
                if (state is DailyDetailLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                if (state is DailyDetailError)
                  Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                if (state is DailyDetailLoaded)
                  Column(
                    children: [
                      SafeArea(
                        child: MemberCarouselHeader(
                          members: _allMembers,
                          pageController: _pageController,
                          onPageChanged: (index) {
                            final memberIndex = index % _allMembers.length;
                            context.read<DailyDetailCubit>().changeMember(
                              _allMembers[memberIndex],
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: TSColor.monochrome.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Konsumsi Gizi Harian',
                                  style: getResponsiveTextStyle(
                                    context,
                                    TSFont.bold.h2.withColor(
                                      TSColor.monochrome.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pilih Tanggal untuk Melihat Konsumsi Gizi',
                                  style: getResponsiveTextStyle(
                                    context,
                                    TSFont.regular.large.withColor(
                                      TSColor.monochrome.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TSButton(
                                  onPressed: () => _selectDate(context),
                                  text: DateFormat(
                                    'EEEE, d MMMM yyyy',
                                    'id_ID',
                                  ).format(_selectedDate),
                                  icon: Icons.calendar_month_rounded,
                                  style: ButtonStyleType.rightIcon,
                                  textStyle: getResponsiveTextStyle(
                                    context,
                                    TSFont.bold.large.withColor(
                                      TSColor.monochrome.black,
                                    ),
                                  ),
                                  backgroundColor:
                                      TSColor.secondaryGreen.shade200,
                                  borderColor: Colors.transparent,
                                  customBorderRadius: 240,
                                  boxShadow: TSShadow.shadows.weight300,
                                  contentColor: TSColor.monochrome.black,
                                  width: double.infinity,
                                ),
                                const SizedBox(height: 24),
                                if (state.detail.meals.isEmpty)
                                  const Center(
                                    child: Text(
                                      'Tidak ada data untuk tanggal ini.',
                                    ),
                                  )
                                else
                                  ..._buildMealTiles(state.detail.meals),
                              ],
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

  List<Widget> _buildMealTiles(Map<MealTime, List<FoodDetail>> meals) {
    final sortedMealTimes = meals.keys.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    return sortedMealTimes.map((mealTime) {
      final foods = meals[mealTime]!;
      final timestampMillis = foods.first.calculatedNutrients['timestamp'];
      final time = timestampMillis != null
          ? DateTime.fromMillisecondsSinceEpoch(timestampMillis.toInt())
          : DateTime.now();

      final timeFormatted = DateFormat('HH:mm').format(time);

      return MealTimeExpansionTile(
        title: mealTime.name,
        time: timeFormatted,
        foods: foods,
      );
    }).toList();
  }
}
