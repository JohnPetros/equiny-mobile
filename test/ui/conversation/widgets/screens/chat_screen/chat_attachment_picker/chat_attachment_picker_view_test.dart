import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> pickedActions;

  setUp(() {
    pickedActions = <String>[];
  });

  Widget createWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChatAttachmentPickerView(
          onPickImages: () async {
            pickedActions.add('images');
          },
          onPickDocuments: () async {
            pickedActions.add('documents');
          },
        ),
      ),
    );
  }

  group('ChatAttachmentPickerView', () {
    testWidgets('should render image option', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Imagem'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('should render document option', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Documento'), findsOneWidget);
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('should render two ListTile options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('should call onPickImages when image option is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Imagem'));
      await tester.pumpAndSettle();

      expect(pickedActions, <String>['images']);
    });

    testWidgets('should call onPickDocuments when document option is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Documento'));
      await tester.pumpAndSettle();

      expect(pickedActions, <String>['documents']);
    });
  });
}
