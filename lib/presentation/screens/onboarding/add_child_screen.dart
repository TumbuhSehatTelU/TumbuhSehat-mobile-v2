// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/child_model.dart';
import '../../cubit/onboarding/onboarding_cubit.dart';
import '../../widgets/child_form_card.dart';
import '../../widgets/ts_button.dart';
import '../../widgets/ts_page_scaffold.dart';
import 'login_screen.dart';

class ChildFormData {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  Gender? gender;
  DateTime? dateOfBirth;

  void dispose() {
    nameController.dispose();
    dobController.dispose();
    heightController.dispose();
    weightController.dispose();
  }
}

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final List<ChildFormData> _childForms = [];

  @override
  void initState() {
    super.initState();
    _addNewChildForm();
  }

  @override
  void dispose() {
    for (var form in _childForms) {
      form.dispose();
    }
    super.dispose();
  }

  void _addNewChildForm() {
    setState(() {
      _childForms.add(ChildFormData());
    });
  }

  void _removeChildForm(int index) {
    setState(() {
      _childForms[index].dispose();
      _childForms.removeAt(index);
    });
  }

  void _submitForms(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    final currentState = cubit.state;

    if (currentState is! OnboardingSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error: Sesi tidak valid.')));
      return;
    }

    final uniqueCode = currentState.family.uniqueCode;

    _submitNextChild(context, 0, uniqueCode);
  }

  void _submitNextChild(BuildContext context, int index, String uniqueCode) {
    if (index >= _childForms.length) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    final form = _childForms[index];
    if (form.formKey.currentState?.validate() ?? false) {
      context.read<OnboardingCubit>().submitChildData(
        uniqueCode: uniqueCode,
        name: form.nameController.text,
        gender: form.gender!,
        dateOfBirth: form.dateOfBirth!,
        height: double.parse(form.heightController.text),
        weight: double.parse(form.weightController.text),
      );

      context
          .read<OnboardingCubit>()
          .stream
          .firstWhere((state) => state is OnboardingSuccess)
          .then((_) {
            _submitNextChild(context, index + 1, uniqueCode);
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data anak ke-${index + 1} tidak valid.')),
      );
    }
  }

  void _skipAndContinue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        } else if (state is OnboardingFailure) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OnboardingSuccess) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }
      },
      child: TSPageScaffold(
        appBar: AppBar(title: const Text('Tambah Data Anak')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buildChildForms(),
              const SizedBox(height: 16),
              TSButton(
                onPressed: _addNewChildForm,
                text: 'Tambah Data Anak Lain',
                textStyle: getResponsiveTextStyle(context, TSFont.bold.h3),
                backgroundColor: TSColor.monochrome.white,
                borderColor: TSColor.mainTosca.shade400,
                contentColor: TSColor.mainTosca.shade400,
                borderWidth: 4,
                customBorderRadius: 240,
              ),
              const SizedBox(height: 32),
              TSButton(
                onPressed: () => _submitForms(context),
                text: 'Selesai & Simpan Data Anak',
                textStyle: getResponsiveTextStyle(context, TSFont.bold.h3),
                backgroundColor: TSColor.mainTosca.shade400,
                borderColor: Colors.transparent,
                contentColor: TSColor.monochrome.white,
                customBorderRadius: 240,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _skipAndContinue,
                child: Text(
                  'Lewati untuk sekarang',
                  style: getResponsiveTextStyle(
                    context,
                    TSFont.medium.large.withColor(TSColor.additionalColor.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildChildForms() {
    return List.generate(_childForms.length, (index) {
      return ChildFormCard(
        key: ValueKey(index),
        formData: _childForms[index],
        index: index,
        onRemove: () => _removeChildForm(index),
      );
    });
  }
}
