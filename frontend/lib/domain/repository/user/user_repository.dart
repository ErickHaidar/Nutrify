import 'dart:async';

import 'package:boilerplate/domain/usecase/user/login_usecase.dart';

import '../../entity/user/user.dart';

abstract class UserRepository {
  Future<User?> login(LoginParams params);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> forgotPassword(String email);

  Future<void> logout();

  Future<void> saveIsLoggedIn(bool value);

  Future<bool> get isLoggedIn;
}
