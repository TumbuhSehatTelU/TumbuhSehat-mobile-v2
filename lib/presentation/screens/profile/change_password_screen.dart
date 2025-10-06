import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_shadow.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/common/ts_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitChangePassword() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileCubit>().changePassword(
      _oldPasswordController.text,
      _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Password Lama'),
                const SizedBox(height: 8),
                TSTextField(
                  controller: _oldPasswordController,
                  isPassword: true,
                  backgroundColor: Colors.white,
                  boxShadow: TSShadow.shadows.weight300,
                  validator: (val) => (val?.isEmpty ?? true)
                      ? 'Password lama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),

                const Text('Password Baru'),
                const SizedBox(height: 8),
                TSTextField(
                  controller: _newPasswordController,
                  isPassword: true,
                  backgroundColor: Colors.white,
                  boxShadow: TSShadow.shadows.weight300,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password baru tidak boleh kosong';
                    }
                    if (val.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const Text('Konfirmasi Password Baru'),
                const SizedBox(height: 8),
                TSTextField(
                  controller: _confirmPasswordController,
                  isPassword: true,
                  backgroundColor: Colors.white,
                  boxShadow: TSShadow.shadows.weight300,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (val != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    final isLoading = state is ProfileLoading;
                    return TSButton(
                      onPressed: isLoading ? null : _submitChangePassword,
                      text: isLoading ? 'Menyimpan...' : 'Simpan Password',
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
