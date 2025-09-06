import 'package:flutter/material.dart';
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

  bool _isFormComplete = false;

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
    _phoneController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
    _dobController.addListener(_validateForm);
    _weightController.addListener(_validateForm);
    _heightController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateForm);
    _nameController.removeListener(_validateForm);
    _dobController.removeListener(_validateForm);
    _weightController.removeListener(_validateForm);
    _heightController.removeListener(_validateForm);
    _passwordController.removeListener(_validateForm);
    _confirmPasswordController.removeListener(_validateForm);
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
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
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
    final phoneValid =
        !(!widget.isJoiningFamily && _phoneController.text.isEmpty);
    final nameValid = _nameController.text.isNotEmpty;
    final dobValid = _dobController.text.isNotEmpty;
    final weightValid = _weightController.text.isNotEmpty;
    final heightValid = _heightController.text.isNotEmpty;
    final roleValid = _selectedRole != null;
    final passwordValid = _passwordController.text.length >= 8;
    final confirmPwValid =
        _passwordController.text == _confirmPasswordController.text;

    if (!phoneValid ||
        !nameValid ||
        !dobValid ||
        !weightValid ||
        !heightValid ||
        !roleValid ||
        !passwordValid ||
        !confirmPwValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua data dengan benar')),
      );
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

  void _validateForm() {
    final isPhoneValid =
        widget.isJoiningFamily || _phoneController.text.isNotEmpty;
    final isNameValid = _nameController.text.isNotEmpty;
    final isDobValid = _dobController.text.isNotEmpty;
    final isWeightValid = _weightController.text.isNotEmpty;
    final isHeightValid = _heightController.text.isNotEmpty;
    final isRoleValid = _selectedRole != null;
    final isPasswordValid = _passwordController.text.length >= 8;
    final isConfirmPwValid =
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text;

    final isComplete =
        isPhoneValid &&
        isNameValid &&
        isDobValid &&
        isWeightValid &&
        isHeightValid &&
        isRoleValid &&
        isPasswordValid &&
        isConfirmPwValid;

    if (_isFormComplete != isComplete) {
      setState(() {
        _isFormComplete = isComplete;
      });
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

    final buttonColor = _isFormComplete
        ? TSColor.secondaryGreen.primary
        : TSColor.monochrome.lightGrey;
    final onButtonPress = _isFormComplete ? _submitForm : null;
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
        } else if (state is OnboardingSuccess &&
            _selectedRole != ParentRole.ibu) {
          Navigator.of(context).pop();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: TSPageScaffold(
        appBar: AppBar(title: const Text('Registrasi Data Diri')),
        body: Form(
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
                              placeholder: 'Contoh: 56',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              controller: _weightController,
                              isPassword: false,
                              backgroundColor: TSColor.monochrome.pureWhite,
                              boxShadow: TSShadow.shadows.weight500,
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
                      _validateForm();
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
                    backgroundColor: buttonColor,
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
