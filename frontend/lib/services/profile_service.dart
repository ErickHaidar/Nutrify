import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileData {
  final String name;
  final String email;
  final String height;
  final String weight;
  final String targetWeight;
  final String age;
  final String gender;
  final String activityLevel;
  final String mainGoal;
  final String weeklyTarget;
  final double weightIncrement;
  final String? photoPath;

  ProfileData({
    this.name = 'Zayn Malik',
    this.email = 'Zaynmalik@nutrify.app',
    this.height = '175',
    this.weight = '70',
    this.targetWeight = '70',
    this.age = '25',
    this.gender = 'Laki-Laki',
    this.activityLevel = 'Moderately Active',
    this.mainGoal = 'Maintain',
    this.weeklyTarget = 'Balance',
    this.weightIncrement = 0.5,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'height': height,
        'weight': weight,
        'targetWeight': targetWeight,
        'age': age,
        'gender': gender,
        'activityLevel': activityLevel,
        'mainGoal': mainGoal,
        'weeklyTarget': weeklyTarget,
        'weightIncrement': weightIncrement,
        'photoPath': photoPath,
      };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
        name: json['name'] ?? 'Zayn Malik',
        email: json['email'] ?? 'Zaynmalik@nutrify.app',
        height: json['height'] ?? '175',
        weight: json['weight'] ?? '70',
        targetWeight: json['targetWeight'] ?? '70',
        age: json['age'] ?? '25',
        gender: json['gender'] ?? 'Laki-Laki',
        activityLevel: json['activityLevel'] ?? 'Moderately Active',
        mainGoal: json['mainGoal'] ?? 'Maintain',
        weeklyTarget: json['weeklyTarget'] ?? 'Balance',
        weightIncrement: (json['weightIncrement'] ?? 0.5).toDouble(),
        photoPath: json['photoPath'],
      );

  int calculateTargetCalories() {
    double w = double.tryParse(weight) ?? 70;
    double h = double.tryParse(height) ?? 175;
    int a = int.tryParse(age) ?? 25;

    double bmr;
    if (gender == 'Laki-Laki') {
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
    } else {
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
    }

    double activityMultiplier;
    switch (activityLevel) {
      case 'Lightly Active':
        activityMultiplier = 1.375;
        break;
      case 'Moderately Active':
        activityMultiplier = 1.55;
        break;
      case 'Highly Active':
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }

    double tdee = bmr * activityMultiplier;

    if (mainGoal == 'Cutting') {
      return (tdee - 500).round();
    } else if (mainGoal == 'Bulking') {
      return (tdee + 500).round();
    } else {
      return tdee.round();
    }
  }
}

class ProfileService {
  static const String _key = 'user_profile';

  Future<void> saveProfile(ProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  Future<ProfileData> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return ProfileData();
    return ProfileData.fromJson(jsonDecode(data));
  }
}
