// import 'package:flutter/material.dart';

// class CameraScreen extends StatelessWidget {
//   final String productType;
//   const CameraScreen({super.key, required this.productType});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Scan $productType')),
//       body: const Center(
//         child: Text('Camera coming soon...'),
//       ),
//     );
//   }
// }
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import 'ocr_confirm_screen.dart';

class CameraScreen extends StatefulWidget {
  final String productType;
  const CameraScreen({super.key, required this.productType});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  final _recognizer = TextRecognizer();
  bool _isProcessing = false;
  bool _cameraReady = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.97,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _initCamera();
  }

  Future _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  Future _capture() async {
    if (!_cameraReady || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      final file = await _controller!.takePicture();
      final input = InputImage.fromFilePath(file.path);
      final recognized = await _recognizer.processImage(input);
      if (recognized.text.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No text detected. Try holding the camera closer.'),
            ),
          );
        }
        return;
      }
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OcrConfirmScreen(
            ocrText: recognized.text,
            productType: widget.productType,
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future _pickFromGallery() async {
    setState(() => _isProcessing = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final input = InputImage.fromFilePath(image.path);
      final recognized = await _recognizer.processImage(input);
      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OcrConfirmScreen(
            ocrText: recognized.text.isEmpty
                ? 'No text found in image'
                : recognized.text,
            productType: widget.productType,
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller?.dispose();
    _recognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Scan ${widget.productType} label',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(children: [
        // Camera preview
        if (_cameraReady)
          SizedBox.expand(
            child: CameraPreview(_controller!),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: AppColors.green),
          ),

        // Pulsing scan border
        if (_cameraReady)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Center(
              child: Transform.scale(
                scale: _pulseController.value,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.green.withOpacity(0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),

        // Instructions
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Point camera at the ingredients label',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery button
              GestureDetector(
                onTap: _isProcessing ? null : _pickFromGallery,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Colors.white),
                ),
              ),
              // Capture button
              GestureDetector(
                onTap: _isProcessing ? null : _capture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
              // Spacer
              const SizedBox(width: 52),
            ],
          ),
        ),
      ]),
    );
  }
}
