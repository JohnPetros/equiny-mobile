import 'dart:io';

import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/pending_attachments_preview/pending_attachment_item/pending_attachment_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/pending_attachments_preview/pending_attachments_preview_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> removedIds;

  Widget createWidget({
    List<PendingAttachment> attachments = const <PendingAttachment>[],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PendingAttachmentsPreviewView(
          attachments: attachments,
          onRemove: (String localId) => removedIds.add(localId),
        ),
      ),
    );
  }

  PendingAttachment makePending({
    String localId = 'local-1',
    String name = 'photo.jpg',
  }) {
    return PendingAttachment(
      localId: localId,
      file: File('test/photo.jpg'),
      kind: 'image',
      name: name,
      size: 1024,
      status: AttachmentUploadStatus.ready,
    );
  }

  setUp(() {
    removedIds = <String>[];
  });

  group('PendingAttachmentsPreviewView', () {
    testWidgets('should render nothing when attachments is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(PendingAttachmentItemView), findsNothing);
    });

    testWidgets('should render one item per attachment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachments: <PendingAttachment>[
          makePending(localId: 'a', name: 'a.jpg'),
          makePending(localId: 'b', name: 'b.jpg'),
        ],
      ));

      expect(find.byType(PendingAttachmentItemView), findsNWidgets(2));
    });

    testWidgets('should call onRemove with correct localId', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachments: <PendingAttachment>[
          makePending(localId: 'remove-me', name: 'photo.jpg'),
        ],
      ));

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(removedIds, <String>['remove-me']);
    });
  });
}
