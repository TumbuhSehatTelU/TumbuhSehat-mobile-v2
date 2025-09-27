import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/family_model.dart';
import '../../../data/models/parent_model.dart';
import '../../../gen/assets.gen.dart';
import '../../cubit/scan/scan_cubit.dart';
import '../../widgets/meal_analysis/analysis_card.dart';
import '../../widgets/meal_analysis/family_expansion_tile.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../scan/manual_input_screen.dart';
import '../scan/photo_scan_screen.dart';
import '../scan/video_scan_screen.dart';

enum AnalysisType { manual, photo, video }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  AnalysisType? _selectedType;
  final Set<ParentModel> _selectedParents = {};
  final Set<ChildModel> _selectedChildren = {};

  @override
  void initState() {
    super.initState();
    context.read<ScanCubit>().loadFamilyData();
  }

  void _onContinue() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih cara menganalisis makanan')),
      );
      return;
    }
    if (_selectedParents.isEmpty && _selectedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu anggota keluarga')),
      );
      return;
    }

    Widget destination;
    switch (_selectedType!) {
      case AnalysisType.manual:
        destination = ManualInputScreen(
          selectedParents: _selectedParents,
          selectedChildren: _selectedChildren,
        );
        break;
      case AnalysisType.photo:
        destination = PhotoScanScreen(
          selectedParents: _selectedParents,
          selectedChildren: _selectedChildren,
        );
        break;
      case AnalysisType.video:
        destination = const VideoScanScreen();
        break;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => destination));
  }

  Widget _buildContent(FamilyModel family) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            'Pilih cara menganalisis makanan',
            style: TSFont.getStyle(
              context,
              TSFont.bold.h3.withColor(TSColor.monochrome.black),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AnalysisCard(
            assetPath: Assets.icons.inputManual.path,
            text: 'Input Manual',
            isSelected: _selectedType == AnalysisType.manual,
            onTap: () => setState(() => _selectedType = AnalysisType.manual),
          ),
          AnalysisCard(
            assetPath: Assets.icons.fotoMakanan.path,
            text: 'Foto Makanan',
            isSelected: _selectedType == AnalysisType.photo,
            onTap: () => setState(() => _selectedType = AnalysisType.photo),
          ),
          // AnalysisCard(
          //   assetPath: Assets.icons.videoMakanan.path,
          //   text: 'Video Makanan',
          //   isSelected: _selectedType == AnalysisType.video,
          //   onTap: () => setState(() => _selectedType = AnalysisType.video),
          // ),
          const Divider(height: 48),
          FamilyExpansionTile<ParentModel>(
            title: 'Orang Tua',
            members: family.parents,
            selectedMembers: _selectedParents,
            onChanged: (member, isSelected) {
              setState(
                () => isSelected
                    ? _selectedParents.add(member)
                    : _selectedParents.remove(member),
              );
            },
          ),
          FamilyExpansionTile<ChildModel>(
            title: 'Anak',
            members: family.children,
            selectedMembers: _selectedChildren,
            onChanged: (member, isSelected) {
              setState(
                () => isSelected
                    ? _selectedChildren.add(member)
                    : _selectedChildren.remove(member),
              );
            },
          ),
          const SizedBox(height: 48),
          TSButton(
            onPressed: _onContinue,
            text: 'Selanjutnya',
            textStyle: TSFont.getStyle(context, TSFont.bold.large),
            boxShadow: TSShadow.shadows.weight400,
            backgroundColor: TSColor.secondaryGreen.primary,
            borderColor: Colors.transparent,
            contentColor: TSColor.monochrome.black,
            width: double.infinity,
            customBorderRadius: 240,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TSPageScaffold(
      title: 'Analisis Gizi',
      body: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) {
          if (state is ScanLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScanError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat data keluarga: ${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (state is ScanLoaded) {
            return _buildContent(state.family);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
