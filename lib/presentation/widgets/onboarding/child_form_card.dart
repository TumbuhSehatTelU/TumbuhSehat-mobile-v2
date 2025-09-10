// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/child_model.dart';
import '../../screens/onboarding/add_child_screen.dart';
import '../common/ts_button.dart';
import '../common/ts_text_field.dart';

class ChildFormCard extends StatefulWidget {
  final ChildFormData formData;
  final int index;
  final VoidCallback onRemove;

  const ChildFormCard({
    super.key,
    required this.formData,
    required this.index,
    required this.onRemove,
  });

  @override
  State<ChildFormCard> createState() => _ChildFormCardState();
}

class _ChildFormCardState extends State<ChildFormCard> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.formData.dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 20),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != widget.formData.dateOfBirth) {
      setState(() {
        widget.formData.dateOfBirth = picked;
        widget.formData.dobController.text = DateFormat(
          'dd MMMM yyyy',
        ).format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: TSColor.secondaryGreen.shade100.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: widget.formData.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Anak ke-${widget.index + 1}',
                    style: getResponsiveTextStyle(
                      context,
                      TSFont.bold.body.withColor(TSColor.monochrome.black),
                    ),
                  ),
                  if (widget.index >= 0)
                    TSButton(
                      onPressed: widget.onRemove,
                      text: 'Hapus',
                      icon: Icons.delete_outline,
                      style: ButtonStyleType.leftIcon,
                      size: ButtonSize.small,
                      customBorderRadius: 240,
                      backgroundColor: TSColor.additionalColor.red,
                      borderColor: Colors.transparent,
                      contentColor: TSColor.monochrome.pureWhite,
                      textStyle: TSFont.medium.body,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Nama Lengkap Anak'),
              TSTextField(
                controller: widget.formData.nameController,
                placeholder: 'Isi Nama Lengkap Anak Anda',
                validator: (val) =>
                    (val?.isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
                isPassword: false,
                backgroundColor: TSColor.monochrome.pureWhite,
                boxShadow: TSShadow.shadows.weight200,
              ),
              const SizedBox(height: 16),
              const Text('Jenis Kelamin'),
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.male,
                    groupValue: widget.formData.gender,
                    onChanged: (Gender? value) {
                      setState(() {
                        widget.formData.gender = value;
                      });
                    },
                  ),
                  const Text('Laki-laki'),
                  Radio<Gender>(
                    value: Gender.female,
                    groupValue: widget.formData.gender,
                    onChanged: (Gender? value) {
                      setState(() {
                        widget.formData.gender = value;
                      });
                    },
                  ),
                  const Text('Perempuan'),
                ],
              ),
              if (widget.formData.gender == null)
                const Text(
                  'Pilih jenis kelamin',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Tanggal Lahir Anak'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TSTextField(
                    controller: widget.formData.dobController,
                    placeholder: 'Pilih Tanggal Lahir',
                    validator: (val) => (val?.isEmpty ?? true)
                        ? 'Tanggal lahir harus diisi'
                        : null,
                    isPassword: false,
                    backgroundColor: TSColor.monochrome.pureWhite,
                    width: double.infinity,
                    boxShadow: TSShadow.shadows.weight200,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "Tinggi Badan (cm)"),
                        TSTextField(
                          controller: widget.formData.heightController,
                          placeholder: 'Contoh: 156.0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) => (val?.isEmpty ?? true)
                              ? 'Tinggi harus diisi'
                              : null,
                          isPassword: false,
                          backgroundColor: TSColor.monochrome.pureWhite,
                          width: double.infinity,
                          boxShadow: TSShadow.shadows.weight200,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "Berat Badan (kg)"),
                        TSTextField(
                          controller: widget.formData.weightController,
                          placeholder: 'Contoh: 56.5',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) => (val?.isEmpty ?? true)
                              ? 'Berat harus diisi'
                              : null,
                          isPassword: false,
                          backgroundColor: TSColor.monochrome.pureWhite,
                          width: double.infinity,
                          boxShadow: TSShadow.shadows.weight200,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildSectionHeader(BuildContext context, String title) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: getResponsiveTextStyle(context, TSFont.bold.body)),
      const SizedBox(height: 8),
    ],
  );
}
