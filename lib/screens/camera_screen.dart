import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

// Import the global cameras variable
import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  MobileScannerController? _qrController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isQRMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _qrController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      return;
    }

    if (cameras.isEmpty) {
      print('No cameras available');
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: true,
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

  void _toggleCameraMode() {
    setState(() {
      _isQRMode = !_isQRMode;
      if (_isQRMode) {
        _controller?.dispose();
        _controller = null;
        _qrController = MobileScannerController();
      } else {
        _qrController?.dispose();
        _qrController = null;
        _initializeCamera();
      }
    });
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      if (!mounted) return;

      // Show preview dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Image.file(File(photo.path)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (!_controller!.value.isInitialized) return;

    try {
      if (_isRecording) {
        final XFile video = await _controller!.stopVideoRecording();
        setState(() => _isRecording = false);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved to: ${video.path}')),
        );
      } else {
        await _controller!.startVideoRecording();
        setState(() => _isRecording = true);
      }
    } catch (e) {
      print('Error recording video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized && !_isQRMode) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isQRMode ? 'QR Scanner' : 'Camera'),
        actions: [
          IconButton(
            icon: Icon(_isQRMode ? Icons.camera_alt : Icons.qr_code),
            onPressed: _toggleCameraMode,
          ),
        ],
      ),
      body: _isQRMode
          ? MobileScanner(
              controller: _qrController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('QR Code: ${barcode.rawValue}')),
                    );
                  }
                }
              },
            )
          : Stack(
              children: [
                CameraPreview(_controller!),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'photo',
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera),
                      ),
                      FloatingActionButton(
                        heroTag: 'video',
                        onPressed: _toggleRecording,
                        backgroundColor: _isRecording ? Colors.red : null,
                        child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 