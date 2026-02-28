import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/chat_input_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late String changedValue;
  late bool sendCalled;
  late bool attachmentTapCalled;
  late List<String> removedAttachmentIds;

  Widget createWidget({
    String draft = '',
    bool isSending = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChatInputBarView(
          draft: draft,
          isSending: isSending,
          pendingAttachments: const [],
          onChanged: (String value) => changedValue = value,
          onSend: () async => sendCalled = true,
          onAttachmentTap: () async => attachmentTapCalled = true,
          onRemoveAttachment: (String id) => removedAttachmentIds.add(id),
        ),
      ),
    );
  }

  setUp(() {
    changedValue = '';
    sendCalled = false;
    attachmentTapCalled = false;
    removedAttachmentIds = <String>[];
  });

  group('ChatInputBarView', () {
    testWidgets('should render text field with placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Digite uma mensagem'), findsOneWidget);
    });

    testWidgets('should render send button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should render attachment button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should call onChanged when text is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), 'Ola');
      await tester.pump();

      expect(changedValue, 'Ola');
    });

    testWidgets('should call onSend when send button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(sendCalled, isTrue);
    });

    testWidgets('should call onAttachmentTap when attachment button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(attachmentTapCalled, isTrue);
    });

    testWidgets('should show loading indicator when isSending is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isSending: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('should disable buttons when isSending is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isSending: true));

      final addButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.add),
      );
      expect(addButton.onPressed, isNull);
    });

    testWidgets('should prefill text field with draft', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(draft: 'Rascunho'));

      expect(find.text('Rascunho'), findsOneWidget);
    });
  });
}
