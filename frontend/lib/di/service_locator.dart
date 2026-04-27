import 'package:nutrify/data/di/data_layer_injection.dart';
import 'package:nutrify/domain/di/domain_layer_injection.dart';
import 'package:nutrify/presentation/di/presentation_layer_injection.dart';
import 'package:nutrify/services/notification_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> configureDependencies() async {
    await DataLayerInjection.configureDataLayerInjection();
    await DomainLayerInjection.configureDomainLayerInjection();
    await PresentationLayerInjection.configurePresentationLayerInjection();
    
    final notificationService = NotificationService();
    await notificationService.init();
    getIt.registerSingleton<NotificationService>(notificationService);
  }
}
