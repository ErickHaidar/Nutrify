import 'package:flutter/material.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';
import 'package:nutrify/screens/post_detail_screen.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/utils/locale/app_strings.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _api = CommunityPostApiService();
  bool _isLoading = true;

  String _name = '';
  String _username = '';
  String _avatarUrl = '';
  String _accountType = 'public';
  int _followersCount = 0;
  int _followingsCount = 0;
  int _postsCount = 0;
  List<CommunityPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _api.getMyProfile();
      if (mounted) {
        setState(() {
          _name = data['name'] as String? ?? '';
          _username = data['username'] as String? ?? '';
          _avatarUrl = data['avatar_url'] as String? ?? '';
          _accountType = data['account_type'] as String? ?? 'public';
          _followersCount = data['followers_count'] as int? ?? 0;
          _followingsCount = data['followings_count'] as int? ?? 0;
          _postsCount = data['posts_count'] as int? ?? 0;
          _isLoading = false;
        });
        _loadMyPosts();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyPosts() async {
    try {
      final posts = await _api.getPosts();
      if (mounted) {
        setState(() {
          _posts = posts.where((p) => p.isOwnPost).toList();
        });
      }
    } catch (_) {}
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final usernameCtrl = TextEditingController(text: _username);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  const Text('Edit Profil', style: TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.navy.withValues(alpha: 0.1),
                      child: const Icon(Icons.close, size: 18, color: AppColors.navy),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: AppColors.navy),
                      prefixText: '@',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _api.updateProfile(
                            name: nameCtrl.text.trim(),
                            username: usernameCtrl.text.trim(),
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            _loadProfile();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Future<void> _toggleAccountType() async {
    final newType = _accountType == 'public' ? 'private' : 'public';
    try {
      await _api.updateProfile(accountType: newType);
      if (mounted) {
        setState(() => _accountType = newType);
      }
    } catch (_) {}
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
          : RefreshIndicator(
              onRefresh: _loadProfile,
              color: AppColors.amber,
              backgroundColor: AppColors.navy,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    const Divider(height: 1, color: Colors.black12),
                    _buildPostsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
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
            ),
            child: _avatarUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _avatarUrl.startsWith('http') ? _avatarUrl : 'https://nutrify-app.my.id$_avatarUrl',
                      width: 90, height: 90, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitialsAvatar(),
                    ),
                  )
                : _buildInitialsAvatar(),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            _name,
            style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (_username.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '@$_username',
              style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 14),
            ),
          ],
          const SizedBox(height: 20),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Postingan', _postsCount),
              Container(
                width: 1, height: 30,
                color: AppColors.navy.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(horizontal: 24),
              ),
              _buildStatItem('Pengikut', _followersCount),
              Container(
                width: 1, height: 30,
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
                    onPressed: _showEditDialog,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: BorderSide(color: AppColors.navy.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: _buildAccountTypeToggle(),
                ),
              ),
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
          color: isPrivate ? AppColors.navy : AppColors.peach.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isPrivate ? AppColors.navy : AppColors.navy.withValues(alpha: 0.2),
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
        _name.isNotEmpty ? _name[0].toUpperCase() : '?',
        style: const TextStyle(color: AppColors.navy, fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(color: AppColors.navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }

  Widget _buildPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              const Text('Postingan', style: TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('$_postsCount', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 14)),
            ],
          ),
        ),
        if (_posts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.article_outlined, size: 48, color: AppColors.navy.withValues(alpha: 0.2)),
                  const SizedBox(height: 12),
                  Text('Belum ada postingan', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.5), fontSize: 14)),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _posts.length,
            separatorBuilder: (_, __) => Divider(color: AppColors.navy.withValues(alpha: 0.1), thickness: 1, height: 24),
            itemBuilder: (context, index) => _buildPostCard(_posts[index]),
          ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post, api: _api)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.content, style: const TextStyle(color: AppColors.navy, fontSize: 14, height: 1.5), maxLines: 4, overflow: TextOverflow.ellipsis),
            if (post.imagePath != null && post.imagePath!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imagePath!.startsWith('http') ? post.imagePath! : 'https://nutrify-app.my.id${post.imagePath!}',
                  width: double.infinity, height: 160, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : AppColors.navy.withValues(alpha: 0.4), size: 18),
                const SizedBox(width: 4),
                Text('${post.likes}', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, color: AppColors.navy.withValues(alpha: 0.4), size: 16),
                const SizedBox(width: 4),
                Text('${post.comments}', style: TextStyle(color: AppColors.navy.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(post.timeAgo, style: TextStyle(color: AppColors.navy.withValues(alpha: 0.4), fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
