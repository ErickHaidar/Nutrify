import 'package:nutrify/core/data/network/dio/dio_client.dart';
import 'package:nutrify/di/service_locator.dart';

class ChatbotResponse {
  final String reply;
  final String? navigateTo;

  ChatbotResponse({required this.reply, this.navigateTo});

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      reply: json['reply'] as String? ?? '',
      navigateTo: json['navigate_to'] as String?,
    );
  }
}

class ChatbotService {
  DioClient get _dio => getIt<DioClient>();
  final List<Map<String, dynamic>> messages = [];

  void clearHistory() {
    messages.clear();
  }

  Future<ChatbotResponse> sendMessage(String message) async {
    final response = await _dio.dio.post(
      'chatbot/message',
      data: {'message': message},
    );

    // Handle cases where the response might be nested under 'data' or similar
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        return ChatbotResponse.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      }
      return ChatbotResponse.fromJson(responseData);
    }
    throw Exception('Invalid response format');
  }
}
