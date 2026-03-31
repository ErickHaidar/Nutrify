import 'dart:async';

import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/constants/strings.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/presentation/home/store/language/language_store.dart';
import 'package:boilerplate/presentation/home/store/theme/theme_store.dart';
import 'package:boilerplate/presentation/login/store/login_store.dart';
import 'package:boilerplate/screens/splash_screen.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:boilerplate/utils/routes/routes.dart';
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
          locale: Locale(_languageStore.locale),
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
