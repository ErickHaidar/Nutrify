import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:nutrify/data/sharedpref/shared_preference_helper.dart';
import 'package:nutrify/domain/entity/user/user.dart';
import 'package:nutrify/domain/repository/user/user_repository.dart';
import 'package:nutrify/domain/usecase/user/login_usecase.dart';
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

  @override
  Future<void> signInWithGoogle() async {
    // 1. Inisialisasi Google Sign In
    // PENTING: Dapatkan Client ID Web dari Google Cloud Console
    // Ikuti panduan di google_auth_keystore_guide.md
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? ''; 
    
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;
    final accessToken = googleAuth?.accessToken;
    final idToken = googleAuth?.idToken;

    if (accessToken == null || idToken == null) {
      throw Exception('Google Sign In gagal: token tidak tersedia');
    }

    // 2. Sign in ke Supabase dengan token Google
    final response = await sb.Supabase.instance.client.auth.signInWithIdToken(
      provider: sb.OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final jwt = response.session?.accessToken;
    if (jwt != null) {
      await _sharedPrefsHelper.saveAuthToken(jwt);
      await _sharedPrefsHelper.saveIsLoggedIn(true);
    }
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
