import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/domain/entity/post/community_post.dart';

class CommunityPostApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<CommunityPost>> getPosts({int page = 1}) async {
    final res = await _dio.dio.get(
      Endpoints.posts,
      queryParameters: {'page': page},
    );
    final List<dynamic> data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data.map((e) => CommunityPost.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommunityPost> createPost({required String content, File? imageFile}) async {
    FormData formData = FormData.fromMap({'content': content});
    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      formData.files.add(MapEntry('image', await MultipartFile.fromFile(imageFile.path, filename: fileName)));
    }
    final res = await _dio.dio.post(Endpoints.posts, data: formData);
    return CommunityPost.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deletePost(int postId) async {
    await _dio.dio.delete('${Endpoints.posts}/$postId');
  }

  Future<CommunityPost> updatePost(int postId, {required String content}) async {
    final res = await _dio.dio.put('${Endpoints.posts}/$postId', data: {'content': content});
    return CommunityPost.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<bool> togglePin(int postId) async {
    final res = await _dio.dio.post('${Endpoints.posts}/$postId/pin');
    return res.data['is_pinned'] as bool;
  }

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final res = await _dio.dio.post('${Endpoints.posts}/$postId/like');
    return {'liked': res.data['liked'] as bool, 'likes_count': res.data['likes_count'] as int};
  }

  Future<List<CommentItem>> getComments(int postId) async {
    final res = await _dio.dio.get('${Endpoints.posts}/$postId/comments');
    final List<dynamic> data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data.map((e) => CommentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommentItem> addComment(int postId, String content, {int? parentId}) async {
    final data = <String, dynamic>{'content': content};
    if (parentId != null) data['parent_id'] = parentId;
    final res = await _dio.dio.post('${Endpoints.posts}/$postId/comments', data: data);
    return CommentItem.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> toggleCommentLike(int commentId) async {
    final res = await _dio.dio.post('comments/$commentId/like');
    return {'liked': res.data['liked'] as bool, 'likes_count': res.data['likes_count'] as int};
  }

  Future<List<CommentItem>> getCommentReplies(int commentId, {int page = 1}) async {
    final res = await _dio.dio.get('comments/$commentId/replies', queryParameters: {'page': page});
    final List<dynamic> data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data.map((e) => CommentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> toggleFollow(int userId) async {
    final res = await _dio.dio.post('users/$userId/follow');
    return {
      'followed': res.data['followed'] as bool? ?? false,
      'requested': res.data['requested'] as bool? ?? false,
      'followers_count': res.data['followers_count'] as int? ?? 0,
    };
  }

  Future<bool> approveFollowRequest(int requesterId) async {
    final res = await _dio.dio.post('follow-requests/$requesterId/approve');
    return res.data['success'] as bool? ?? false;
  }

  Future<bool> rejectFollowRequest(int requesterId) async {
    final res = await _dio.dio.post('follow-requests/$requesterId/reject');
    return res.data['success'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final res = await _dio.dio.get('users/$userId/profile');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final res = await _dio.dio.get('users/search', queryParameters: {'q': query});
    final List<dynamic> data = res.data['data'] as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.dio.get('users/me');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({String? name, String? username, String? accountType}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;
    if (accountType != null) data['account_type'] = accountType;
    final res = await _dio.dio.put('users/profile', data: data);
    return res.data['data'] as Map<String, dynamic>;
  }
}

class CommentItem {
  final int id;
  final String content;
  final int userId;
  final String userName;
  final String? userUsername;
  final String? userAvatarUrl;
  final int? parentId;
  final int likesCount;
  final bool isLiked;
  final int repliesCount;
  final List<CommentItem> replies;
  final DateTime createdAt;

  CommentItem({
    required this.id,
    required this.content,
    required this.userId,
    required this.userName,
    this.userUsername,
    this.userAvatarUrl,
    this.parentId,
    this.likesCount = 0,
    this.isLiked = false,
    this.repliesCount = 0,
    this.replies = const [],
    required this.createdAt,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final avatarUrl = user['avatar_url'] as String?;
    return CommentItem(
      id: json['id'] as int,
      content: json['content'] as String,
      userId: user['id'] as int? ?? 0,
      userName: user['name'] as String? ?? '',
      userUsername: user['username'] as String?,
      userAvatarUrl: avatarUrl != null && avatarUrl.isNotEmpty
          ? (avatarUrl.startsWith('http') ? avatarUrl : 'https://nutrify-app.my.id/$avatarUrl')
          : null,
      parentId: json['parent_id'] as int?,
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      repliesCount: json['replies_count'] as int? ?? 0,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => CommentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}
