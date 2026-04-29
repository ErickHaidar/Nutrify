import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/screens/add_post_screen.dart';
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

    when(() => mockPrefs.getString(any())).thenReturn(null);
    
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

  testWidgets('AddPostScreen picks image and crops it', (WidgetTester tester) async {
    // Act - Pump Widget
    await tester.pumpWidget(const MaterialApp(
      home: AddPostScreen(),
    ));
    await tester.pumpAndSettle();

    // Tap on image picker area
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    // Verify ImagePicker was called
    verify(() => mockImagePicker.pickImage(source: any(named: 'source'))).called(1);
    
    // Verify ImagePreviewScreen is pushed
    expect(find.byType(ImagePreviewScreen), findsOneWidget);
    
    // Tap Use Photo to return
    await tester.tap(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'));
    await tester.pumpAndSettle();
  });
}
