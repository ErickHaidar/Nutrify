import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/services/profile_api_service.dart';
import 'package:nutrify/data/network/constants/endpoints.dart';
import 'package:nutrify/di/service_locator.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late ProfileApiService profileApiService;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = MockDio();
    
    when(() => mockDioClient.dio).thenReturn(mockDio);
    
    await getIt.reset();
    getIt.registerSingleton<DioClient>(mockDioClient);
    
    profileApiService = ProfileApiService();
    
    // Register fallback values if needed
    registerFallbackValue(Uri.parse('http://localhost'));
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('uploadProfilePhoto sends a PUT request with multipart form data', () async {
    // Arrange
    final file = File('test_assets/logo.png');
    when(() => mockDio.put(
      any(),
      data: any(named: 'data'),
      options: any(named: 'options'),
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: Endpoints.profilePhoto),
      statusCode: 200,
      data: {'message': 'Success'},
    ));

    // Act
    await profileApiService.uploadProfilePhoto(file);

    // Assert
    final captured = verify(() => mockDio.put(
      Endpoints.profilePhoto,
      data: captureAny(named: 'data'),
    )).captured;
    
    final formData = captured.first as FormData;
    expect(formData.files.length, 1);
    expect(formData.files.first.key, 'photo'); // Assuming the backend expects 'photo' as the field name
  });
}
