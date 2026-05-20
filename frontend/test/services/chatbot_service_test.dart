import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/services/chatbot_service.dart';

class MockDioClient extends Mock implements DioClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late ChatbotService chatbotService;
  late MockDioClient mockDioClient;
  late MockDio mockDio;

  setUp(() async {
    mockDioClient = MockDioClient();
    mockDio = MockDio();

    when(() => mockDioClient.dio).thenReturn(mockDio);

    await getIt.reset();
    getIt.registerSingleton<DioClient>(mockDioClient);

    chatbotService = ChatbotService();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('ChatbotService Tests', () {
    test('sendMessage returns a ChatbotResponse on success', () async {
      // Arrange
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: 'chatbot/message'),
          statusCode: 200,
          data: {
            'reply': 'Halo! Saya asisten diet Anda.',
            'navigate_to': 'profile',
          },
        ),
      );

      // Act
      final result = await chatbotService.sendMessage('Halo');

      // Assert
      expect(result.reply, 'Halo! Saya asisten diet Anda.');
      expect(result.navigateTo, 'profile');

      verify(
        () => mockDio.post('chatbot/message', data: {'message': 'Halo'}),
      ).called(1);
    });

    test(
      'sendMessage returns a ChatbotResponse when response is nested in a data field',
      () async {
        // Arrange
        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: 'chatbot/message'),
            statusCode: 200,
            data: {
              'data': {
                'reply': 'Tentu! Buka halaman riwayat.',
                'navigate_to': 'history',
              },
            },
          ),
        );

        // Act
        final result = await chatbotService.sendMessage(
          'Lihat riwayat makan saya',
        );

        // Assert
        expect(result.reply, 'Tentu! Buka halaman riwayat.');
        expect(result.navigateTo, 'history');

        verify(
          () => mockDio.post(
            'chatbot/message',
            data: {'message': 'Lihat riwayat makan saya'},
          ),
        ).called(1);
      },
    );
  });
}
