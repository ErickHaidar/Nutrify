import 'package:nutrify/presentation/login/login.dart';
import 'package:nutrify/screens/main_navigation_screen.dart';
import 'package:nutrify/screens/otp_verification_screen.dart';
import 'package:nutrify/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => const MainNavigationScreen(),
    otp: (BuildContext context) => OtpVerificationScreen(
      email: ModalRoute.of(context)?.settings.arguments as String? ?? '',
    ),
    resetPassword: (BuildContext context) => const ResetPasswordScreen(),
  };
}
