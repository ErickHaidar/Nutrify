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
    
    // Wrap pumpWidget inside runAsync so real file I/O can complete during initState
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest(testImagePath));
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Verify Buttons are present (loading done, IO complete)
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

    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest(testImagePath));
      // Allow async _loadImageBytes to complete
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    await tester.tap(find.text(AppStrings.edit));
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    verify(() => mockImageCropper.cropImage(
      sourcePath: testImagePath,
      uiSettings: any(named: 'uiSettings'),
    )).called(1);
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
    await tester.pump();

    // Run the ENTIRE navigation + interaction inside runAsync so that:
    //  1. File I/O in _loadImageBytes() can complete (real async work)
    //  2. The Navigator.push future continuation (returnedPath = await ...)
    //     resolves in the same async zone where the push was awaited.
    await tester.runAsync(() async {
      // Tap Go to navigate to ImagePreviewScreen
      await tester.tap(find.text('Go'));
      await tester.pump(); // start navigation
      await tester.pump(const Duration(milliseconds: 300)); // settle animation

      // Let _loadImageBytes() (real file I/O) complete
      await Future.delayed(const Duration(milliseconds: 500));
      await tester.pump(); // drain setState(_isLoadingBytes = false)
      await tester.pump();

      // Verify buttons are visible before tapping
      expect(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'), findsOneWidget,
          reason: 'Use Photo button should be visible after file load');

      // Tap 'Gunakan Foto' — calls Navigator.pop(context, _currentImagePath)
      await tester.tap(find.text(AppStrings.isId ? 'Gunakan Foto' : 'Use Photo'));
      await tester.pump(); // process tap → Navigator.pop fires
      await tester.pump(); // drain microtasks: returnedPath = await ... runs here
      await tester.pump(const Duration(milliseconds: 300)); // settle pop animation
    });

    // Drain any remaining frames outside runAsync
    await tester.pumpAndSettle();

    expect(returnedPath, testImagePath);
  });
}
