import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _descController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _handleUpload() async {
    if (_descController.text.trim().isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.addPhotoOrDescFirst)),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Get actual user profile data from API
    final profileApiService = ProfileApiService();
    final userProfile = await profileApiService.getProfile(forceRefresh: true);
    final profileImagePath = getIt<SharedPreferences>().getString('profile_image');

    if (userProfile == null) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil data profil')),
        );
      }
      return;
    }

    // Simulate upload delay
    Future.delayed(const Duration(milliseconds: 800), () {
      final newPost = CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: userProfile.name,
        authorAvatarUrl: profileImagePath ?? '',
        timeAgo: AppStrings.justNow,
        content: _descController.text.trim(),
        localImageFile: _selectedImage,
        likes: 0,
        comments: 0,
        isLiked: false,
        isFollowed: true,
        tabCategory: 'Untuk Anda', // Show in both realistically, but default For You
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        Navigator.pop(context, newPost);
      }
    });
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
