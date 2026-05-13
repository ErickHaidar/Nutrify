import 'dart:io';
import 'package:nutrify/services/profile_api_service.dart';

abstract class ProfileRepository {
  Future<ApiProfileData?> getProfile({bool forceRefresh = false});
  Future<void> saveProfile({
    required int age,
    required int weight,
    required int height,
    required String gender,
    required String goal,
    required String activityLevel,
    int? targetWeight,
    File? photo,
  });
  Future<void> uploadProfilePhoto(File image);
  Future<void> updateFcmToken(String token);
  void invalidateCache();
}
