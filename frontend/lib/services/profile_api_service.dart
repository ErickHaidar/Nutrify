import 'dart:io';
import 'package:dio/dio.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class ApiProfileData {
  final String name;
  final String email;
  final int age;
  final int weight;
  final int height;
  final String gender; // 'male' | 'female'
  final String goal; // 'cutting' | 'maintenance' | 'bulking'
  final String
  activityLevel; // 'sedentary'|'light'|'moderate'|'active'|'very_active'
  final int? targetWeight; // Target berat badan
  final double bmi;
  final String bmiStatus;
  final int targetCalories;

  ApiProfileData({
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.activityLevel,
    this.targetWeight,
    required this.bmi,
    required this.bmiStatus,
    required this.targetCalories,
  });

  String get genderDisplay => gender == 'male' ? 'Laki-Laki' : 'Perempuan';
}

class ProfileApiService {
  DioClient get _dio => getIt<DioClient>();

  // -------------------------------------------------------------------
  // Static in-memory cache — shared across all ProfileApiService instances.
  // Concurrent calls are deduplicated: only 1 HTTP request is in-flight.
  // Cache is valid for 60 s, or until invalidateCache() is called.
  // -------------------------------------------------------------------
  static ApiProfileData? _cache;
  static DateTime? _cacheTime;
  static Future<ApiProfileData?>? _ongoingFetch;
  static const int _cacheTtlSeconds = 60;

  /// Returns profile data from cache when fresh; otherwise fetches once.
  /// Multiple simultaneous callers share the same in-flight Future.
  Future<ApiProfileData?> getProfile({bool forceRefresh = false}) {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cache != null &&
        _cacheTime != null &&
        now.difference(_cacheTime!).inSeconds < _cacheTtlSeconds) {
      return Future.value(_cache);
    }
    _ongoingFetch ??= _doFetch().whenComplete(() => _ongoingFetch = null);
    return _ongoingFetch!;
  }

  Future<ApiProfileData?> _doFetch() async {
    try {
      final res = await _dio.dio.get(Endpoints.profile);
      final data = res.data as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      if (profile == null) {
        _cache = null;
        return null;
      }
      final email = sb.Supabase.instance.client.auth.currentUser?.email ?? '';
      _cache = ApiProfileData(
        name: (data['user'] as String? ?? '').isEmpty ? (email.split('@')[0]) : data['user'] as String,
        email: email,
        age: (profile['age'] as num?)?.toInt() ?? 0,
        weight: (profile['weight'] as num?)?.toInt() ?? 0,
        height: (profile['height'] as num?)?.toInt() ?? 0,
        gender: profile['gender'] as String? ?? 'male',
        goal: profile['goal'] as String? ?? 'maintenance',
        activityLevel: profile['activity_level'] as String? ?? 'sedentary',
        targetWeight: (profile['target_weight'] as num?)?.toInt(), // Nullable!
        bmi: (data['bmi'] as num?)?.toDouble() ?? 0,
        bmiStatus: data['bmi_status'] as String? ?? '',
        targetCalories: (data['target_calories'] as num?)?.toInt() ?? 0,
      );
      _cacheTime = DateTime.now();
      return _cache;
    } catch (e) {
      // Return a basic profile with the user's email if the backend profile is not found.
      final user = sb.Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final email = user.email ?? '';
        final name = user.userMetadata?['full_name'] as String? ?? 
                     user.userMetadata?['name'] as String? ?? 
                     (user.email?.split('@')[0] ?? '-');
        
        _cache = ApiProfileData(
          name: name,
          email: email,
          age: 0,
          weight: 0,
          height: 0,
          gender: 'male',
          goal: 'maintenance',
          activityLevel: 'sedentary',
          bmi: 0,
          bmiStatus: '-',
          targetCalories: 0,
        );
        _cacheTime = DateTime.now();
        return _cache;
      }
      _cache = null;
      _cacheTime = null;
      return null;
    }
  }

  /// Clears cache so the next getProfile() fetches fresh data from the API.
  static void invalidateCache() {
    _cache = null;
    _cacheTime = null;
    _ongoingFetch = null;
  }

Future<void> uploadProfilePhoto(File image) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    await _dio.dio.post( 
      Endpoints.profilePhoto,
      data: formData,
    );
  }
  Future<void> saveProfile({
    required int age,
    required int weight,
    required int height,
    required String gender,
    required String goal,
    required String activityLevel,
    int? targetWeight, // Target berat badan (opsional)
    File? photo,
  }) async {
    // Jika ada foto, gunakan multipart/form-data
    if (photo != null) {
      final fileName = photo.path.split('/').last;
      final formData = FormData.fromMap({
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'goal': goal,
        'activity_level': activityLevel,
        'target_weight': targetWeight, // Kirim target weight
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
      });

      await _dio.dio.post(
        Endpoints.storeProfile,
        data: formData,
      );
    } else {
      // Jika tidak ada foto, gunakan JSON biasa
      final data = {
        'age': age,
        'weight': weight,
        'height': height,
        'gender': gender,
        'goal': goal,
        'activity_level': activityLevel,
      };

      // Tambah target_weight jika ada
      if (targetWeight != null) {
        data['target_weight'] = targetWeight;
      }

      await _dio.dio.post(
        Endpoints.storeProfile,
        data: data,
      );
    }

    // Invalidate so next read reflects the saved changes.
    invalidateCache();
  }

  Future<void> updateFcmToken(String token) async {
    final userId = sb.Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await _dio.dio.post(
      Endpoints.profile, // Assuming profile endpoint handles token update or use a specific one
      data: {'fcm_token': token},
    );
  }
}
