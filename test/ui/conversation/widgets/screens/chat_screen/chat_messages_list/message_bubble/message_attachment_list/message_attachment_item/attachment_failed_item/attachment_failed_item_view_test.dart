import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_failed_item/attachment_failed_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late bool retryTapped;

  Widget createWidget({required String name}) {
    return MaterialApp(
      home: Scaffold(
        body: AttachmentFailedItemView(
          name: name,
          onRetry: () => retryTapped = true,
        ),
      ),
    );
  }

  setUp(() {
    retryTapped = false;
  });

  group('AttachmentFailedItemView', () {
    testWidgets('should render file name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      expect(find.text('photo.jpg'), findsOneWidget);
    });

    testWidgets('should render error icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should render retry button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      expect(
        find.widgetWithText(TextButton, 'Tentar novamente'),
        findsOneWidget,
      );
    });

    testWidgets('should call onRetry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      await tester.tap(
        find.widgetWithText(TextButton, 'Tentar novamente'),
      );
      await tester.pump();

      expect(retryTapped, isTrue);
    });
  });
}
