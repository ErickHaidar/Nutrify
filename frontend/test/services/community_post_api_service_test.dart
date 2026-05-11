import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/services/community_post_api_service.dart';
import 'package:nutrify/di/service_locator.dart';

class MockDioClient extends Mock implements DioClient {}
class MockDio extends Mock implements Dio {}

void main() {
  late CommunityPostApiService communityPostApiService;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);

    await getIt.reset();
    getIt.registerSingleton<DioClient>(mockDioClient);

    communityPostApiService = CommunityPostApiService();

    // Mock successful response
    when(() => mockDio.put('users/profile', data: any(named: 'data')))
        .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'users/profile'),
              data: {
                'data': {
                  'name': 'A',
                  'username': 'newuser',
                  'account_type': 'public'
                }
              },
              statusCode: 200,
            ));
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('updateProfile sends only name when username is null', () async {
    // Act
    await communityPostApiService.updateProfile(name: 'A');

    // Assert
    final verification = verify(() => mockDio.put(
          'users/profile',
          data: captureAny(named: 'data'),
        ));
    verification.called(1);
    final captured = verification.captured;

    final data = captured.first as Map<String, dynamic>;
    expect(data.containsKey('name'), isTrue);
    expect(data['name'], 'A');
    expect(data.containsKey('username'), isFalse);
    expect(data.containsKey('account_type'), isFalse);
  });

  test('updateProfile sends only username when name is null', () async {
    // Act
    await communityPostApiService.updateProfile(username: 'newuser');

    // Assert
    final verification = verify(() => mockDio.put(
          'users/profile',
          data: captureAny(named: 'data'),
        ));
    verification.called(1);
    final captured = verification.captured;

    final data = captured.first as Map<String, dynamic>;
    expect(data.containsKey('username'), isTrue);
    expect(data['username'], 'newuser');
    expect(data.containsKey('name'), isFalse);
    expect(data.containsKey('account_type'), isFalse);
  });

  test('updateProfile sends both when both provided', () async {
    // Act
    await communityPostApiService.updateProfile(
      name: 'A',
      username: 'newuser',
    );

    // Assert
    final verification = verify(() => mockDio.put(
          'users/profile',
          data: captureAny(named: 'data'),
        ));
    verification.called(1);
    final captured = verification.captured;

    final data = captured.first as Map<String, dynamic>;
    expect(data['name'], 'A');
    expect(data['username'], 'newuser');
    expect(data.containsKey('account_type'), isFalse);
  });

  test('updateProfile sends empty map when all null', () async {
    // Act
    await communityPostApiService.updateProfile();

    // Assert
    final verification = verify(() => mockDio.put(
          'users/profile',
          data: captureAny(named: 'data'),
        ));
    verification.called(1);
    final captured = verification.captured;

    final data = captured.first as Map<String, dynamic>;
    expect(data.isEmpty, isTrue);
  });
}
