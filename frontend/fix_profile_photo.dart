import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var content = file.readAsStringSync();
  
  // 1. Add _isLocalAvatarNew to the top variables
  content = content.replaceFirst(
    "bool _isPhotoChanged = false;",
    "bool _isPhotoChanged = false;\n  bool _isLocalAvatarNew = false;"
  );
  
  // 2. Change _buildProfileImageProvider
  final oldProvider = """  ImageProvider? _buildProfileImageProvider() {
    if (_profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty) {
      return NetworkImage(_profile!.photoUrl!);
    }
    if (_profileImagePath != null) {
      if (kIsWeb) return NetworkImage(_profileImagePath!);
      return FileImage(File(_profileImagePath!));
    }
    return null;
  }""";
  
  final newProvider = """  ImageProvider? _buildProfileImageProvider() {
    if (_isLocalAvatarNew && _profileImagePath != null) {
      if (kIsWeb) return NetworkImage(_profileImagePath!);
      return FileImage(File(_profileImagePath!));
    }
    if (_profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty) {
      final String url = _profile!.photoUrl!;
      // Append timestamp to bypass caching if we just uploaded
      final String finalUrl = _isLocalAvatarNew ? '\$url?t=\${DateTime.now().millisecondsSinceEpoch}' : url;
      return NetworkImage(finalUrl);
    }
    if (_profileImagePath != null) {
      if (kIsWeb) return NetworkImage(_profileImagePath!);
      return FileImage(File(_profileImagePath!));
    }
    return null;
  }""";
  
  content = content.replaceAll(oldProvider, newProvider);

  // 3. Rewrite _pickAndUploadPhoto
  final oldUpload = """  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;

      setState(() {
        _profileImage = picked;
        _isPhotoChanged = true;
      });

      await _profileApiService.uploadProfilePhoto(File(picked.path));

      // Clear Flutter image cache so old avatar doesn't linger
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await getIt<SharedPreferences>().setString('profile_image', picked.path);

      if (mounted) {
        setState(() => _isPhotoChanged = false);
        loadProfile();
        _loadSocialProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.profilePhotoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPhotoChanged = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failedToUploadPhoto(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }""";
  
  final newUpload = """  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;

      if (!context.mounted) return;
      final String? finalImagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imagePath: picked.path),
        ),
      );

      if (finalImagePath == null) return;

      setState(() {
        _profileImage = XFile(finalImagePath);
        _profileImagePath = finalImagePath;
        _isPhotoChanged = true;
        _isLocalAvatarNew = true; // Use local image instantly
      });

      await _profileApiService.uploadProfilePhoto(File(finalImagePath));

      // Clear Flutter image cache so old avatar doesn't linger
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      await getIt<SharedPreferences>().setString('profile_image', finalImagePath);

      if (mounted) {
        setState(() {
          _isPhotoChanged = false;
        });
        loadProfile();
        _loadSocialProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.profilePhotoUpdated)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPhotoChanged = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failedToUploadPhoto(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }""";

  content = content.replaceAll(oldUpload, newUpload);

  file.writeAsStringSync(content);
  print('Updated profile_screen.dart for preview and photo update fix');
}
