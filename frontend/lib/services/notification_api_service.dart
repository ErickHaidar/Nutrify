import 'package:flutter/material.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';

class NotificationApiService {
  DioClient get _dio => getIt<DioClient>();

  Future<List<NotificationItem>> getNotifications({int page = 1}) async {
    final res = await _dio.dio.get(
      Endpoints.notifications,
      queryParameters: {'page': page, 'per_page': 20},
    );
    final items = (res.data['data'] as List?) ?? [];
    return items.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.dio.get('${Endpoints.notifications}/unread-count');
    return (res.data['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _dio.dio.put('${Endpoints.notifications}/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.dio.put('${Endpoints.notifications}/read-all');
  }
}

class NotificationItem {
  final int id;
  final String type;
  final String title;
  final String body;
  final int? actorId;
  final String? actorName;
  final int? postId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.actorId,
    this.actorName,
    this.postId,
    this.data,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final actor = json['actor'] as Map<String, dynamic>?;
    return NotificationItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actorId: (json['actor_id'] as num?)?.toInt(),
      actorName: actor?['name'] as String?,
      postId: (json['post_id'] as num?)?.toInt(),
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['read_at'] != null,
    );
  }

  IconDataData get iconData {
    switch (type) {
      case 'like':
        return IconDataData(Icons.favorite, Colors.red);
      case 'comment':
        return IconDataData(Icons.chat_bubble, const Color(0xFF64B5F6));
      case 'follow':
        return IconDataData(Icons.person_add, const Color(0xFF81C784));
      default:
        return IconDataData(Icons.notifications, Colors.orangeAccent);
    }
  }
}

class IconDataData {
  final IconData icon;
  final Color color;
  IconDataData(this.icon, this.color);
}
