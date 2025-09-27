import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/ts_color.dart';
import '../../../injection_container.dart';
import '../../cubit/beranda/beranda_cubit.dart';
import '../../cubit/profile/profile_cubit.dart';
import '../../widgets/common/ts_button.dart';
import '../../widgets/dialogs_and_modals/ts_success_modal.dart';
import '../../widgets/layouts/ts_page_scaffold.dart';
import '../splash_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(),
      child: TSPageScaffold(
        title: "Riwayat Kalori",
        body: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            // Tutup dialog loading jika ada
            if (state is! ProfileLoading &&
                Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            if (state is ProfileLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            decoration: TextDecoration.none,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is ProfileSuccess) {
              // Jika sukses menghapus semua data
              if (state.message.contains('Semua data')) {
                showTSSuccessModal(
                  context: context,
                  message: state.message,
                  autoClose: true,
                  duration: const Duration(seconds: 2),
                  onClosed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                      (route) => false,
                    );
                  },
                );
              }
              // Jika sukses menghapus riwayat atau reseed
              else {
                showTSSuccessModal(
                  context: context,
                  message: state.message,
                  autoClose: true,
                  duration: const Duration(seconds: 2),
                  onClosed: () {
                    // Muat ulang data Beranda
                    context.read<BerandaCubit>().refreshBeranda();
                  },
                );
              }
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TSButton(
                  onPressed: () => context.read<ProfileCubit>().deleteAllData(),
                  text: 'Hapus Seluruh Data Lokal',
                  backgroundColor: TSColor.additionalColor.red,
                  borderColor: Colors.transparent,
                  contentColor: Colors.white,
                ),
                const SizedBox(height: 16),
                TSButton(
                  onPressed: () =>
                      context.read<ProfileCubit>().deleteHistoryData(),
                  text: 'Hapus Riwayat & Cache',
                  backgroundColor: TSColor.additionalColor.orange,
                  borderColor: Colors.transparent,
                  contentColor: Colors.white,
                ),
                const SizedBox(height: 16),
                TSButton(
                  onPressed: () =>
                      context.read<ProfileCubit>().reseedDatabase(),
                  text: 'Muat Ulang Data Makanan',
                  backgroundColor: TSColor.additionalColor.blue,
                  borderColor: Colors.transparent,
                  contentColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
