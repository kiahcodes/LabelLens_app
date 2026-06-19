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
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _cameraDenied = false;
  bool _flashOn = false;
  bool _isStreamingImages = false;
  bool _shownDarkSuggestion = false;
  DateTime? _lastBrightnessCheck;
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

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _cameraDenied = true;
            _cameraReady = false;
          });
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);
      if (mounted) {
        setState(() {
          _cameraDenied = false;
          _cameraReady = true;
          _flashOn = false;
        });
      }
      await _startLightMonitor();
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

  Future<void> _retryCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isPermanentlyDenied || status.isRestricted) {
      await openAppSettings();
      return;
    }

    setState(() => _cameraDenied = false);
    await _initCamera();
  }

  Future<void> _startLightMonitor() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isStreamingImages) {
      return;
    }

    try {
      await _controller!.startImageStream(_checkBrightness);
      _isStreamingImages = true;
    } catch (_) {
      // Some camera backends do not support image streams while previewing.
    }
  }

  Future<void> _stopLightMonitor() async {
    if (_controller == null || !_isStreamingImages) return;

    try {
      await _controller!.stopImageStream();
    } catch (_) {
      // The stream may already be stopped by the platform.
    } finally {
      _isStreamingImages = false;
    }
  }

  void _checkBrightness(CameraImage image) {
    final now = DateTime.now();
    if (_lastBrightnessCheck != null &&
        now.difference(_lastBrightnessCheck!) < const Duration(seconds: 2)) {
      return;
    }
    _lastBrightnessCheck = now;

    final bytes = image.planes.first.bytes;
    if (bytes.isEmpty) return;

    var total = 0;
    var samples = 0;
    final step = (bytes.length / 1200).ceil().clamp(1, bytes.length);
    for (var i = 0; i < bytes.length; i += step) {
      total += bytes[i];
      samples++;
    }

    final averageBrightness = total / samples;
    if (averageBrightness < 55 && !_flashOn && !_shownDarkSuggestion) {
      _shownDarkSuggestion = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('It looks dark. Turn on flash for a clearer scan.'),
          action: SnackBarAction(
            label: 'Turn on',
            onPressed: _toggleFlash,
          ),
        ),
      );
    } else if (averageBrightness >= 65 && _shownDarkSuggestion) {
      _shownDarkSuggestion = false;
    }
  }

  Future<void> _toggleFlash() async {
    if (!_cameraReady || _controller == null || _isProcessing) return;

    final nextFlashOn = !_flashOn;
    try {
      await _controller!.setFlashMode(
        nextFlashOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() => _flashOn = nextFlashOn);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Flash is not available on this camera.')),
        );
      }
    }
  }

  Future _capture() async {
    if (!_cameraReady || _isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await _stopLightMonitor();
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
      if (mounted) await _startLightMonitor();
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
    _stopLightMonitor();
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
        else if (_cameraDenied)
          _CameraPermissionView(onRetry: _retryCameraPermission)
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
              // Flash button
              GestureDetector(
                onTap: _toggleFlash,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _flashOn ? AppColors.green : Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _CameraPermissionView extends StatelessWidget {
  final VoidCallback onRetry;

  const _CameraPermissionView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.white,
              size: 56,
            ),
            const SizedBox(height: 18),
            const Text(
              'Camera permission needed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow camera access to scan ingredient labels.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Allow camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
