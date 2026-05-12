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
import 'package:nutrify/services/community_post_api_service.dart';
class MockProfileApiService extends Mock implements ProfileApiService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockImagePicker extends Mock implements ImagePicker {}
class MockImageCropper extends Mock implements ImageCropper {}
class MockCommunityPostApiService extends Mock implements CommunityPostApiService {}
class FakeCroppedFile extends Fake implements CroppedFile {
  @override
  String get path => 'test_assets/logo.png';
}

/// Pumps widget and drains all async microtasks without risking infinite-loop timeout.
Future<void> pumpUntilSettled(WidgetTester tester, {int maxPumps = 20}) async {
  for (int i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) break;
  }
}

void main() {
  late MockProfileApiService mockProfileApiService;
  late MockSharedPreferences mockPrefs;
  late MockImagePicker mockImagePicker;
  late MockImageCropper mockImageCropper;
  late MockCommunityPostApiService mockCommunityPostApiService;

  setUpAll(() {
    // No google_fonts workarounds needed — AddPostScreen now uses const TextStyle
    // for the AppBar title instead of GoogleFonts.montserrat().
  });

  setUp(() async {
    mockProfileApiService = MockProfileApiService();
    mockPrefs = MockSharedPreferences();
    mockImagePicker = MockImagePicker();
    mockImageCropper = MockImageCropper();
    mockCommunityPostApiService = MockCommunityPostApiService();

    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(File('test_assets/logo.png'));
    registerFallbackValue(const <PlatformUiSettings>[]);
    registerFallbackValue(ImageCompressFormat.jpg);

    when(() => mockPrefs.getString(any())).thenReturn(null);
    
    when(() => mockImagePicker.pickImage(
      source: any(named: 'source'),
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    )).thenAnswer((_) async => XFile('test_assets/logo.png'));
    
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
    GetIt.instance.registerSingleton<CommunityPostApiService>(mockCommunityPostApiService);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('AddPostScreen picks image and crops it', (WidgetTester tester) async {
    // Act - Pump Widget
    await tester.pumpWidget(const MaterialApp(
      home: AddPostScreen(),
    ));
    await pumpUntilSettled(tester);

    // Tap on image picker area (opens BottomSheet)
    await tester.tap(find.byIcon(Icons.camera_alt));
    await pumpUntilSettled(tester);

    // BottomSheet is now open — tap "Gallery" option
    // Dismisses sheet, then _pickImage calls pickImage async (mock resolves via microtask)
    await tester.tap(find.text(AppStrings.gallery));
    // Allow async pickImage mock + Navigator.push to complete
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    // Multiple pumps to process: BottomSheet dismiss -> pickImage -> navigation
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ImagePicker was called with gallery source
    verify(() => mockImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: any(named: 'maxWidth'),
      maxHeight: any(named: 'maxHeight'),
      imageQuality: any(named: 'imageQuality'),
    )).called(1);
    
    // Verify ImagePreviewScreen is pushed (navigation completed)
    expect(find.byType(ImagePreviewScreen), findsOneWidget);
  });
}
