import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/screens/edit_profile_screen.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:nutrify/domain/repository/profile/profile_repository.dart';
import 'package:nutrify/services/profile_api_service.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockImageCropper extends Mock implements ImageCropper {}

class FakeFile extends Fake implements File {}

/// Pumps widget and drains all async microtasks without risking infinite-loop timeout.
Future<void> pumpUntilSettled(WidgetTester tester, {int maxPumps = 30}) async {
  for (int i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  late MockProfileRepository mockProfileRepository;
  late MockSharedPreferences mockPrefs;
  late MockImagePicker mockImagePicker;
  late MockImageCropper mockImageCropper;

  setUp(() async {
    mockProfileRepository = MockProfileRepository();
    mockPrefs = MockSharedPreferences();
    mockImagePicker = MockImagePicker();
    mockImageCropper = MockImageCropper();

    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<ProfileRepository>(mockProfileRepository);
    GetIt.instance.registerSingleton<SharedPreferences>(mockPrefs);
    GetIt.instance.registerSingleton<ImagePicker>(mockImagePicker);
    GetIt.instance.registerSingleton<ImageCropper>(mockImageCropper);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('EditProfileScreen loads and displays profile data', (WidgetTester tester) async {
    // Arrange
    when(() => mockProfileRepository.getProfile(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => ApiProfileData(
      name: 'Test User',
      email: 'test@user.com',
      age: 25,
      weight: 70,
      height: 175,
      gender: 'male',
      goal: 'maintenance',
      activityLevel: 'active',
      bmi: 22.8,
      bmiStatus: 'Normal',
      targetCalories: 2500,
    ));

    // Act - Pump Widget
    await tester.pumpWidget(const MaterialApp(
      home: EditProfileScreen(),
    ));
    await pumpUntilSettled(tester);

    // Assert - profile data is loaded and displayed
    expect(find.text('175'), findsOneWidget); // Height
    expect(find.text('70'), findsOneWidget);  // Weight
  });

  testWidgets('EditProfileScreen shows save button and triggers save on tap', (WidgetTester tester) async {
    // Arrange
    when(() => mockProfileRepository.getProfile(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => ApiProfileData(
      name: 'Test User',
      email: 'test@user.com',
      age: 25,
      weight: 70,
      height: 175,
      gender: 'male',
      goal: 'maintenance',
      activityLevel: 'active',
      bmi: 22.8,
      bmiStatus: 'Normal',
      targetCalories: 2500,
    ));

    when(() => mockProfileRepository.saveProfile(
      age: any(named: 'age'),
      weight: any(named: 'weight'),
      height: any(named: 'height'),
      gender: any(named: 'gender'),
      goal: any(named: 'goal'),
      activityLevel: any(named: 'activityLevel'),
    )).thenAnswer((_) async { await Future.delayed(const Duration(milliseconds: 100)); return; });

    when(() => mockProfileRepository.uploadProfilePhoto(any()))
        .thenAnswer((_) async { await Future.delayed(const Duration(milliseconds: 100)); return; });

    // Act - Pump Widget
    await tester.pumpWidget(const MaterialApp(
      home: EditProfileScreen(),
    ));
    await pumpUntilSettled(tester);

    // Change weight to enable the Save button
    await tester.enterText(find.byType(TextField).at(1), '75');
    await pumpUntilSettled(tester);

    // Tap Save Changes
    final saveButton = find.text(AppStrings.saveChanges);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);

    // Pump to start loading
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Finish loading
    await pumpUntilSettled(tester);

    // Assert API was called
    verify(() => mockProfileRepository.saveProfile(
      age: 25,
      weight: 75,
      height: 175,
      gender: 'male',
      goal: 'maintenance',
      activityLevel: 'active',
    )).called(1);
  });
}
