import 'dart:async';

import 'package:nutrify/constants/app_theme.dart';
import 'package:nutrify/constants/strings.dart';
import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:nutrify/presentation/home/store/language/language_store.dart';
import 'package:nutrify/presentation/home/store/theme/theme_store.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/screens/splash_screen.dart';
import 'package:nutrify/utils/locale/app_localization.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../di/service_locator.dart';

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();
  final UserStore _userStore = getIt<UserStore>();
  final SharedPreferenceHelper _prefs = getIt<SharedPreferenceHelper>();

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
        data,
      ) {
        if (data.event == AuthChangeEvent.signedOut) {
          // Session habis atau user di-sign-out dari luar
          _userStore.clearSession();
          _prefs.removeAuthToken();
          _prefs.saveIsLoggedIn(false);
          MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.login,
            (route) => false,
          );
        } else if (data.event == AuthChangeEvent.signedIn) {
          final user = data.session?.user;
          // Skip auto-navigate jika email belum dikonfirmasi (registration + OTP flow).
          // login.dart akan navigate ke OTP screen untuk verifikasi.
          if (user != null && user.emailConfirmedAt == null) {
            return;
          }
          final newToken = data.session?.accessToken;
          if (newToken != null) {
            _prefs.saveAuthToken(newToken);
          }
          _prefs.saveIsLoggedIn(true);
          MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.home,
            (route) => false,
          );
        } else if (data.event == AuthChangeEvent.tokenRefreshed) {
          // Supabase auto-refresh token — simpan token baru ke SharedPrefs
          // supaya Dio AuthInterceptor selalu gunakan token terbaru
          final newToken = data.session?.accessToken;
          if (newToken != null) {
            _prefs.saveAuthToken(newToken);
          }
        } else if (data.event == AuthChangeEvent.passwordRecovery) {
          // User membuka link reset password dari email — arahkan ke layar
          // ganti password.
          MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.resetPassword,
            (route) => false,
          );
        }
      });
    } catch (e) {
      // Error subscribing to auth changes
      // Initialize an empty dummy subscription to avoid late initialization error in dispose()
      _authSubscription = const Stream<AuthState>.empty().listen((_) {});
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: Strings.appName,
          navigatorKey: MyApp.navigatorKey,
          theme: _themeStore.darkMode
              ? AppThemeData.darkThemeData
              : AppThemeData.lightThemeData,
          routes: Routes.routes,
          locale: Locale(_languageStore.locale.isEmpty ? 'id' : _languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
          builder: (context, child) {
            return Container(
              color: const Color(0xFF2D2A4A), // Deep blue background for the deadzone
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: child!,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
