import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_gradient/mesh_gradient.dart';

import '../../../core/theme/ts_color.dart';
import '../../../injection_container.dart' as di;
import '../../../injection_container.dart';
import '../../cubit/calory_history/calory_history_cubit.dart';

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
          sl<CaloryHistoryCubit>()..loadInitialData(widget.initialMemberName),
      child: Scaffold(
        extendBodyBehindAppBar:
            true,
        appBar: AppBar(
          title: const Text('Riwayat Kalori'),
          backgroundColor: Colors.transparent, 
          elevation: 0,
        ),
        body: BlocConsumer<CaloryHistoryCubit, CaloryHistoryState>(
          listener: (context, state) {
            if (state is CaloryHistoryLoaded && _allMembers.isEmpty) {
              setState(() {
                _allMembers = state.allMembers;
                final initialIndex = _allMembers.indexWhere(
                  (member) => member.name == widget.initialMemberName,
                );
                _currentMemberIndex = (initialIndex != -1) ? initialIndex : 0;

                final initialPage = _allMembers.isNotEmpty
                    ? _allMembers.length * 100 + _currentMemberIndex
                    : 0;
                _pageController = PageController(initialPage: initialPage);
              });
            }
          },
          builder: (context, state) {
            final Color color1 = TSColor.mainTosca.shade100;
            final Color color2 = TSColor.secondaryGreen.shade100;
            final Color color3 = TSColor.mainTosca.shade200;
            final Color color4 = TSColor.secondaryGreen.shade200;

            return Stack(
              children: [
                Positioned.fill(
                  child: MeshGradient(
                    points: [
                      MeshGradientPoint(
                        position: const Offset(0, 0.2),
                        color: color1,
                      ),
                      MeshGradientPoint(
                        position: const Offset(1, 0.4),
                        color: color2,
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.2, 1),
                        color: color3,
                      ),
                      MeshGradientPoint(
                        position: const Offset(0.8, 0.8),
                        color: color4,
                      ),
                    ],
                    options: MeshGradientOptions(blend: 3.5),
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
