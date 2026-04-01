import 'package:nutrify/data/di/module/local_module.dart';
import 'package:nutrify/data/di/module/network_module.dart';
import 'package:nutrify/data/di/module/repository_module.dart';

class DataLayerInjection {
  static Future<void> configureDataLayerInjection() async {
    await Future.wait([
      LocalModule.configureLocalModuleInjection(),
      NetworkModule.configureNetworkModuleInjection(),
    ]);
    await RepositoryModule.configureRepositoryModuleInjection();
  }
}
