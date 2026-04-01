import 'dart:async';

import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Parallelize independent initializations
    await Future.wait([
      dotenv.load(fileName: ".env"),
      initializeDateFormatting('id_ID', null),
      setPreferredOrientations(),
    ]);

    await Supabase.initialize(
      url: Endpoints.supabaseUrl,
      anonKey: Endpoints.supabaseAnonKey,
    );

    await ServiceLocator.configureDependencies();
    runApp(MyApp());
  } catch (e, stacktrace) {
    debugPrint("Fatal Initialization Error: $e");
    debugPrint(stacktrace.toString());
    
    // Fallback UI or simple error screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SelectableText("Nutrify failed to start.\n\nError: $e"),
          ),
        ),
      ),
    ));
  }
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}
