// ignore_for_file: deprecated_member_use, avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/child_model.dart';
import '../../../data/models/parent_model.dart';
import '../main/prediction_loading_screen.dart';

class PhotoScanScreen extends StatefulWidget {
  final Set<ParentModel> selectedParents;
  final Set<ChildModel> selectedChildren;

  const PhotoScanScreen({
    super.key,
    required this.selectedParents,
    required this.selectedChildren,
  });

  @override
  State<PhotoScanScreen> createState() => _PhotoScanScreenState();
}

class _PhotoScanScreenState extends State<PhotoScanScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  FlashMode _flashMode = FlashMode.off;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      return;
    }

    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _onCapturePressed() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile imageFile = await _controller!.takePicture();
      // Navigasi ke loading screen
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PredictionLoadingScreen(
              imageFile: imageFile,
              // Teruskan data member
              selectedParents: widget.selectedParents,
              selectedChildren: widget.selectedChildren,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _onGalleryPressed() async {
    try {
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (imageFile != null && mounted) {
        // Navigasi ke loading screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PredictionLoadingScreen(
              imageFile: imageFile,
              selectedParents: widget.selectedParents,
              selectedChildren: widget.selectedChildren,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _onFlashPressed() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.torch;
      } else {
        _flashMode = FlashMode.off;
      }
    });
    _controller!.setFlashMode(_flashMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Foto Makanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Agar body berada di belakang AppBar
      body: _isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Camera Preview
                CameraPreview(_controller!),

                // Layer 2: Overlay Frame
                _buildCameraOverlay(),

                // Layer 3: UI Kontrol
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildControlUI(),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCameraOverlay() {
    final screenSize = MediaQuery.of(context).size;
    final scanSize = screenSize.width * 0.8; // Lebar frame 80% dari lebar layar

    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5),
        BlendMode.srcOut,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              backgroundBlendMode: BlendMode.dstOut,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              height: scanSize,
              width: scanSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlUI() {
    IconData flashIcon;
    switch (_flashMode) {
      case FlashMode.auto:
        flashIcon = Icons.flash_auto;
        break;
      case FlashMode.torch:
        flashIcon = Icons.flash_on;
        break;
      default:
        flashIcon = Icons.flash_off;
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Letakkan makanan di tengah kotak',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol Galeri
              IconButton(
                onPressed: _onGalleryPressed,
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              // Tombol Capture
              GestureDetector(
                onTap: _onCapturePressed,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 4),
                  ),
                ),
              ),

              // Tombol Flash
              IconButton(
                onPressed: _onFlashPressed,
                icon: Icon(flashIcon, color: Colors.white, size: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
