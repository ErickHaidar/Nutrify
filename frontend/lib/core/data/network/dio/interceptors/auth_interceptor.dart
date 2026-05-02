import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;

  AuthInterceptor({
    required this.accessToken,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String token = await accessToken() ?? '';
    if (token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Session expired or invalid — sign out user
      _handleSessionExpired();
    }
    super.onError(err, handler);
  }

  void _handleSessionExpired() {
    try {
      Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }
}
