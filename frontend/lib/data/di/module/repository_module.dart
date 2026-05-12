import 'dart:async';

import 'package:nutrify/data/local/datasources/post/post_datasource.dart';
import 'package:nutrify/data/network/apis/posts/post_api.dart';
import 'package:nutrify/data/local/datasources/profile/profile_datasource.dart';
import 'package:nutrify/data/repository/post/post_repository_impl.dart';
import 'package:nutrify/data/repository/profile/profile_repository_impl.dart';
import 'package:nutrify/data/repository/setting/setting_repository_impl.dart';
import 'package:nutrify/data/repository/user/user_repository_impl.dart';
import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:nutrify/data/local/datasources/food_log/food_log_datasource.dart';
import 'package:nutrify/data/repository/food_log/food_log_repository_impl.dart';
import 'package:nutrify/domain/repository/food_log/food_log_repository.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';
import 'package:nutrify/domain/repository/post/post_repository.dart';
import 'package:nutrify/domain/repository/setting/setting_repository.dart';
import 'package:nutrify/domain/repository/user/user_repository.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/services/food_log_api_service.dart';

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

    getIt.registerSingleton<ProfileRepository>(ProfileRepositoryImpl(
      getIt<ProfileApiService>(),
      getIt<ProfileDataSource>(),
    ));

    getIt.registerSingleton<FoodLogRepository>(FoodLogRepositoryImpl(
      getIt<FoodLogApiService>(),
      getIt<FoodLogDataSource>(),
    ));
  }
}
