import 'package:boilerplate/presentation/login/login.dart';
import 'package:boilerplate/screens/main_navigation_screen.dart';
import 'package:boilerplate/screens/reset_password_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String resetPassword = '/reset-password';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    home: (BuildContext context) => const MainNavigationScreen(),
    resetPassword: (BuildContext context) => const ResetPasswordScreen(),
  };
}
