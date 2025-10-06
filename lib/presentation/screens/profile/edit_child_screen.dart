import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../../data/models/child_model.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/common/ts_text_field.dart';

class EditChildScreen extends StatefulWidget {
  final ChildModel child;
  const EditChildScreen({super.key, required this.child});

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  Gender? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _dobController = TextEditingController(
      text: DateFormat(
        'dd MMMM yyyy',
        'id_ID',
      ).format(widget.child.dateOfBirth),
    );
    _heightController = TextEditingController(
      text: widget.child.height.toString(),
    );
    _weightController = TextEditingController(
      text: widget.child.weight.toString(),
    );
    _selectedGender = widget.child.gender;
    _selectedDateOfBirth = widget.child.dateOfBirth;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 20),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  void _submitUpdate() {
    if (!_formKey.currentState!.validate() ||
        _selectedGender == null ||
        _selectedDateOfBirth == null) {
      return;
    }

    final updatedChild = ChildModel(
      name: _nameController.text.trim(),
      gender: _selectedGender!,
      dateOfBirth: _selectedDateOfBirth!,
      height:
          double.tryParse(_heightController.text.trim()) ?? widget.child.height,
      weight:
          double.tryParse(_weightController.text.trim()) ?? widget.child.weight,
    );

    context.read<ProfileCubit>().updateChildProfile(updatedChild);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Data ${widget.child.name}')),
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
                const Text('Nama Lengkap Anak'),
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

                const Text('Tanggal Lahir Anak'),
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
                    const SizedBox(width: 16),
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
                  ],
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
