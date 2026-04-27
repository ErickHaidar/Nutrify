import 'dart:io';

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String timeAgo;
  final String content;
  final String? imagePath; // Can be asset or local file path
  final File? localImageFile; // For newly uploaded posts
  int likes;
  int comments;
  bool isLiked;
  bool isFollowed;
  final String tabCategory; // 'Untuk Anda' or 'Diikuti'

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.timeAgo,
    required this.content,
    this.imagePath,
    this.localImageFile,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.isFollowed,
    required this.tabCategory,
  });
}
