import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/profile/profile_menu_item.dart';
import '../onboarding/login_screen.dart';
import '../../../gen/assets.gen.dart';


class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfileData();
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProfileCubit>().logout();
            },
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Profil Saya')),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLogoutSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading && state.message == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            return _buildProfileContent(state);
          }
          // Default fallback (jika state lain)
          return const Center(child: Text('Memuat data profil...'));
        },
      ),
    );
  }

  Widget _buildProfileContent(ProfileLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          CircleAvatar(
            radius: 50,
            child: Text(
              state.currentUser.name[0],
              style: const TextStyle(fontSize: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.currentUser.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TSButton(
            onPressed: () {
              // TODO: Navigasi ke EditProfileScreen
            },
            text: 'Edit Profil',
            backgroundColor: TSColor.secondaryGreen.primary,
            borderColor: Colors.transparent,
            contentColor: Colors.black,
          ),
          const SizedBox(height: 32),

          // Menu Items
          ProfileMenuItem(
            svgIconPath: Assets.icons.profilGantiPassword.path,
            title: 'Ganti Password',
            onTap: () {
              // TODO: Navigasi ke ChangePasswordScreen
            },
          ),
          const SizedBox(height: 16),
          ProfileMenuItem(
            svgIconPath: Assets.icons.profilDataKeluarga.path,
            title: 'Data Keluarga',
            onTap: () {
              // TODO: Navigasi ke FamilyDataScreen
            },
          ),
          const SizedBox(height: 16),
          ProfileMenuItem(
            svgIconPath: Assets.icons.profilKeluar.path,
            title: 'Keluar',
            color: Colors.red,
            onTap: _showLogoutConfirmationDialog,
          ),
        ],
      ),
    );
  }
}
