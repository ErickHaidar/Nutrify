import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String content;
  final String? imagePath;
  final File? localImageFile;
  final int authorId;
  int likes;
  int comments;
  bool isLiked;
  bool isFollowed;
  final String tabCategory;

  bool get isOwnPost {
    final currentUserId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return false;
    return currentUserId == authorId.toString();
  }

  CommunityPost({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl = '',
    this.timeAgo = '',
    required this.content,
    this.imagePath,
    this.localImageFile,
    this.authorId = 0,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isFollowed,
    this.tabCategory = 'Untuk Anda',
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return CommunityPost(
      id: json['id'].toString(),
      authorName: user['name'] as String? ?? '',
      authorAvatarUrl: '',
      content: json['content'] as String? ?? '',
      imagePath: json['image_url'] as String?,
      authorId: user['id'] as int? ?? 0,
      likes: json['likes_count'] as int? ?? 0,
      comments: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isFollowed: false,
      timeAgo: _formatTimeAgo(json['created_at'] as String?),
    );
  }

  static String _formatTimeAgo(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes}m lalu';
      if (diff.inDays < 1) return '${diff.inHours}j lalu';
      if (diff.inDays < 7) return '${diff.inDays}h lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
