import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_error_state/chat_error_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int retryCount;

  setUp(() {
    retryCount = 0;
  });

  Widget createWidget({String message = 'Erro ao carregar conversa.'}) {
    return MaterialApp(
      home: Scaffold(
        body: ChatErrorStateView(
          message: message,
          onRetry: () => retryCount++,
        ),
      ),
    );
  }

  group('ChatErrorStateView', () {
    testWidgets('should render error icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render error message', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(message: 'Falha na conexao.'));

      expect(find.text('Falha na conexao.'), findsOneWidget);
    });

    testWidgets('should render retry button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryCount, 1);
    });

    testWidgets('should call onRetry multiple times on multiple taps', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();
      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryCount, 2);
    });
  });
}
