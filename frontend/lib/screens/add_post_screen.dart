import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/screens/image_preview_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  bool _isPickingImage = false;

  final ImagePicker _picker = getIt<ImagePicker>();
  final CommunityPostApiService _api = CommunityPostApiService();

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null && mounted) {
        final String? finalImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imagePath: image.path),
          ),
        );

        if (finalImagePath != null && mounted) {
          setState(() {
            _selectedImage = File(finalImagePath);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.failedToPickImage}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  void _handleUpload() async {
    if (_descController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.addPhotoOrDescFirst)),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final newPost = await _api.createPost(
        content: _descController.text.trim(),
        imageFile: _selectedImage,
      );
      if (mounted) {
        Navigator.pop(context, newPost);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.uploadFailed}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.addNewPost,
          style: GoogleFonts.montserrat(
            color: AppColors.navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Area
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.peach,
                    borderRadius: BorderRadius.circular(20),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt,
                              color: AppColors.navy,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.addPhotoOrImage,
                              style: TextStyle(
                                color: AppColors.navy.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              
              // Description Label
              Text(
                AppStrings.description,
                style: TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              
              // Description Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.peach,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _descController,
                  maxLines: 5,
                  minLines: 3,
                  style: const TextStyle(color: AppColors.navy),
                  decoration: InputDecoration(
                    hintText: AppStrings.writeDescription,
                    hintStyle: TextStyle(
                      color: AppColors.navy.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Upload Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _handleUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.navy.withOpacity(0.3),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppStrings.upload,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
