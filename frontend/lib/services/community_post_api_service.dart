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

  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final res = await _dio.dio.post('${Endpoints.posts}/$postId/like');
    return {'liked': res.data['liked'] as bool, 'likes_count': res.data['likes_count'] as int};
  }

  Future<List<CommentItem>> getComments(int postId) async {
    final res = await _dio.dio.get('${Endpoints.posts}/$postId/comments');
    final List<dynamic> data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data.map((e) => CommentItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommentItem> addComment(int postId, String content) async {
    final res = await _dio.dio.post('${Endpoints.posts}/$postId/comments', data: {'content': content});
    return CommentItem.fromJson(res.data['data'] as Map<String, dynamic>);
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
  final String userName;
  final DateTime createdAt;

  CommentItem({required this.id, required this.content, required this.userName, required this.createdAt});

  factory CommentItem.fromJson(Map<String, dynamic> json) => CommentItem(
        id: json['id'] as int,
        content: json['content'] as String,
        userName: (json['user'] ?? {})['name'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
