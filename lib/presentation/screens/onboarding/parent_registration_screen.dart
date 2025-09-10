import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../data/models/parent_model.dart';
import '../../cubit/onboarding/onboarding_cubit.dart';
import '../../widgets/ts_button.dart';
import '../../widgets/ts_dropdown.dart';
import '../../widgets/ts_page_scaffold.dart';
import '../../widgets/ts_text_field.dart';
import 'add_child_screen.dart';
import 'login_screen.dart';
import 'pregnancy_check_screen.dart';

extension ParentRoleExtension on ParentRole {
  String get displayName {
    switch (this) {
      case ParentRole.ayah:
        return 'Ayah';
      case ParentRole.ibu:
        return 'Ibu';
      case ParentRole.wali:
        return 'Wali';
      case ParentRole.pengasuh:
        return 'Pengasuh';
      case ParentRole.lainnya:
        return 'Lainnya';
    }
  }
}

class ParentRegistrationScreen extends StatefulWidget {
  final bool isJoiningFamily;

  const ParentRegistrationScreen({super.key, required this.isJoiningFamily});

  @override
  State<ParentRegistrationScreen> createState() =>
      _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState extends State<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  DateTime? _selectedDateOfBirth;
  ParentRole? _selectedRole;
  bool _hasAttemptedSubmit = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _dobController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(DateTime.now().year - 25),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('dd MMMM yyyy').format(picked);
      });
    }
  }

  void _submitForm() {
    setState(() {
      _hasAttemptedSubmit = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final onboardingCubit = context.read<OnboardingCubit>();

    onboardingCubit.submitParentData(
      phoneNumber: !widget.isJoiningFamily
          ? _phoneController.text.trim()
          : null,
      name: _nameController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
      dateOfBirth: _selectedDateOfBirth!,
      height: double.tryParse(_heightController.text.trim()) ?? 0.0,
      weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
    );

    if (_selectedRole == ParentRole.ibu) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PregnancyCheckScreen()),
      );
    } else {
      onboardingCubit.submitLactationStatus(isLactating: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String getButtonText() {
      if (widget.isJoiningFamily && _selectedRole != ParentRole.ibu) {
        return 'Daftar';
      }
      return 'Lanjutkan';
    }

    final onButtonPress = _submitForm;
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
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is OnboardingSuccess) {
          Navigator.of(context).pop();
          if (!widget.isJoiningFamily) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddChildScreen()),
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        }
      },
      child: TSPageScaffold(
        title: 'Registrasi Data Diri',
        body: Form(
          autovalidateMode: _hasAttemptedSubmit
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.isJoiningFamily) ...[
                    _buildSectionHeader(context, "No Handphone"),
                    TSTextField(
                      placeholder: 'Contoh: 089512341234',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      isPassword: false,
                      backgroundColor: TSColor.monochrome.pureWhite,
                      boxShadow: TSShadow.shadows.weight500,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: TSValidator(
                        [
                          (val) => val.isNotEmpty,
                          (val) => int.tryParse(val) != null,
                        ],
                        [
                          'Nomor HP tidak boleh kosong',
                          'Nomor HP harus berupa angka',
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildSectionHeader(context, "Nama Lengkap"),
                  TSTextField(
                    placeholder: 'Contoh: Syahreza Adnan Al Azhar',
                    controller: _nameController,
                    isPassword: false,
                    backgroundColor: TSColor.monochrome.pureWhite,
                    boxShadow: TSShadow.shadows.weight500,
                    validator: TSValidator(
                      [(val) => val.isNotEmpty],
                      ['Nama tidak boleh kosong'],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, "Tanggal Lahir"),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TSTextField(
                        placeholder: 'Pilih Tanggal Lahir',
                        controller: _dobController,
                        isPassword: false,
                        backgroundColor: TSColor.monochrome.pureWhite,
                        boxShadow: TSShadow.shadows.weight500,
                        validator: TSValidator(
                          [(val) => val.isNotEmpty],
                          ['Tanggal lahir harus diisi'],
                        ),
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
                            _buildSectionHeader(context, "Berat Badan (kg)"),
                            TSTextField(
                              placeholder: 'Contoh: 56.5',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              controller: _weightController,
                              isPassword: false,
                              backgroundColor: TSColor.monochrome.pureWhite,
                              boxShadow: TSShadow.shadows.weight500,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: TSValidator(
                                [
                                  (val) => val.isNotEmpty,
                                  (val) => double.tryParse(val) != null,
                                ],
                                [
                                  'Berat badan harus diisi',
                                  'Berat badan harus angka',
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(context, "Tinggi Badan (cm)"),
                            TSTextField(
                              placeholder: 'Contoh: 156',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              controller: _heightController,
                              isPassword: false,
                              backgroundColor: TSColor.monochrome.pureWhite,
                              boxShadow: TSShadow.shadows.weight500,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: TSValidator(
                                [
                                  (val) => val.isNotEmpty,
                                  (val) => double.tryParse(val) != null,
                                ],
                                [
                                  'Tinggi badan harus diisi',
                                  'Tinggi badan harus angka',
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, "Hubungan dengan anak"),
                  TSDropdown<ParentRole>(
                    label: 'Hubungan dengan Anak',
                    value: _selectedRole,
                    items: ParentRole.values,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    },
                    itemBuilder: (role) => Text(role.displayName),
                    validator: (value) =>
                        value == null ? 'Pilih hubungan' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionHeader(context, "Password"),
                  TSTextField(
                    placeholder: 'Contoh: abcdefgh12',
                    controller: _passwordController,
                    isPassword: true,
                    backgroundColor: TSColor.monochrome.pureWhite,
                    boxShadow: TSShadow.shadows.weight500,
                    validator: TSValidator(
                      [(val) => val.isNotEmpty, (val) => val.length >= 8],
                      [
                        'Password tidak boleh kosong',
                        'Password minimal 8 karakter',
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader(context, "Konfirmasi Password"),
                  TSTextField(
                    placeholder: 'Contoh: abcdefgh12',
                    textInputAction: TextInputAction.done,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    backgroundColor: TSColor.monochrome.pureWhite,
                    boxShadow: TSShadow.shadows.weight500,
                    validator: TSValidator(
                      [
                        (val) => val.isNotEmpty,
                        (val) => val == _passwordController.text,
                      ],
                      [
                        'Konfirmasi password tidak boleh kosong',
                        'Password tidak cocok',
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  TSButton(
                    onPressed: onButtonPress,
                    text: getButtonText(),
                    textStyle: getResponsiveTextStyle(
                      context,
                      TSFont.bold.large,
                    ),
                    customBorderRadius: 240,
                    boxShadow: TSShadow.shadows.weight500,
                    size: ButtonSize.medium,
                    backgroundColor: TSColor.secondaryGreen.primary,
                    borderColor: Colors.transparent,
                    contentColor: TSColor.monochrome.black,
                  ),
                  const SizedBox(height: 24),

                  _buildLoginRedirect(context),
                ],
              ),
            ),
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

Widget _buildLoginRedirect(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    },
    child: RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TSFont.regular.large.withColor(TSColor.monochrome.grey),
        children: <TextSpan>[
          const TextSpan(text: 'Sudah punya akun? '),
          TextSpan(
            text: 'Masuk',
            style: TSFont.semiBold.large.withColor(
              TSColor.additionalColor.blue,
            ),
          ),
        ],
      ),
    ),
  );
}
