// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:mobile_tumbuh_sehat_v2/presentation/widgets/layouts/ts_app_bar.dart';

import '../../../core/theme/ts_color.dart';
import '../../../data/models/child_model.dart';
import '../../../injection_container.dart' as di;
import '../../../injection_container.dart';
import '../../cubit/calory_history/calory_history_cubit.dart';
import '../../widgets/history/member_carousel_header.dart';

class CaloryHistoryScreen extends StatefulWidget {
  final String initialMemberName;

  const CaloryHistoryScreen({super.key, required this.initialMemberName});

  @override
  State<CaloryHistoryScreen> createState() => _CaloryHistoryScreenState();
}

class _CaloryHistoryScreenState extends State<CaloryHistoryScreen> {
  late final PageController _pageController;
  int _currentMemberIndex = 0;
  List<dynamic> _allMembers = [];
  DateTime _selectedDate = DateTime.now();
  CaloryChartRange _chartRange = CaloryChartRange.oneMonth;
  List<Color> _gradientColors = [];
  List<Color> _getGradientColors({required bool isChild}) {
    if (isChild) {
      return [
        TSColor.mainTosca.shade100,
        TSColor.secondaryGreen.shade100,
        TSColor.mainTosca.shade200,
        TSColor.secondaryGreen.shade200,
        TSColor.additionalColor.blue.withOpacity(0.5),
        TSColor.mainTosca.primary,
      ];
    } else {
      return [
        TSColor.secondaryGreen.primary,
        TSColor.additionalColor.orange.withOpacity(0.7),
        TSColor.mainTosca.shade500,
        TSColor.secondaryGreen.shade400,
        TSColor.additionalColor.red.withOpacity(0.6),
        TSColor.mainTosca.shade600,
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _gradientColors = _getGradientColors(isChild: true);
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
          sl<CaloryHistoryCubit>()..loadInitialData(widget.initialMemberName),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: TSAppBar(title: "Riwayat Kalori"),
        body: BlocConsumer<CaloryHistoryCubit, CaloryHistoryState>(
          listener: (context, state) {
            if (state is CaloryHistoryLoaded && _allMembers.isEmpty) {
              _allMembers = state.allMembers;
              final initialIndex = _allMembers.indexWhere(
                (member) => member.name == widget.initialMemberName,
              );
              _currentMemberIndex = (initialIndex != -1) ? initialIndex : 0;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _pageController.hasClients) {
                  final initialPage =
                      _allMembers.length * 100 + _currentMemberIndex;
                  _pageController.jumpToPage(initialPage);
                }
              });
              setState(() {});
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: MeshGradient(
                    points: [
                      MeshGradientPoint(
                        position: const Offset(0.1, 0.2),
                        color: _gradientColors[0],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.8, 0.1),
                        color: _gradientColors[1],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.5, 0.5),
                        color: _gradientColors[2],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.9, 0.8),
                        color: _gradientColors[3],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.2, 0.9),
                        color: _gradientColors[4],
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.6, 0.0),
                        color: _gradientColors[5],
                      ),
                    ],
                    options: MeshGradientOptions(blend: 4),
                  ),
                ),

                if (state is CaloryHistoryLoading && _allMembers.isEmpty)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),

                if (state is CaloryHistoryError)
                  Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                if (state is CaloryHistoryLoaded)
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SafeArea(
                          child: MemberCarouselHeader(
                            members: _allMembers,
                            pageController: _pageController,
                            onPageChanged: (index) {
                              final memberIndex = index % _allMembers.length;
                              if (_currentMemberIndex != memberIndex) {
                                setState(() {
                                  _currentMemberIndex = memberIndex;
                                  final currentMember =
                                      _allMembers[memberIndex];
                                  _gradientColors = _getGradientColors(
                                    isChild: currentMember is ChildModel,
                                  );
                                });
                                context.read<CaloryHistoryCubit>().changeMember(
                                  _allMembers[memberIndex],
                                );
                              }
                            },
                          ),
                        ),
                      ),

                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 400,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(32),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Konten untuk ${state.currentMember.name}',
                                ),
                              ),
                            ),
                          ],
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
}
