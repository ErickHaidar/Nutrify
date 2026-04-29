import 'dart:async';
import 'dart:io';

import 'package:nutrify/core/data/local/sembast/sembast_client.dart';
import 'package:nutrify/data/local/constants/db_constants.dart';
import 'package:nutrify/data/local/datasources/post/post_datasource.dart';
import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../di/service_locator.dart';

class LocalModule {
  static Future<void> configureLocalModuleInjection() async {
    // Parallelize getting instances
    final sharedPrefs = await SharedPreferences.getInstance();
    Directory? appDocDir;
    if (!kIsWeb) {
      appDocDir = await getApplicationDocumentsDirectory();
    }

    // preference manager:------------------------------------------------------
    getIt.registerSingleton<SharedPreferences>(sharedPrefs);
    getIt.registerSingleton<SharedPreferenceHelper>(
      SharedPreferenceHelper(sharedPrefs),
    );

    // database:----------------------------------------------------------------
    final sembastClient = await SembastClient.provideDatabase(
      databaseName: DBConstants.DB_NAME,
      databasePath: kIsWeb ? "/assets/db" : appDocDir!.path,
    );
    getIt.registerSingleton<SembastClient>(sembastClient);

    // data sources:------------------------------------------------------------
    getIt.registerSingleton(PostDataSource(sembastClient));

    // image:-------------------------------------------------------------------
    getIt.registerSingleton<ImagePicker>(ImagePicker());
    getIt.registerSingleton<ImageCropper>(ImageCropper());
  }
}
