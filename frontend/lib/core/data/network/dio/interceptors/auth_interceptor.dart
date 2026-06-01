import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';

class AuthInterceptor extends Interceptor {
  final AsyncValueGetter<String?> accessToken;
  Future<void>? _refreshTask;

  AuthInterceptor({
    required this.accessToken,
  });

  Future<void> _refreshToken() async {
    try {
      await Supabase.instance.client.auth.refreshSession();
    } finally {
      _refreshTask = null;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final session = Supabase.instance.client.auth.currentSession;

    // Proactively refresh if the token is already expired locally
    if (session != null && session.isExpired) {
      _refreshTask ??= _refreshToken();
      try {
        await _refreshTask;
      } catch (_) {
        // If refresh fails, we continue anyway to let it hit 401
      }
    }

    final String token = await accessToken() ?? '';
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Avoid infinite loop if we already retried this request
      if (err.requestOptions.extra['isRetry'] == true) {
        _handleSessionExpired();
        return super.onError(err, handler);
      }

      try {
        // Session expired or invalid — try to refresh before signing out
        _refreshTask ??= _refreshToken();
        await _refreshTask;

        final String newToken = await accessToken() ?? '';
        if (newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          err.requestOptions.extra['isRetry'] = true;

          // Retry the request with the new token using the existing Dio instance
          final cloneReq = await getIt<DioClient>().dio.fetch(err.requestOptions);
          return handler.resolve(cloneReq);
        } else {
          _handleSessionExpired();
        }
      } catch (_) {
        _handleSessionExpired();
      }
    } else {
      super.onError(err, handler);
    }
  }

  void _handleSessionExpired() {
    try {
      Supabase.instance.client.auth.signOut();
    } catch (_) {}
  }
}
