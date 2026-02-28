import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_loading_item/attachment_loading_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({required String name}) {
    return MaterialApp(
      home: Scaffold(body: AttachmentLoadingItemView(name: name)),
    );
  }

  group('AttachmentLoadingItemView', () {
    testWidgets('should render file name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      expect(find.text('photo.jpg'), findsOneWidget);
    });

    testWidgets('should render loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(name: 'photo.jpg'));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
