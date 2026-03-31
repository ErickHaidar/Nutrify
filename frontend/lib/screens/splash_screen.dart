import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // Minimum splash display time for branding
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      // Valid session — persist the latest token for Dio's AuthInterceptor
      await getIt<SharedPreferenceHelper>().saveAuthToken(session.accessToken);
      await getIt<SharedPreferenceHelper>().saveIsLoggedIn(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(Routes.home);
    } else {
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
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: NutrifyTheme.accentOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your calories. Transform your life.',
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
