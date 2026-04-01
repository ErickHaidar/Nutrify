import 'dart:async';

import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await setPreferredOrientations();

  await Supabase.initialize(
    url: Endpoints.supabaseUrl,
    anonKey: Endpoints.supabaseAnonKey,
  );

  await ServiceLocator.configureDependencies();
  runApp(MyApp());
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}
