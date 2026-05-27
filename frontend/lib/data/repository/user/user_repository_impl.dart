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

  // Verify Email OTP:----------------------------------------------------------
  @override
  Future<void> verifyEmail(String email, String token) async {
    final response = await sb.Supabase.instance.client.auth.verifyOTP(
      email: email,
      token: token,
      type: sb.OtpType.signup,
    );
    final jwt = response.session?.accessToken;
    if (jwt != null) {
      await _sharedPrefsHelper.saveAuthToken(jwt);
      await _sharedPrefsHelper.saveIsLoggedIn(true);
    }
  }

  // Resend OTP:----------------------------------------------------------------
  @override
  Future<void> resendOtp(String email) async {
    await sb.Supabase.instance.client.auth.resend(
      type: sb.OtpType.signup,
      email: email,
    );
  }

  // Google Sign In (v7.x API - singleton pattern):-----------------------------
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  bool _googleSignInInitialized = false;

  @override
  Future<void> signInWithGoogle() async {
    try {
      // Initialize GoogleSignIn only once (required in v7.x, must not be called twice)
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize(
          serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
        );
        _googleSignInInitialized = true;
      }

      // authenticate() replaces the old signIn() in v7.x (throws on failure, never null)
      final googleUser = await _googleSignIn.authenticate();

      // In v7.x, authentication (idToken) and authorization (accessToken) are separate
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      // Get accessToken via authorizationClient
      final authorization = await googleUser.authorizationClient.authorizeScopes(['email']);
      final accessToken = authorization.accessToken;

      if (idToken == null) {
        throw Exception('Google Sign In gagal: idToken tidak tersedia');
      }

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
    } catch (e) {
      // ignore: avoid_print
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  // Logout:--------------------------------------------------------------------
  @override
  Future<void> logout() async {
    try {
      // 1. Logout dari Supabase (Menghapus session di server)
      await sb.Supabase.instance.client.auth.signOut();

      // 2. Logout dari Google (Menghapus cache akun di HP)
      // In v7.x, currentUser has been removed, so just call signOut directly
      try {
        await _googleSignIn.signOut();
      } catch (_) {
        // Ignore if not signed in with Google
      }

      // 3. Hapus data di Shared Preferences (Token, status login, dll)
      await _sharedPrefsHelper.clearUserData();
      await _sharedPrefsHelper.saveIsLoggedIn(false);
      //ignore: avoid_print
      // Success
    } catch (e) {
      //ignore: avoid_print
      // Error logout
      rethrow;
    }
  }

  @override
  Future<void> saveIsLoggedIn(bool value) =>
      _sharedPrefsHelper.saveIsLoggedIn(value);

  @override
  Future<bool> get isLoggedIn => _sharedPrefsHelper.isLoggedIn;
}
