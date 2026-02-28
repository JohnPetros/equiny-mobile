import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/date_separator_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({required String label}) {
    return MaterialApp(
      home: Scaffold(body: DateSeparatorView(label: label)),
    );
  }

  group('DateSeparatorView', () {
    testWidgets('should render label in uppercase', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(label: 'hoje'));

      expect(find.text('HOJE'), findsOneWidget);
    });

    testWidgets('should render already uppercase label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(label: 'ONTEM'));

      expect(find.text('ONTEM'), findsOneWidget);
    });
  });
}
