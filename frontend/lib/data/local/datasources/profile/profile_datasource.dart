import 'package:nutrify/core/data/local/sembast/sembast_client.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:sembast/sembast.dart';

class ProfileDataSource {
  final _profileStore = stringMapStoreFactory.store('profile');
  final SembastClient _sembastClient;

  ProfileDataSource(this._sembastClient);

  Future<void> saveProfile(ApiProfileData profile) async {
    await _profileStore.record('current_profile').put(_sembastClient.database, _profileToMap(profile));
  }

  Future<ApiProfileData?> getProfile() async {
    final map = await _profileStore.record('current_profile').get(_sembastClient.database);
    if (map == null) return null;
    return _mapToProfile(map);
  }

  Future<void> deleteProfile() async {
    await _profileStore.record('current_profile').delete(_sembastClient.database);
  }

  Map<String, dynamic> _profileToMap(ApiProfileData profile) {
    return {
      'name': profile.name,
      'email': profile.email,
      'age': profile.age,
      'weight': profile.weight,
      'height': profile.height,
      'gender': profile.gender,
      'goal': profile.goal,
      'activityLevel': profile.activityLevel,
      'targetWeight': profile.targetWeight,
      'bmi': profile.bmi,
      'bmiStatus': profile.bmiStatus,
      'targetCalories': profile.targetCalories,
      'photoUrl': profile.photoUrl,
      // Macronutrients serialization could be added here if needed
    };
  }

  ApiProfileData _mapToProfile(Map<String, dynamic> map) {
    return ApiProfileData(
      name: map['name'] as String,
      email: map['email'] as String,
      age: map['age'] as int,
      weight: map['weight'] as int,
      height: map['height'] as int,
      gender: map['gender'] as String,
      goal: map['goal'] as String,
      activityLevel: map['activityLevel'] as String,
      targetWeight: map['targetWeight'] as int?,
      bmi: map['bmi'] as double,
      bmiStatus: map['bmiStatus'] as String,
      targetCalories: map['targetCalories'] as int,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}
