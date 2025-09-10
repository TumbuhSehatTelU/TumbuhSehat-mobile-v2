import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_tumbuh_sehat_v2/core/theme/ts_shadow.dart';
import 'package:mobile_tumbuh_sehat_v2/presentation/screens/onboarding/welcome_screen.dart';

import '../../../core/network/network_info.dart';
import '../../../core/theme/ts_color.dart';
import '../../../core/theme/ts_text_style.dart';
import '../../../injection_container.dart';
import '../../cubit/login/login_cubit.dart';
import '../../widgets/onboarding/ts_auth_header.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../../widgets/common/ts_text_field.dart';
import 'join_or_create_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _uniqueCodeController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  bool _isOnlineMode = false;
  bool _isLoadingConnection = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _uniqueCodeController = TextEditingController();
    _phoneController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    _uniqueCodeController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectionStatus() async {
    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;
    if (mounted) {
      setState(() {
        _isOnlineMode = isConnected;
        _isLoadingConnection = false;
      });
    }
  }

  void _submitLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<LoginCubit>().login(
      name: _nameController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
      uniqueCode: _isOnlineMode ? _uniqueCodeController.text.trim() : null,
      phoneNumber: !_isOnlineMode ? _phoneController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
          );
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: TSPageScaffold(
        body: _isLoadingConnection
            ? const Center(child: CircularProgressIndicator())
            : _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(),
            SizedBox(height: 36),
            if (_isOnlineMode) ...[
              _buildSectionHeader(context, 'Kode Unik Keluarga'),
              TSTextField(
                controller: _uniqueCodeController,
                placeholder: 'Masukkan Kode Unik Keluarga Anda',
                validator: (val) =>
                    (val?.isEmpty ?? true) ? 'Kode unik harus diisi' : null,
                isPassword: false,
                backgroundColor: TSColor.monochrome.pureWhite,
                width: double.infinity,
                boxShadow: TSShadow.shadows.weight500,
              ),
            ] else ...[
              _buildSectionHeader(context, 'Nomor Handphone'),
              TSTextField(
                controller: _phoneController,
                placeholder: 'Masukkan Nomor Handphone Keluarga Anda',
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    (val?.isEmpty ?? true) ? 'Nomor HP harus diisi' : null,
                isPassword: false,
                backgroundColor: TSColor.monochrome.pureWhite,
                width: double.infinity,
                boxShadow: TSShadow.shadows.weight500,
              ),
            ],
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'Nama Lengkap'),
            TSTextField(
              controller: _nameController,
              placeholder: 'Nama Lengkap',
              validator: (val) =>
                  (val?.isEmpty ?? true) ? 'Nama harus diisi' : null,
              isPassword: false,
              backgroundColor: TSColor.monochrome.pureWhite,
              width: double.infinity,
              boxShadow: TSShadow.shadows.weight500,
            ),
            const SizedBox(height: 16),
            _buildSectionHeader(context, 'Password'),
            TSTextField(
              controller: _passwordController,
              placeholder: 'Password',
              isPassword: true,
              textInputAction: TextInputAction.done,
              validator: (val) =>
                  (val?.isEmpty ?? true) ? 'Password harus diisi' : null,
              backgroundColor: TSColor.monochrome.pureWhite,
              width: double.infinity,
              boxShadow: TSShadow.shadows.weight500,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (val) =>
                          setState(() => _rememberMe = val ?? false),
                    ),
                    const Text('Ingat Saya'),
                  ],
                ),
                if (_isOnlineMode)
                  TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password flow
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            BlocBuilder<LoginCubit, LoginState>(
              builder: (context, state) {
                final isLoading = state is LoginLoading;
                return TSButton(
                  onPressed: isLoading ? null : _submitLogin,
                  text: isLoading ? 'Memproses...' : 'Masuk',
                  textStyle: getResponsiveTextStyle(context, TSFont.bold.large),
                  customBorderRadius: 240,
                  boxShadow: TSShadow.shadows.weight500,
                  size: ButtonSize.medium,
                  backgroundColor: isLoading
                      ? TSColor.monochrome.lightGrey
                      : TSColor.secondaryGreen.primary,
                  borderColor: Colors.transparent,
                  contentColor: TSColor.monochrome.black,
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum punya akun?'),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const JoinOrCreateScreen(),
                      ),
                    );
                  },
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ],
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
