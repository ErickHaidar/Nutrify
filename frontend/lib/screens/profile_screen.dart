import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/post_detail_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'edit_profile_screen.dart';
import '../services/profile_api_service.dart';
import '../services/notification_service.dart';
import '../constants/colors.dart';
import '../widgets/shimmer_loading.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCreatePost;
  const ProfileScreen({super.key, this.onNavigateToCreatePost});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // General tab
  final _profileApiService = ProfileApiService();
  final _communityApi = CommunityPostApiService();
  ApiProfileData? _profile;
  bool _isLoading = true;
  String? _profileImagePath;
  bool _notificationsEnabled = true;
  XFile? _profileImage;
  bool _isPhotoChanged = false;
  final ImagePicker _picker = getIt<ImagePicker>();

  // Social tab
  bool _socialLoading = true;
  String _socName = '';
  String _socUsername = '';
  String _socAvatarUrl = '';
  String _accountType = 'public';
  int _followersCount = 0;
  int _followingsCount = 0;
  int _postsCount = 0;
  List<CommunityPost> _posts = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _profileImagePath =
        getIt<SharedPreferences>().getString('profile_image');
    _notificationsEnabled =
        getIt<SharedPreferences>().getBool('notifications_enabled') ?? true;
    final savedImage = getIt<SharedPreferences>().getString('profile_image');
    if (savedImage != null) _profileImage = XFile(savedImage);
    loadProfile();
    _loadSocialProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ========================
  // GENERAL TAB DATA
  // ========================

  void switchToSocialTab() {
    _tabController.animateTo(1);
  }

  void switchToUmumTab() {
    _tabController.animateTo(0);
  }

  Future<void> loadProfile() async {
    try {
      final profile = await _profileApiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = getIt<SharedPreferences>();
    final notificationService = getIt<NotificationService>();

    if (value) {
      setState(() => _notificationsEnabled = true);
      final granted = await notificationService.requestPermissions();
      if (granted) {
        await prefs.setBool('notifications_enabled', true);
        await notificationService.scheduleMealReminders();
        await notificationService.registerPushNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.notifEnabled)),
          );
        }
      } else {
        setState(() => _notificationsEnabled = false);
        await prefs.setBool('notifications_enabled', false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.notifDenied)),
          );
        }
      }
    } else {
      setState(() => _notificationsEnabled = false);
      await prefs.setBool('notifications_enabled', false);
      await notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.notifDisabled)),
        );
      }
    }
  }

  ImageProvider? _buildProfileImageProvider() {
    if (_profile?.photoUrl != null && _profile!.photoUrl!.isNotEmpty) {
      return NetworkImage(_profile!.photoUrl!);
    }
    if (_profileImagePath != null) {
      if (kIsWeb) return NetworkImage(_profileImagePath!);
      return FileImage(File(_profileImagePath!));
    }
    return null;
  }

  // ========================
  // SOCIAL TAB DATA
  // ========================

  Future<void> _loadSocialProfile() async {
    try {
      final data = await _communityApi.getMyProfile();
      if (mounted) {
        setState(() {
          _socName = data['name'] as String? ?? '';
          _socUsername = data['username'] as String? ?? '';
          _socAvatarUrl = data['avatar_url'] as String? ?? '';
          _accountType = data['account_type'] as String? ?? 'public';
          _followersCount = data['followers_count'] as int? ?? 0;
          _followingsCount = data['followings_count'] as int? ?? 0;
          _postsCount = data['posts_count'] as int? ?? 0;
          _socialLoading = false;
        });
        _loadMyPosts();
      }
    } catch (_) {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  Future<void> _loadMyPosts() async {
    try {
      final posts = await _communityApi.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts.where((p) => p.isOwnPost).toList();
        });
      }
    } catch (_) {}
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _socName);
    final usernameCtrl = TextEditingController(text: _socUsername);
    String? usernameError;
    bool isChecking = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    const Text('Edit Profil',
                        style: TextStyle(
                            color: AppColors.navy,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.navy),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        labelStyle: const TextStyle(color: AppColors.navy),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameCtrl,
                      onChanged: (value) async {
                        final trimmed = value.trim();
                        if (trimmed.isEmpty || trimmed == _socUsername) {
                          setDialogState(() { usernameError = null; isChecking = false; });
                          return;
                        }
                        setDialogState(() { isChecking = true; usernameError = null; });
                        try {
                          final results = await _communityApi.searchUsers(trimmed);
                          final taken = results.any((u) =>
                              (u['username'] as String? ?? '').toLowerCase() == trimmed.toLowerCase());
                          setDialogState(() { usernameError = taken ? 'Username sudah digunakan' : null; isChecking = false; });
                        } catch (_) {
                          setDialogState(() { isChecking = false; });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: AppColors.navy),
                        prefixText: '@',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none),
                        errorText: usernameError,
                        errorStyle: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.normal),
                        suffixIcon: isChecking
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : usernameError == null && usernameCtrl.text.trim().isNotEmpty && usernameCtrl.text.trim() != _socUsername
                                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: usernameError != null || isChecking ? null : () async {
                          try {
                            await _communityApi.updateProfile(
                              name: nameCtrl.text.trim(),
                              username: usernameCtrl.text.trim(),
                            );
                            if (mounted) {
                              Navigator.pop(ctx);
                              _loadSocialProfile();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Gagal menyimpan: $e'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: usernameError != null || isChecking ? Colors.grey : AppColors.navy,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Simpan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleAccountType() async {
    final newType = _accountType == 'public' ? 'private' : 'public';
    try {
      await _communityApi.updateProfile(accountType: newType);
      if (mounted) {
        setState(() => _accountType = newType);
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
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
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPhotoChanged = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Ubah Foto Profil',
                  style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFFFCC80)),
                title: const Text('Galeri'),
                onTap: () { Navigator.pop(ctx); _pickAndUploadPhoto(ImageSource.gallery); },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFFFCC80)),
                title: const Text('Kamera'),
                onTap: () { Navigator.pop(ctx); _pickAndUploadPhoto(ImageSource.camera); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return count.toString();
  }

  // ========================
  // POST MANAGEMENT
  // ========================

  Future<void> _editPost(CommunityPost post) async {
    final ctrl = TextEditingController(text: post.content);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  const Text('Edit Postingan',
                      style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                      child: const Icon(Icons.close,
                          size: 18, color: AppColors.navy),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  TextField(
                    controller: ctrl,
                    maxLines: 5,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _communityApi.updatePost(
                            int.parse(post.id),
                            content: ctrl.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            _loadSocialProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Postingan berhasil diedit')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Gagal: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePost(CommunityPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text('Hapus Postingan?',
            style: TextStyle(color: AppColors.navy)),
        content: const Text(
            'Postingan ini akan dihapus secara permanen.',
            style: TextStyle(color: AppColors.navy)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _communityApi.deletePost(int.parse(post.id));
        _loadSocialProfile();
      } catch (_) {}
    }
  }

  Future<void> _togglePinPost(CommunityPost post) async {
    try {
      await _communityApi.togglePin(int.parse(post.id));
      _loadSocialProfile();
    } catch (_) {}
  }

  // ========================
  // LANGUAGE
  // ========================

  void _showLanguagePicker() {
    final languageStore = getIt<LanguageStore>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.chooseLanguage,
                  style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildLanguageOption(ctx, languageStore,
                  flag: '🇮🇩', label: 'Bahasa Indonesia', locale: 'id'),
              const SizedBox(height: 12),
              _buildLanguageOption(ctx, languageStore,
                  flag: '🇺🇸', label: 'English', locale: 'en'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, LanguageStore languageStore,
      {required String flag, required String label, required String locale}) {
    final isSelected = AppStrings.currentLocale == locale;
    return GestureDetector(
      onTap: () {
        languageStore.changeLanguage(locale);
        Navigator.pop(ctx);
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home, (route) => false);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.peach : NutrifyTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.navy, width: 2) : null,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.navy),
          ],
        ),
      ),
    );
  }

  // ========================
  // BUILD
  // ========================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(child: ProfileShimmer()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Logo + Brand
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Image.asset(Assets.nutrifyLogo, height: 40, width: 40),
                  const SizedBox(width: 8),
                  Text(
                    'Nutrify',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFB26B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TabBar (underline style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.navy,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.navy.withValues(alpha: 0.1),
                labelColor: AppColors.navy,
                unselectedLabelColor: AppColors.navy.withValues(alpha: 0.4),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 14),
                tabs: const [
                  Tab(text: 'Umum'),
                  Tab(text: 'Sosial'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUmumTab(),
                  _buildSosialTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // UMUM TAB
  // ========================

  Widget _buildUmumTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Info Grid or CTA
          if (_profile == null ||
              _profile!.age == 0 ||
              _profile!.weight == 0 ||
              _profile!.height == 0)
            _buildCompleteProfileBanner()
          else
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildInfoBox(AppStrings.height,
                    _profile != null ? '${_profile!.height} cm' : '-'),
                _buildInfoBox(AppStrings.weight,
                    _profile != null ? '${_profile!.weight} kg' : '-'),
                _buildInfoBox(AppStrings.age,
                    _profile != null ? '${_profile!.age} ${AppStrings.years}' : '-'),
                _buildInfoBox(
                    AppStrings.gender, _profile?.genderDisplay ?? '-'),
                _buildInfoBox(
                  'BMI',
                  _profile != null
                      ? '${_profile!.bmi.toStringAsFixed(1)} (${_profile!.bmiStatus})'
                      : '-',
                ),
                _buildInfoBox(
                  AppStrings.target,
                  _profile != null
                      ? '${_profile!.targetCalories} kcal'
                      : '-',
                ),
              ],
            ),
          const SizedBox(height: 30),

          // General Settings
          Text(AppStrings.generalSettings,
              style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMenuButton(context,
              icon: Icons.person_rounded,
              label: AppStrings.editProfile,
              onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()),
            );
            if (result == true) {
              setState(() {
                _profileImagePath =
                    getIt<SharedPreferences>().getString('profile_image');
              });
              loadProfile();
            }
          }),
          const SizedBox(height: 30),

          // Preferences
          Text(AppStrings.preferences,
              style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMenuButton(context,
              icon: Icons.notifications_rounded,
              label: AppStrings.notification,
              onPressed: () => _toggleNotifications(!_notificationsEnabled),
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                onChanged: (val) => _toggleNotifications(val),
                activeColor: AppColors.navy,
              )),
          const SizedBox(height: 12),
          _buildMenuButton(context,
              icon: Icons.language_rounded,
              label: AppStrings.language,
              onPressed: _showLanguagePicker,
              trailing: Text(
                AppStrings.isId ? '🇮🇩 ID' : '🇺🇸 EN',
                style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              )),
          const SizedBox(height: 12),
          _buildMenuButton(context,
              icon: Icons.logout_rounded,
              label: AppStrings.logout,
              onPressed: () async {
            await getIt<UserStore>().logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.login,
                (Route<dynamic> route) => false,
              );
            }
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ========================
  // SOSIAL TAB
  // ========================

  Widget _buildSosialTab() {
    if (_socialLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.navy));
    }

    return RefreshIndicator(
      onRefresh: _loadSocialProfile,
      color: AppColors.amber,
      backgroundColor: AppColors.navy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // Avatar with camera button
            GestureDetector(
              onTap: _showImagePickerModal,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.peach.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      image: _buildProfileImageProvider() != null
                          ? DecorationImage(
                              image: _buildProfileImageProvider()!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _buildProfileImageProvider() == null
                        ? _buildInitialsAvatar()
                        : null,
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cream, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt, color: AppColors.navy, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _profile?.name ?? _socName,
              style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            if (_socUsername.isNotEmpty)
              Text('@$_socUsername',
                  style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.5),
                      fontSize: 14)),
            const SizedBox(height: 20),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('Postingan', _postsCount),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.navy.withValues(alpha: 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStatItem('Pengikut', _followersCount),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.navy.withValues(alpha: 0.1),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildStatItem('Mengikuti', _followingsCount),
              ],
            ),
            const SizedBox(height: 20),

            // Edit Profile + Account Type row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _showEditProfileDialog,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        side: BorderSide(
                            color: AppColors.navy.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                      height: 44, child: _buildAccountTypeToggle()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Posts section
            Row(
              children: [
                const Text('Postingan',
                    style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text('$_postsCount',
                    style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.5),
                        fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            _posts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.article_outlined,
                            size: 48,
                            color: AppColors.navy.withValues(alpha: 0.2)),
                        const SizedBox(height: 12),
                        Text('Belum ada postingan',
                            style: TextStyle(
                                color: AppColors.navy.withValues(alpha: 0.5),
                                fontSize: 14)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onNavigateToCreatePost?.call();
                            },
                            icon: const Icon(Icons.edit_note, size: 20),
                            label: const Text('Buat Postingan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => Divider(
                        color: AppColors.navy.withValues(alpha: 0.1),
                        thickness: 1,
                        height: 24),
                    itemBuilder: (context, index) =>
                        _buildPostCard(_posts[index]),
                  ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PostDetailScreen(
                  post: post, api: _communityApi)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: pin badge + three-dot menu
          Row(
            children: [
              if (post.isPinned) ...[
                Icon(Icons.push_pin,
                    size: 14,
                    color: AppColors.navy.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text('Disematkan',
                    style: TextStyle(
                        color: AppColors.navy.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
              ] else
                const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz,
                    color: AppColors.navy.withValues(alpha: 0.6)),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                onSelected: (value) {
                  if (value == 'edit') _editPost(post);
                  if (value == 'delete') _deletePost(post);
                  if (value == 'pin') _togglePinPost(post);
                },
                itemBuilder: (_) => [
                  if (post.canEdit)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: AppColors.navy, size: 20),
                        SizedBox(width: 8),
                        Text('Edit',
                            style: TextStyle(color: AppColors.navy)),
                      ]),
                    ),
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(children: [
                      Icon(
                          post.isPinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined,
                          color: AppColors.navy,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(post.isPinned ? 'Lepas Sematan' : 'Sematkan',
                          style: const TextStyle(color: AppColors.navy)),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Content
          Text(post.content,
              style: const TextStyle(
                  color: AppColors.navy, fontSize: 14, height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imagePath!.startsWith('http')
                    ? post.imagePath!
                    : 'https://nutrify-app.my.id${post.imagePath!}',
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                  post.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: post.isLiked
                      ? Colors.red
                      : AppColors.navy.withValues(alpha: 0.4),
                  size: 18),
              const SizedBox(width: 4),
              Text('${post.likes}',
                  style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline,
                  color: AppColors.navy.withValues(alpha: 0.4), size: 16),
              const SizedBox(width: 4),
              Text('${post.comments}',
                  style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(post.timeAgo,
                  style: TextStyle(
                      color: AppColors.navy.withValues(alpha: 0.4),
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTypeToggle() {
    final isPrivate = _accountType == 'private';
    return GestureDetector(
      onTap: _toggleAccountType,
      child: Container(
        decoration: BoxDecoration(
          color: isPrivate
              ? AppColors.navy
              : AppColors.peach.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isPrivate
                ? AppColors.navy
                : AppColors.navy.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPrivate ? Icons.lock : Icons.lock_open,
              size: 16,
              color: isPrivate ? Colors.white : AppColors.navy,
            ),
            const SizedBox(width: 6),
            Text(
              isPrivate ? 'Privat' : 'Publik',
              style: TextStyle(
                color: isPrivate ? Colors.white : AppColors.navy,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Center(
      child: Text(
        _socName.isNotEmpty ? _socName[0].toUpperCase() : '?',
        style: const TextStyle(
            color: AppColors.navy, fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(_formatCount(count),
            style: const TextStyle(
                color: AppColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }

  // ========================
  // SHARED BUILDERS
  // ========================

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppColors.navy.withValues(alpha: 0.7),
                  fontSize: 11)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteProfileBanner() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EditProfileScreen()),
        );
        if (result == true) loadProfile();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.navy, Color(0xFF2D2A4A)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.edit_note_rounded,
                color: AppColors.amber, size: 40),
            const SizedBox(height: 12),
            Text(
              AppStrings.isId
                  ? 'Lengkapi Profil Anda'
                  : 'Complete Your Profile',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.isId
                  ? 'Isi data tinggi, berat, dan usia untuk mendapatkan rekomendasi kalori personalized.'
                  : 'Fill in your height, weight, and age to get personalized calorie recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppStrings.isId ? 'Isi Sekarang' : 'Fill Now',
                style: const TextStyle(
                    color: AppColors.navy, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon,
      required String label,
      Widget? destination,
      Widget? trailing,
      VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: NutrifyTheme.lightCard,
        borderRadius: BorderRadius.circular(35),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ??
              () {
                if (destination != null) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => destination));
                }
              },
          borderRadius: BorderRadius.circular(35),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: AppColors.navy.withValues(alpha: 0.6),
                      size: 22),
                ),
                const SizedBox(width: 15),
                Text(label,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    )),
                const Spacer(),
                trailing ??
                    const Icon(Icons.chevron_right,
                        color: AppColors.navy, size: 20),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
