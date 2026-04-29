import re

with open('frontend/lib/screens/edit_profile_screen.dart', 'r') as f:
    content = f.read()

# Add _isPhotoChanged
content = re.sub(r'bool _isSaving = false;', 'bool _isSaving = false;\n  bool _isPhotoChanged = false;', content)

# Update upload logic
old_upload = """      // If profile image was picked and has changes
      if (_profileImage != null && kIsWeb == false) {
        final savedImagePath = getIt<SharedPreferences>().getString('profile_image');
        if (_profileImage!.path == savedImagePath) {
          await _profileApiService.uploadProfilePhoto(File(_profileImage!.path));
        }
      }"""

new_upload = """      if (_profileImage != null && kIsWeb == false && _isPhotoChanged) {
        await _profileApiService.uploadProfilePhoto(File(_profileImage!.path));
        _isPhotoChanged = false;
      }"""

content = content.replace(old_upload, new_upload)

# Update setState in _pickImage
old_set_state = """        setState(() {
          _profileImage = pickedFile;
        });"""

new_set_state = """        setState(() {
          _profileImage = pickedFile;
          _isPhotoChanged = true;
        });"""

content = content.replace(old_set_state, new_set_state)

with open('frontend/lib/screens/edit_profile_screen.dart', 'w') as f:
    f.write(content)

