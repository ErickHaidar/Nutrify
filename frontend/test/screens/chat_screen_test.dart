import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutrify/di/service_locator.dart';
import 'package:nutrify/screens/chat_screen.dart';
import 'package:nutrify/services/chatbot_service.dart';

class MockChatbotService extends Mock implements ChatbotService {}

void main() {
  late MockChatbotService mockChatbotService;

  setUp(() async {
    await getIt.reset();
    mockChatbotService = MockChatbotService();
    getIt.registerSingleton<ChatbotService>(mockChatbotService);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(home: ChatScreen());
  }

  testWidgets('ChatScreen shows welcome message and UI components', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Verify AppBar and NutriBot title
    expect(find.text('NutriBot'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);

    // Verify Welcome message is displayed
    expect(
      find.textContaining('Halo! Saya NutriBot, asisten nutrisi pribadimu.'),
      findsOneWidget,
    );

    // Verify input text field is present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('Sending a message calls ChatbotService and appends reply', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(() => mockChatbotService.sendMessage(any())).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return ChatbotResponse(
        reply: 'Ini adalah jawaban dari NutriBot.',
        navigateTo: null,
      );
    });

    await tester.pumpWidget(createWidgetUnderTest());

    // Act: enter a message and send it
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Halo, berapa kalori dalam apel?');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(); // Start sending, should show typing indicator

    // Assert: User message is displayed and typing indicator is visible
    expect(find.text('Halo, berapa kalori dalam apel?'), findsOneWidget);
    expect(find.text('NutriBot sedang mengetik...'), findsOneWidget);

    // Wait for the response to resolve
    await tester.pump(
      const Duration(milliseconds: 100),
    ); // Advance time for delayed future
    await tester.pump(); // Render state with reply and no typing indicator

    // Assert: Typing indicator is gone and reply is visible
    expect(find.text('NutriBot sedang mengetik...'), findsNothing);
    expect(find.text('Ini adalah jawaban dari NutriBot.'), findsOneWidget);

    verify(
      () => mockChatbotService.sendMessage('Halo, berapa kalori dalam apel?'),
    ).called(1);
  });
}
