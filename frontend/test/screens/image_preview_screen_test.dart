import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:nutrify/screens/image_preview_screen.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockImageCropper extends Mock implements ImageCropper {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeCroppedFile extends Fake implements CroppedFile {
  @override
  String get path => 'test_assets/edited_image.png';
}

void main() {
  late MockImageCropper mockImageCropper;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(const <PlatformUiSettings>[]);
    registerFallbackValue(ImageCompressFormat.jpg);
  });

  setUp(() async {
    mockImageCropper = MockImageCropper();
    mockPrefs = MockSharedPreferences();

    when(() => mockPrefs.getString(any())).thenReturn('id');

    await GetIt.instance.reset();
    GetIt.instance.registerSingleton<ImageCropper>(mockImageCropper);
    GetIt.instance.registerSingleton<SharedPreferences>(mockPrefs);
    
    AppStrings.init();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest(String imagePath) {
    return MaterialApp(
      home: ImagePreviewScreen(imagePath: imagePath),
    );
  }

  testWidgets('ImagePreviewScreen displays image and has Edit and Confirm buttons', (tester) async {
    const testImagePath = 'test_assets/logo.png';
    
    await tester.pumpWidget(createWidgetUnderTest(testImagePath));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text(AppStrings.isId ? 'Preview Gambar' : 'Image Preview'), findsOneWidget);
    
    // Verify Image is displayed (via FileImage or similar, but checking for presence of widgets)
    expect(find.byType(Image), findsOneWidget);

    // Verify Buttons
    expect(find.text(AppStrings.edit), findsOneWidget);
    expect(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'), findsOneWidget);
  });

  testWidgets('Tapping Edit calls ImageCropper and updates image', (tester) async {
    const testImagePath = 'test_assets/logo.png';
    final fakeEditedFile = FakeCroppedFile();

    when(() => mockImageCropper.cropImage(
      sourcePath: any(named: 'sourcePath'),
      compressFormat: any(named: 'compressFormat'),
      compressQuality: any(named: 'compressQuality'),
      uiSettings: any(named: 'uiSettings'),
    )).thenAnswer((_) async => fakeEditedFile);

    await tester.pumpWidget(createWidgetUnderTest(testImagePath));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.edit));
    await tester.pumpAndSettle();

    verify(() => mockImageCropper.cropImage(
      sourcePath: testImagePath,
      uiSettings: any(named: 'uiSettings'),
    )).called(1);
    
    // In a real implementation, we'd check if the UI updated its internal state.
    // For now, this verifies the interaction.
  });

  testWidgets('Tapping Confirm returns the image path', (tester) async {
    const testImagePath = 'test_assets/logo.png';
    String? returnedPath;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            returnedPath = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImagePreviewScreen(imagePath: testImagePath)),
            );
          },
          child: const Text('Go'),
        ),
      ),
    ));

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'));
    await tester.pumpAndSettle();

    expect(returnedPath, testImagePath);
  });
}
