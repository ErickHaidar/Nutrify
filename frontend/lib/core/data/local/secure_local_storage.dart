import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage _secureStorage;

  SecureLocalStorage() : _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false,
      storageNamespace: 'nutrify_secure_prefs',
      preferencesKeyPrefix: 'nutrify_secure_',
      resetOnError: true,
    ),
  );

  @override
  Future<void> initialize() async {
    // Initialization, if required
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    try {
      await _secureStorage
          .write(key: supabasePersistSessionKey, value: persistSessionString)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SecureLocalStorage persistSession error: $e');
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    try {
      return await _secureStorage
          .containsKey(key: supabasePersistSessionKey)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SecureLocalStorage hasAccessToken error: $e');
      return false;
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      return await _secureStorage
          .read(key: supabasePersistSessionKey)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SecureLocalStorage accessToken error: $e');
      return null;
    }
  }

  @override
  Future<void> removePersistedSession() async {
    try {
      await _secureStorage
          .delete(key: supabasePersistSessionKey)
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SecureLocalStorage removePersistedSession error: $e');
    }
  }
}
