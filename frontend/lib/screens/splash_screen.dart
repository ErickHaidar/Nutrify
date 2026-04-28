import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/presentation/login/store/login_store.dart';
import 'package:nutrify/utils/routes/routes.dart';
import 'package:nutrify/constants/colors.dart';
import 'package:nutrify/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Branding delay: gives Supabase time to recover session from storage
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    final userStore = getIt<UserStore>();

    if (session != null) {
      // Valid session — ensure local state is synced
      await getIt<SharedPreferenceHelper>().saveAuthToken(session.accessToken);
      await getIt<SharedPreferenceHelper>().saveIsLoggedIn(true);
      userStore.isLoggedIn = true;
      
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
      // No session — ensure local state is cleared
      await getIt<SharedPreferenceHelper>().saveIsLoggedIn(false);
      userStore.isLoggedIn = false;

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NutrifyTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.nutrifyLogo,
              width: 100,
              height: 100,
              errorBuilder: (_, __, ___) => Icon(
                Icons.pie_chart_outline,
                color: NutrifyTheme.accentOrange,
                size: 80,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nutrify',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFB26B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.splashSubtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: NutrifyTheme.accentOrange,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
