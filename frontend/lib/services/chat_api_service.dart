import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';

class ConversationItem {
  final int id;
  final int otherUserId;
  final String otherUserName;
  final String otherUsername;
  final String? otherUserAvatarUrl;
  final String? lastMessageContent;
  final String? lastMessageImageUrl;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ConversationItem({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUsername,
    this.otherUserAvatarUrl,
    this.lastMessageContent,
    this.lastMessageImageUrl,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) =>
      ConversationItem(
        id: json['id'] as int,
        otherUserId: json['other_user_id'] as int,
        otherUserName: json['other_user_name'] as String? ?? '',
        otherUsername: json['other_username'] as String? ?? '',
        otherUserAvatarUrl: json['other_user_avatar_url'] as String?,
        lastMessageContent: json['last_message'] != null
            ? json['last_message']['content'] as String?
            : null,
        lastMessageImageUrl: json['last_message'] != null
            ? json['last_message']['image_url'] as String?
            : null,
        lastMessageAt: json['last_message'] != null
            ? DateTime.parse(json['last_message']['created_at'] as String)
            : null,
        unreadCount: json['unread_count'] as int? ?? 0,
      );
}

class MessageItem {
  final int id;
  final int senderId;
  final String? content;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;

  MessageItem({
    required this.id,
    required this.senderId,
    this.content,
    this.imageUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) => MessageItem(
        id: json['id'] as int,
        senderId: json['sender_id'] as int,
        content: json['content'] as String?,
        imageUrl: json['image_url'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class ChatApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<ConversationItem>> getConversations({
    String filter = 'all',
    String? search,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (filter != 'all') params['filter'] = filter;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _dio.dio.get(
      Endpoints.chatConversations,
      queryParameters: params,
    );
    final List<dynamic> data = res.data['data'] ?? [];
    return data
        .map((e) => ConversationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationItem> createConversation(int userId) async {
    final res = await _dio.dio.post(
      Endpoints.chatConversations,
      data: {'user_id': userId},
    );
    return ConversationItem.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<MessageItem>> getMessages(int conversationId, {int page = 1}) async {
    final res = await _dio.dio.get(
      '${Endpoints.chatConversations}/$conversationId/messages',
      queryParameters: {'page': page},
    );
    final List<dynamic> data = res.data['data']['data'] ?? res.data['data'] ?? [];
    return data
        .map((e) => MessageItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageItem> sendMessage(int conversationId, {
    String? content,
    File? imageFile,
  }) async {
    FormData? formData;
    if (imageFile != null) {
      final fileName = imageFile.path.split('/').last;
      final Map<String, dynamic> formMap = {};
      if (content != null && content.isNotEmpty) formMap['content'] = content;
      formMap['image'] = await MultipartFile.fromFile(imageFile.path, filename: fileName);
      formData = FormData.fromMap(formMap);
    }

    final res = await _dio.dio.post(
      '${Endpoints.chatConversations}/$conversationId/messages',
      data: formData ?? {'content': content},
    );
    return MessageItem.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> markAsRead(int conversationId) async {
    await _dio.dio.put('${Endpoints.chatConversations}/$conversationId/read');
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.dio.get(Endpoints.chatUnreadCount);
    return res.data['unread_count'] as int? ?? 0;
  }

  Future<void> markAllRead() async {
    await _dio.dio.post('chat/mark-all-read');
  }
}
