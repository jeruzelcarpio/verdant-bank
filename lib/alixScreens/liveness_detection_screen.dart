import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/signIn_screen.dart';

class LivenessDetectionScreen extends StatefulWidget {
  final String email;

  const LivenessDetectionScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<LivenessDetectionScreen> createState() => _LivenessDetectionScreenState();
}

class _LivenessDetectionScreenState extends State<LivenessDetectionScreen> {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  String _instruction = '';
  int _remainingTime = 10;
  int _failedAttempts = 0;
  Timer? _timer;
  bool _isProcessing = false;
  String? _resultMessage;
  final List<String> _gestures = ['Thumbs Up', 'Peace Sign', 'Okay Sign'];
  late String _currentGesture;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _selectRandomGesture();
  }

  void _selectRandomGesture() {
    _currentGesture = _gestures[_random.nextInt(_gestures.length)];
    setState(() {
      _instruction = 'Please make a $_currentGesture gesture';
    });
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _instruction = 'No camera available';
        });
        return;
      }
      
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _startCountdown() {
    _remainingTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer?.cancel();
            _captureAndVerify();
          }
        });
      }
    });
  }

  Future<void> _captureAndVerify() async {
    if (!_isCameraReady || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _resultMessage = null;
    });

    try {
      // Take picture for visual effect
      await _cameraController?.takePicture();
      await Future.delayed(const Duration(milliseconds: 800));
      
      // MOCK: Verification with 70% success rate
      bool isCorrectGesture = _random.nextInt(10) < 7;
      
      if (isCorrectGesture) {
        setState(() {
          _resultMessage = 'Verification successful!';
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context, true); // Return success
        }
      } else {
        _failedAttempts++;
        
        if (_failedAttempts >= 5) {
          setState(() {
            _resultMessage = 'Too many failed attempts';
          });
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            // Navigate back to sign-in screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
              (route) => false,
            );
          }
        } else {
          setState(() {
            _resultMessage = 'Verification failed. Please try again.';
            _selectRandomGesture(); // Choose a new gesture for next attempt
          });
          
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _resultMessage = null;
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        title: const Text('Identity Verification', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                _instruction,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_timer != null && _timer!.isActive)
                Text(
                  'Time remaining: $_remainingTime seconds',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.lighterGreen, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: _isCameraReady
                        ? CameraPreview(_cameraController!)
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.lighterGreen,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_resultMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _resultMessage!.contains('successful') 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _resultMessage!,
                    style: TextStyle(
                      color: _resultMessage!.contains('successful')
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: _isCameraReady && !_isProcessing && (_timer == null || !_timer!.isActive)
                    ? _startCountdown
                    : null,
                child: const Text(
                  'Start Verification',
                  style: TextStyle(color: AppColors.darkGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}