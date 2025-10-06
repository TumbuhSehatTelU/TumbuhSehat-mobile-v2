import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/common/ts_dropdown.dart';
import '../../widgets/common/ts_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final ParentModel currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;

  DateTime? _selectedDateOfBirth;
  ParentRole? _selectedRole;
  Gender? _selectedGender;

  // Data kondisi ibu (tidak bisa diubah di sini, hanya dibawa)
  late final bool _isPregnant;
  late final GestationalAge _gestationalAge;
  late final bool _isLactating;
  late final LactationPeriod _lactationPeriod;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data awal dari currentUser
    _nameController = TextEditingController(text: widget.currentUser.name);
    _dobController = TextEditingController(
      text: DateFormat('dd MMMM yyyy').format(widget.currentUser.dateOfBirth),
    );
    _weightController = TextEditingController(
      text: widget.currentUser.weight.toString(),
    );
    _heightController = TextEditingController(
      text: widget.currentUser.height.toString(),
    );

    _selectedDateOfBirth = widget.currentUser.dateOfBirth;
    _selectedRole = widget.currentUser.role;
    _selectedGender = widget.currentUser.gender;

    _isPregnant = widget.currentUser.isPregnant;
    _gestationalAge = widget.currentUser.gestationalAge;
    _isLactating = widget.currentUser.isLactating;
    _lactationPeriod = widget.currentUser.lactationPeriod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _heightController.dispose();
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

  void _submitUpdate() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDateOfBirth == null ||
        _selectedRole == null ||
        _selectedGender == null) {
      return;
    }

    final updatedUser = ParentModel(
      name: _nameController.text.trim(),
      password: widget.currentUser.password,
      role: _selectedRole!,
      gender: _selectedGender!,
      dateOfBirth: _selectedDateOfBirth!,
      height:
          double.tryParse(_heightController.text.trim()) ??
          widget.currentUser.height,
      weight:
          double.tryParse(_weightController.text.trim()) ??
          widget.currentUser.weight,
      isPregnant: _isPregnant,
      gestationalAge: _gestationalAge,
      isLactating: _isLactating,
      lactationPeriod: _lactationPeriod,
    );

    context.read<ProfileCubit>().updateUserProfile(updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Nama Lengkap'),
                const SizedBox(height: 8),
                TSTextField(
                  controller: _nameController,
                  isPassword: false,
                  backgroundColor: Colors.white,
                  boxShadow: TSShadow.shadows.weight300,
                  validator: (val) =>
                      (val?.isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),

                const Text('Jenis Kelamin'),
                Row(
                  children: [
                    Radio<Gender>(
                      value: Gender.male,
                      groupValue: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                    const Text('Laki-laki'),
                    Radio<Gender>(
                      value: Gender.female,
                      groupValue: _selectedGender,
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),
                    const Text('Perempuan'),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Tanggal Lahir'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TSTextField(
                      controller: _dobController,
                      isPassword: false,
                      backgroundColor: Colors.white,
                      boxShadow: TSShadow.shadows.weight300,
                      validator: (val) => (val?.isEmpty ?? true)
                          ? 'Tanggal lahir harus diisi'
                          : null,
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
                          const Text('Berat (kg)'),
                          const SizedBox(height: 8),
                          TSTextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            isPassword: false,
                            backgroundColor: Colors.white,
                            boxShadow: TSShadow.shadows.weight300,
                            validator: (val) => (val?.isEmpty ?? true)
                                ? 'Berat harus diisi'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tinggi (cm)'),
                          const SizedBox(height: 8),
                          TSTextField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            isPassword: false,
                            backgroundColor: Colors.white,
                            boxShadow: TSShadow.shadows.weight300,
                            validator: (val) => (val?.isEmpty ?? true)
                                ? 'Tinggi harus diisi'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TSDropdown<ParentRole>(
                  label: 'Hubungan dengan Anak',
                  value: _selectedRole,
                  items: ParentRole.values,
                  onChanged: (val) => setState(() => _selectedRole = val),
                  itemBuilder: (role) => Text(role.name),
                  validator: (val) => val == null ? 'Pilih hubungan' : null,
                ),
                const SizedBox(height: 32),

                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileLoading;
                    return TSButton(
                      onPressed: isLoading ? null : _submitUpdate,
                      text: isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                      backgroundColor: isLoading
                          ? Colors.grey
                          : TSColor.mainTosca.primary,
                      borderColor: Colors.transparent,
                      contentColor: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
