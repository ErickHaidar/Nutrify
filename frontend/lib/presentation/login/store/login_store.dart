import 'package:nutrify/core/stores/error/error_store.dart';
import 'package:nutrify/core/stores/form/form_store.dart';
import 'package:nutrify/domain/repository/user/user_repository.dart';
import 'package:nutrify/domain/usecase/user/is_logged_in_usecase.dart';
import 'package:nutrify/domain/usecase/user/save_login_in_status_usecase.dart';
import 'package:mobx/mobx.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:nutrify/di/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entity/user/user.dart';
import '../../../domain/usecase/user/login_usecase.dart';
import '../../../../services/profile_api_service.dart';
import '../../post/store/post_store.dart';

part 'login_store.g.dart';

class UserStore = _UserStore with _$UserStore;

abstract class _UserStore with Store {
  _UserStore(
    this._isLoggedInUseCase,
    this._saveLoginStatusUseCase,
    this._loginUseCase,
    this._userRepository,
    this.formErrorStore,
    this.errorStore,
  ) {
    _setupDisposers();
    _isLoggedInUseCase.call(params: null).then((value) async {
      isLoggedIn = value;
    });
  }

  final IsLoggedInUseCase _isLoggedInUseCase;
  final SaveLoginStatusUseCase _saveLoginStatusUseCase;
  final LoginUseCase _loginUseCase;
  final UserRepository _userRepository;
  final FormErrorStore formErrorStore;
  final ErrorStore errorStore;

  late List<ReactionDisposer> _disposers;

  void _setupDisposers() {
    _disposers = [
      reaction((_) => success, (_) => success = false, delay: 200),
      reaction(
        (_) => registerSuccess,
        (_) => registerSuccess = false,
        delay: 200,
      ),
    ];
  }

  static ObservableFuture<User?> emptyLoginResponse = ObservableFuture.value(
    null,
  );

  @observable
  bool isLoggedIn = false;

  @observable
  bool success = false;

  @observable
  bool registerSuccess = false;

  @observable
  bool passwordResetSuccess = false;

  @observable
  bool isRegisterLoading = false;

  @observable
  bool isForgotPasswordLoading = false;

  @observable
  ObservableFuture<User?> loginFuture = emptyLoginResponse;

  @computed
  bool get isLoading => loginFuture.status == FutureStatus.pending;

  // Login:--------------------------------------------------------------------
  @action
  Future<void> login(String email, String password) async {
    errorStore.errorMessage = '';
    loginFuture = ObservableFuture(
      _loginUseCase.call(
        params: LoginParams(username: email, password: password),
      ),
    );

    await loginFuture
        .then((value) async {
          await _saveLoginStatusUseCase.call(params: true);
          isLoggedIn = true;
          success = true;
        })
        .catchError((e) {
          final prefs = getIt<SharedPreferences>();
    prefs.remove('profile_image');
    isLoggedIn = false;
          success = false;
          errorStore.errorMessage = _parseAuthError(e);
          throw e;
        });
  }

  @action
  Future<void> signInWithGoogle() async {
    errorStore.errorMessage = '';
    isRegisterLoading = true; // Use loading state
    try {
      await _userRepository.signInWithGoogle();
      isLoggedIn = true;
      success = true;
    } catch (e) {
      final prefs = getIt<SharedPreferences>();
      prefs.remove('profile_image');
      isLoggedIn = false;
      success = false;

      // Bug 11 fix: handle provider mismatch error
      if (e is sb.AuthException) {
        final msg = e.message.toLowerCase();
        if (msg.contains('email already in use') ||
            msg.contains('already registered') ||
            msg.contains('user already registered') ||
            msg.contains('identity already exists') ||
            msg.contains('email_address_not_authorized')) {
          errorStore.errorMessage = 'Email ini sudah terdaftar menggunakan email dan password. Silakan login menggunakan email dan password.';
          return; // Don't rethrow - we handled it
        }
        if (msg.contains('invalid login credentials') ||
            msg.contains('invalid_credentials')) {
          errorStore.errorMessage = 'Gagal login. Coba gunakan email dan password.';
          return;
        }
      }

      errorStore.errorMessage = _parseAuthError(e);
      rethrow;
    } finally {
      isRegisterLoading = false;
    }
  }

  // Register:-----------------------------------------------------------------
  @action
  Future<void> register(String name, String email, String password) async {
    isRegisterLoading = true;
    try {
      await _userRepository.register(
        name: name,
        email: email,
        password: password,
      );
      registerSuccess = true;
    } catch (e) {
      // Do NOT write to errorStore — the sign-up modal shows inline errors.
      // Writing here triggers the login-page Observer and shows a duplicate
      // red flushbar which is confusing.
      rethrow;
    } finally {
      isRegisterLoading = false;
    }
  }

  // Forgot Password:----------------------------------------------------------
  @action
  Future<void> forgotPassword(String email) async {
    isForgotPasswordLoading = true;
    try {
      await _userRepository.forgotPassword(email);
      passwordResetSuccess = true;
    } catch (e) {
      // Do NOT write to errorStore — the dialog catch handles this directly.
      rethrow;
    } finally {
      isForgotPasswordLoading = false;
    }
  }

  // Verify Email OTP:----------------------------------------------------------
  @action
  Future<void> verifyEmail(String email, String token) async {
    await _userRepository.verifyEmail(email, token);
    await _saveLoginStatusUseCase.call(params: true);
    isLoggedIn = true;
    success = true;
  }

  // Resend OTP:----------------------------------------------------------------
  @action
  Future<void> resendOtp(String email) async {
    await _userRepository.resendOtp(email);
  }

  // Logout:-------------------------------------------------------------------
  @action
  Future<void> logout() async {
    await _userRepository.logout();
    await _saveLoginStatusUseCase.call(params: false);
    ProfileApiService.invalidateCache(); // Invalidate cache on logout
    getIt<PostStore>().reset(); // Reset post store on logout
    final prefs = getIt<SharedPreferences>();
    prefs.remove('profile_image');
    isLoggedIn = false;
  }

  // Clear session (called when Supabase fires signedOut event externally):----
  @action
  void clearSession() {
    ProfileApiService.invalidateCache(); // Invalidate cache on clear session
    getIt<PostStore>().reset(); // Reset post store on clear session
    final prefs = getIt<SharedPreferences>();
    prefs.remove('profile_image');
    isLoggedIn = false;
  }

  // Error helper:-------------------------------------------------------------
  String _parseAuthError(dynamic e) {
    if (e is sb.AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid_credentials')) {
        return 'Email atau password salah. Jika akun Anda terdaftar via Google, gunakan tombol "Masuk dengan Google".';
      }
      if (msg.contains('email not confirmed')) {
        return 'Cek email Anda untuk konfirmasi akun terlebih dahulu';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered') ||
          msg.contains('identity already exists')) {
        return 'Email sudah terdaftar. Jika menggunakan Google, gunakan tombol "Masuk dengan Google".';
      }
      if (msg.contains('password should be at least') ||
          msg.contains('weak_password')) {
        return 'Password minimal 6 karakter';
      }
      if (msg.contains('unable to validate email')) {
        return 'Format email tidak valid';
      }
      if (msg.contains('rate limit')) {
        return 'Terlalu banyak percobaan. Tunggu sebentar.';
      }
      return e.message.isNotEmpty ? e.message : 'Terjadi kesalahan autentikasi';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
