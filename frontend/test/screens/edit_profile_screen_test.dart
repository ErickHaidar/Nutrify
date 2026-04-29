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
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/screens/image_preview_screen.dart';

class MockProfileApiService extends Mock implements ProfileApiService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockImageCropper extends Mock implements ImageCropper {}
class FakeCroppedFile extends Fake implements CroppedFile {
  @override
  String get path => 'test_assets/logo.png';
}

void main() {
  late MockProfileApiService mockProfileApiService;
  late MockSharedPreferences mockPrefs;
  late MockImagePicker mockImagePicker;
  late MockImageCropper mockImageCropper;

  setUp(() async {
    mockProfileApiService = MockProfileApiService();
    mockPrefs = MockSharedPreferences();
    mockImagePicker = MockImagePicker();
    mockImageCropper = MockImageCropper();

    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(File('test_assets/logo.png'));
    registerFallbackValue(const <PlatformUiSettings>[]);
    registerFallbackValue(ImageCompressFormat.jpg);
    registerFallbackValue(CropStyle.rectangle);
    registerFallbackValue(const CropAspectRatio(ratioX: 1, ratioY: 1));
    registerFallbackValue(const <CropAspectRatioPreset>[]);

    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    
    when(() => mockImagePicker.pickImage(source: any(named: 'source')))
        .thenAnswer((_) async => XFile('test_assets/logo.png'));
    
    when(() => mockImageCropper.cropImage(
      sourcePath: any(named: 'sourcePath'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      compressFormat: any(named: 'compressFormat'),
      compressQuality: any(named: 'compressQuality'),
      uiSettings: any(named: 'uiSettings'),
    )).thenAnswer((_) async => FakeCroppedFile());

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<ProfileApiService>(mockProfileApiService);
    GetIt.instance.registerSingleton<SharedPreferences>(mockPrefs);
    GetIt.instance.registerSingleton<ImagePicker>(mockImagePicker);
    GetIt.instance.registerSingleton<ImageCropper>(mockImageCropper);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('EditProfileScreen picks image, crops it, and uploads on save', (WidgetTester tester) async {
    // Arrange
    when(() => mockProfileApiService.getProfile()).thenAnswer((_) async => ApiProfileData(
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

    when(() => mockProfileApiService.saveProfile(
      age: any(named: 'age'),
      weight: any(named: 'weight'),
      height: any(named: 'height'),
      gender: any(named: 'gender'),
      goal: any(named: 'goal'),
      activityLevel: any(named: 'activityLevel'),
    )).thenAnswer((_) async { await Future.delayed(const Duration(milliseconds: 100)); return; });

    when(() => mockProfileApiService.uploadProfilePhoto(any())).thenAnswer((_) async { await Future.delayed(const Duration(milliseconds: 100)); return; });

    // Act - Pump Widget
    await tester.pumpWidget(const MaterialApp(
      home: EditProfileScreen(),
    ));
    await tester.pumpAndSettle();

    // Verify initial state loaded
    expect(find.text('175'), findsOneWidget); // Height
    expect(find.text('70'), findsOneWidget);  // Weight

    // Tap on image placeholder to pick image
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    // Tap on Gallery
    await tester.tap(find.text(AppStrings.openGallery));
    await tester.pumpAndSettle();

    // Verify ImagePicker was called
    verify(() => mockImagePicker.pickImage(source: any(named: 'source'))).called(1);
    
    // Verify ImagePreviewScreen is pushed
    expect(find.byType(ImagePreviewScreen), findsOneWidget);
    expect(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'), findsOneWidget);
    
    // Tap Gunakan Foto to return to EditProfileScreen
    await tester.tap(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'));
    await tester.pumpAndSettle();

    // Now change weight to trigger _hasChanges = true so the Save button is enabled
    await tester.enterText(find.byType(TextField).at(1), '75');
    await tester.pumpAndSettle();

    // Tap Save Changes
    final saveButton = find.text(AppStrings.saveChanges);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    
    // Pump to start loading
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Finish loading
    await tester.pumpAndSettle();

    // Assert API calls
    verify(() => mockProfileApiService.saveProfile(
      age: 25,
      weight: 75,
      height: 175,
      gender: 'male',
      goal: 'maintenance',
      activityLevel: 'active',
    )).called(1);
    verify(() => mockProfileApiService.uploadProfilePhoto(any())).called(1);
  });
}
