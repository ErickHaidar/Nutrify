import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart' as auth;
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

  auth.GoogleSignIn? _googleSignIn;

  auth.GoogleSignIn _getGoogleSignIn() {
    if (_googleSignIn != null) return _googleSignIn!;

    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
    _googleSignIn = auth.GoogleSignIn(
      serverClientId: webClientId,
    );
    return _googleSignIn!;
  }

  @override
  Future<void> signInWithGoogle() async {
    print('DEBUG GOOGLE STEP 1: Memulai proses signInWithGoogle');
    try {
      // 1. Inisialisasi Google Sign In
      final auth.GoogleSignIn googleSignIn = _getGoogleSignIn();
      print('DEBUG GOOGLE STEP 2: Inisialisasi GoogleSignIn selesai');
      
      final googleUser = await googleSignIn.signIn();
      print('DEBUG GOOGLE STEP 3: Hasil signIn dialog: ${googleUser?.email}');
      
      if (googleUser == null) {
        print('DEBUG GOOGLE: User membatalkan login (googleUser is null)');
        return;
      }

      print('DEBUG GOOGLE STEP 4: Mengambil data autentikasi...');
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      print('DEBUG GOOGLE STEP 5: Token didapat. AccessToken: ${accessToken != null}, IdToken: ${idToken != null}');

      if (accessToken == null || idToken == null) {
        throw Exception('Google Sign In gagal: token tidak tersedia');
      }

      // 2. Sign in ke Supabase dengan token Google
      print('DEBUG GOOGLE STEP 6: Mengirim token ke Supabase...');
      final response = await sb.Supabase.instance.client.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final jwt = response.session?.accessToken;
      if (jwt != null) {
        await _sharedPrefsHelper.saveAuthToken(jwt);
        await _sharedPrefsHelper.saveIsLoggedIn(true);
        print('DEBUG GOOGLE STEP 7: Berhasil masuk ke Supabase');
      }
    } catch (e) {
      print('DEBUG GOOGLE ERROR DETAIL: $e');
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
      final auth.GoogleSignIn googleSignIn = _getGoogleSignIn();

      // Cek apakah user sedang login lewat Google
      if (await googleSignIn.isSignedIn()) {
        // signOut() hanya menghapus session lokal
        await googleSignIn.signOut();

        // Opsional: Gunakan disconnect() jika ingin benar-benar menghapus
        // izin aplikasi dari akun Google user (paksa login ulang total).
        // await googleSignIn.disconnect();
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
