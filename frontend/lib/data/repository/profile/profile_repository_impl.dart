import 'dart:io';
import 'package:nutrify/data/local/datasources/profile/profile_datasource.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';
import 'package:nutrify/services/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService _profileApi;
  final ProfileDataSource _profileDataSource;

  ProfileRepositoryImpl(this._profileApi, this._profileDataSource);

  @override
  Future<ApiProfileData?> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedProfile = await _profileDataSource.getProfile();
      if (cachedProfile != null) return cachedProfile;
    }

    final remoteProfile = await _profileApi.getProfile(forceRefresh: true);
    if (remoteProfile != null) {
      await _profileDataSource.saveProfile(remoteProfile);
    }
    return remoteProfile;
  }

  @override
  Future<void> saveProfile({
    required int age,
    required int weight,
    required int height,
    required String gender,
    required String goal,
    required String activityLevel,
    int? targetWeight,
    File? photo,
  }) async {
    await _profileApi.saveProfile(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      goal: goal,
      activityLevel: activityLevel,
      targetWeight: targetWeight,
      photo: photo,
    );
    invalidateCache();
    await getProfile(forceRefresh: true);
  }

  @override
  Future<void> uploadProfilePhoto(File image) async {
    await _profileApi.uploadProfilePhoto(image);
    invalidateCache();
    await getProfile(forceRefresh: true);
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await _profileApi.updateFcmToken(token);
  }

  @override
  void invalidateCache() {
    ProfileApiService.invalidateCache();
    _profileDataSource.deleteProfile();
  }
}
