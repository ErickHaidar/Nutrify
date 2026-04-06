import 'dart:async';

import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/my_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Pastikan binding diinisialisasi di paling atas
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    try {
      debugPrint('Step 1: Loading environment variables...');
      // HARUS await secara mandiri, jangan digabung Future.wait agar variabel tersedia bagi yang lain
      await dotenv.load(fileName: ".env");

      debugPrint('Step 2: Initializing Supabase...');
      // Gunakan nilai langsung dari dotenv untuk memastikan akurasi
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception("Supabase URL or Anon Key is missing in .env file");
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );

      debugPrint('Step 3: Initializing local resources & dependencies...');
      // Fungsi-fungsi yang tidak saling bergantung bisa dijalankan bersamaan
      await Future.wait([
        initializeDateFormatting('id_ID', null),
        setPreferredOrientations(),
        ServiceLocator.configureDependencies(),
      ]);

      debugPrint('Step 4: Running MyApp...');
      runApp(MyApp()); // Hapus 'const' jika constructor MyApp tidak mendukungnya

    } catch (e, stacktrace) {
      debugPrint('FATAL ERROR: $e');
      debugPrint('STACKTRACE: $stacktrace');
      
      runApp(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text("Nutrify failed to start.\n\nError: $e", textAlign: TextAlign.center),
            ),
          ),
        ),
      ));
    }
  }, (error, stack) {
    debugPrint('Global Zoned Error: $error');
  });
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}