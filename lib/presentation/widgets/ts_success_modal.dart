// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/ts_color.dart';
import '../../core/theme/ts_text_style.dart';
import '../../gen/assets.gen.dart';

/// Menampilkan modal sukses yang dapat dikustomisasi.
///
/// [context] adalah BuildContext dari pemanggil.
/// [message] adalah pesan yang akan ditampilkan di bawah animasi.
/// [autoClose] jika true, modal akan tertutup otomatis setelah [duration].
/// [duration] durasi untuk auto-close dan progress bar.
/// [onClosed] callback yang akan dieksekusi setelah modal tertutup. Berguna untuk navigasi.
/// [primaryAction] & [secondaryAction] adalah widget (e.g., TSButton) yang akan ditampilkan.
///
/// --- CONTOH PENGGUNAAN ---
///
/// 1. Auto-close dan navigasi:
/// showTSSuccessModal(
///   context: context,
///   message: 'Data berhasil disimpan!',
///   autoClose: true,
///   onClosed: () {
///     Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
///   },
/// );
///
/// 2. Dengan tombol konfirmasi:
/// showTSSuccessModal(
///   context: context,
///   message: 'Apakah Anda yakin ingin keluar?',
///   primaryAction: TSButton(
///     text: 'Ya, Keluar',
///     onPressed: () {
///       Navigator.of(context).pop(); // Tutup modal dulu
///       // ... Lakukan aksi keluar ...
///     },
///     // ... styling
///   ),
/// );

Future<void> showTSSuccessModal({
  required BuildContext context,
  required String message,
  bool autoClose = false,
  Duration duration = const Duration(seconds: 3),
  VoidCallback? onClosed,
  Widget? primaryAction,
  Widget? secondaryAction,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: !autoClose,
    builder: (BuildContext dialogContext) {
      return _TSSuccessModalContent(
        message: message,
        autoClose: autoClose,
        duration: duration,
        onClosed: onClosed,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
      );
    },
  );
}

class _TSSuccessModalContent extends StatefulWidget {
  final String message;
  final bool autoClose;
  final Duration duration;
  final VoidCallback? onClosed;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  const _TSSuccessModalContent({
    required this.message,
    required this.autoClose,
    required this.duration,
    this.onClosed,
    this.primaryAction,
    this.secondaryAction,
  });

  @override
  _TSSuccessModalContentState createState() => _TSSuccessModalContentState();
}

class _TSSuccessModalContentState extends State<_TSSuccessModalContent>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.autoClose) {
      _animationController.forward();
      _timer = Timer(widget.duration, () {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onClosed?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              Assets.lottie.success.path,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: TSFont.semiBold.large.withColor(TSColor.monochrome.black),
            ),
            if (widget.primaryAction != null || widget.secondaryAction != null)
              const SizedBox(height: 32),

            if (widget.primaryAction != null) widget.primaryAction!,

            if (widget.primaryAction != null && widget.secondaryAction != null)
              const SizedBox(height: 12),

            if (widget.secondaryAction != null) widget.secondaryAction!,

            if (widget.autoClose) ...[
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: TSColor.monochrome.lightGrey.withOpacity(
                      0.5,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TSColor.mainTosca.primary,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
