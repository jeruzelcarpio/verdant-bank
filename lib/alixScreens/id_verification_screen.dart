import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart'; // Add this import
import 'package:verdantbank/alixScreens/identification_details_screen.dart';

class IdVerificationScreen extends StatefulWidget {
  final String email;

  const IdVerificationScreen({
    super.key, 
    required this.email,
  });

  @override
  State<IdVerificationScreen> createState() => _IdVerificationScreenState();
}

class _IdVerificationScreenState extends State<IdVerificationScreen> {
  String? selectedIdType;
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool isCaptureDone = false;

  // Add this list of Philippine IDs
  final List<String> philippineIds = [
    'Philippine Passport',
    'SSS ID / UMID',
    'Driver\'s License',
    'PhilHealth ID',
    'TIN ID',
    'Postal ID',
    'Voter\'s ID',
    'PRC ID',
    'GSIS e-Card',
    'National ID (PhilSys)',
  ];

  // Update the capture method
  Future<void> _captureId() async {
    try {
      // For emulator testing, directly show source selection without permission check
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery, // Directly use gallery for emulator
        imageQuality: 100,
      );

      if (photo != null) {
        final File imageFile = File(photo.path);
        // Verify if file exists and is readable
        if (await imageFile.exists()) {
          setState(() {
            _capturedImage = imageFile;
            isCaptureDone = true;
          });
        } else {
          throw Exception('Selected image file not accessible');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkGreen,
            title: const Text(
              'Image Selection Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Please select an image from your gallery.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: AppColors.lighterGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  // Update the camera container section with this code
  Widget _buildCameraSection() {
    if (isCaptureDone) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkGreen.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.darkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.lighterGreen,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ID Capture\nComplete!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lighterGreen,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            color: AppColors.lighterGreen,
            size: 48,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lighterGreen,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            onPressed: _captureId,
            child: const Text(
              'Capture ID',
              style: TextStyle(color: AppColors.darkGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar - Reusing existing code with updated states
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Getting\nStarted',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: AppColors.lighterGreen,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.lighterGreen,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Verify\nIdentity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.lighterGreen,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: AppColors.lighterGreen,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.lighterGreen,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Create\nAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: Colors.white24,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Government-issued ID Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your ID type:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                    side: BorderSide(
                      color: AppColors.lighterGreen.withOpacity(0.3),
                    ),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.darkGreen,
                    isScrollControlled: true, // Add this
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7, // Add max height
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Select ID Type',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: philippineIds.map((String value) {
                                    return ListTile(
                                      title: Text(
                                        value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      trailing: selectedIdType == value
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: AppColors.lighterGreen,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          selectedIdType = value;
                                        });
                                        Navigator.pop(context);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedIdType ?? 'Select ID',
                        style: TextStyle(
                          color: selectedIdType != null
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.lighterGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildCameraSection(),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.lighterGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: AppColors.lighterGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedIdType != null 
                            ? AppColors.lighterGreen 
                            : AppColors.lightGreen,
                        disabledBackgroundColor: AppColors.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: selectedIdType != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IdentificationDetailsScreen(
                                    email: widget.email,
                                    idType: selectedIdType!,
                                    idImagePath: _capturedImage?.path,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}