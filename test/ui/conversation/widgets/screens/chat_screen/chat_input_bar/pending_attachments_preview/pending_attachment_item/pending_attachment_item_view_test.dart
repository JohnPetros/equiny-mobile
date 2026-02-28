import 'dart:io';

import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/pending_attachments_preview/pending_attachment_item/pending_attachment_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late bool removeTapped;

  Widget createWidget({
    required PendingAttachment attachment,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PendingAttachmentItemView(
          attachment: attachment,
          onRemove: () => removeTapped = true,
        ),
      ),
    );
  }

  setUp(() {
    removeTapped = false;
  });

  PendingAttachment makePending({
    String kind = 'image',
    String name = 'photo.jpg',
    AttachmentUploadStatus status = AttachmentUploadStatus.ready,
    String? errorMessage,
  }) {
    return PendingAttachment(
      localId: 'local-1',
      file: File('test/photo.jpg'),
      kind: kind,
      name: name,
      size: 1024,
      status: status,
      errorMessage: errorMessage,
    );
  }

  group('PendingAttachmentItemView', () {
    testWidgets('should render attachment name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(name: 'my_photo.jpg'),
      ));

      expect(find.text('my_photo.jpg'), findsOneWidget);
    });

    testWidgets('should render image icon for image kind', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(kind: 'image'),
      ));

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('should render document icon for non-image kind', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(kind: 'pdf'),
      ));

      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });

    testWidgets('should render close button and call onRemove when tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(),
      ));

      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(removeTapped, isTrue);
    });

    testWidgets('should render error message when attachment has failed status', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(
          status: AttachmentUploadStatus.failed,
          errorMessage: 'Imagem excede 2 MB.',
        ),
      ));

      expect(find.text('Imagem excede 2 MB.'), findsOneWidget);
    });

    testWidgets('should not render error message when status is ready', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: makePending(status: AttachmentUploadStatus.ready),
      ));

      expect(find.text('Imagem excede 2 MB.'), findsNothing);
    });
  });
}
