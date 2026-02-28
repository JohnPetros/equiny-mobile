import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_loading_state/chat_loading_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(
      home: Scaffold(body: ChatLoadingStateView()),
    );
  }

  group('ChatLoadingStateView', () {
    testWidgets('should render CircularProgressIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should center the loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Center), findsOneWidget);
    });
  });
}
