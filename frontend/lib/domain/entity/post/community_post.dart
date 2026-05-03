import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String authorUsername;
  final String authorSupabaseId;
  final String timeAgo;
  final String content;
  final String? imagePath;
  final File? localImageFile;
  final int authorId;
  final String authorAccountType;
  int likes;
  int comments;
  bool isLiked;
  bool isFollowed;
  bool isRequested;
  final String tabCategory;
  final DateTime createdAt;
  final bool isPinned;
  final DateTime? pinnedAt;

  bool get canEdit => DateTime.now().difference(createdAt).inHours < 1;

  bool get isOwnPost {
    final currentUserId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null || authorSupabaseId.isEmpty) return false;
    return currentUserId == authorSupabaseId;
  }

  CommunityPost({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl = '',
    this.authorUsername = '',
    this.authorSupabaseId = '',
    this.timeAgo = '',
    required this.content,
    this.imagePath,
    this.localImageFile,
    this.authorId = 0,
    this.authorAccountType = 'public',
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isFollowed,
    required this.isRequested,
    this.tabCategory = 'Untuk Anda',
    DateTime? createdAt,
    this.isPinned = false,
    this.pinnedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return CommunityPost(
      id: json['id'].toString(),
      authorName: user['name'] as String? ?? '',
      authorAvatarUrl: user['avatar_url'] as String? ?? '',
      authorUsername: user['username'] as String? ?? '',
      authorSupabaseId: user['supabase_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imagePath: json['image_url'] as String?,
      authorId: user['id'] as int? ?? 0,
      authorAccountType: user['account_type'] as String? ?? 'public',
      likes: json['likes_count'] as int? ?? 0,
      comments: json['comments_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isFollowed: json['is_followed'] as bool? ?? false,
      isRequested: json['is_requested'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      pinnedAt: json['pinned_at'] != null ? DateTime.parse(json['pinned_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
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
