import 'dart:async';

import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/repository/user/user_repository.dart';
import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class UserRepositoryImpl extends UserRepository {
  final SharedPreferenceHelper _sharedPrefsHelper;

  UserRepositoryImpl(this._sharedPrefsHelper);

  // Login:---------------------------------------------------------------------
  @override
  Future<User?> login(LoginParams params) async {
    final response = await sb.Supabase.instance.client.auth.signInWithPassword(
      email: params.username,
      password: params.password,
    );

    final jwt = response.session?.accessToken;
    if (jwt == null) throw Exception('Login gagal: session tidak tersedia');

    await _sharedPrefsHelper.saveAuthToken(jwt);
    await _sharedPrefsHelper.saveIsLoggedIn(true);
    return User();
  }

  // Register:------------------------------------------------------------------
  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await sb.Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  // Forgot Password:-----------------------------------------------------------
  @override
  Future<void> forgotPassword(String email) async {
    await sb.Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'nutrify://reset-password-callback',
    );
  }

  // Logout:--------------------------------------------------------------------
  @override
  Future<void> logout() async {
    await sb.Supabase.instance.client.auth.signOut();
    await _sharedPrefsHelper.removeAuthToken();
    await _sharedPrefsHelper.saveIsLoggedIn(false);
  }

  @override
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  @override
  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;
}
