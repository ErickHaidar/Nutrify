import 'package:nutrify/core/data/network/dio/configs/dio_configs.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:nutrify/core/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:nutrify/data/network/apis/posts/post_api.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/data/network/interceptors/error_interceptor.dart';
import 'package:nutrify/data/network/rest_client.dart';
import 'package:event_bus/event_bus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    // event bus:---------------------------------------------------------------
    getIt.registerSingleton<EventBus>(EventBus());

    // interceptors:------------------------------------------------------------
    getIt.registerSingleton<LoggingInterceptor>(LoggingInterceptor());
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    // Always read the live Supabase session token — never a stale cache.
    // This avoids 401 errors after app restart / token refresh without re-login.
    getIt.registerSingleton<AuthInterceptor>(
      AuthInterceptor(
        accessToken: () async =>
            sb.Supabase.instance.client.auth.currentSession?.accessToken,
      ),
    );

    // rest client:-------------------------------------------------------------
    getIt.registerSingleton(RestClient());

    // dio:---------------------------------------------------------------------
    getIt.registerSingleton<DioConfigs>(
      const DioConfigs(
        baseUrl: Endpoints.baseUrl,
        connectionTimeout: Endpoints.connectionTimeout,
        receiveTimeout:Endpoints.receiveTimeout,
      ),
    );
    final dioClient = DioClient(dioConfigs: getIt());
    // Required for free-tier ngrok: skip the browser warning interstitial page.
    // Without this header, every request returns HTML instead of JSON.
    dioClient.dio.options.headers['ngrok-skip-browser-warning'] = 'true';
    dioClient.addInterceptors([
      getIt<AuthInterceptor>(),
      getIt<ErrorInterceptor>(),
      getIt<LoggingInterceptor>(),
    ]);
    getIt.registerSingleton<DioClient>(dioClient);

    // api's:-------------------------------------------------------------------
    getIt.registerSingleton(PostApi(getIt<DioClient>(), getIt<RestClient>()));
  }
}
