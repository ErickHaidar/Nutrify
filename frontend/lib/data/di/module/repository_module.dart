import 'dart:async';

import 'package:nutrify/data/local/datasources/post/post_datasource.dart';
import 'package:nutrify/data/network/apis/posts/post_api.dart';
import 'package:nutrify/data/repository/post/post_repository_impl.dart';
import 'package:nutrify/data/repository/setting/setting_repository_impl.dart';
import 'package:nutrify/data/repository/user/user_repository_impl.dart';
import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:nutrify/domain/repository/post/post_repository.dart';
import 'package:nutrify/domain/repository/setting/setting_repository.dart';
import 'package:nutrify/domain/repository/user/user_repository.dart';

import '../../../di/service_locator.dart';

class RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    // repository:--------------------------------------------------------------
    getIt.registerSingleton<SettingRepository>(SettingRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<UserRepository>(UserRepositoryImpl(
      getIt<SharedPreferenceHelper>(),
    ));

    getIt.registerSingleton<PostRepository>(PostRepositoryImpl(
      getIt<PostApi>(),
      getIt<PostDataSource>(),
    ));
  }
}
