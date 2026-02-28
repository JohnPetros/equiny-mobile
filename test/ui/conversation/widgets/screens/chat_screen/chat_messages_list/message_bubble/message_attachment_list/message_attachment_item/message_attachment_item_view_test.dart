import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_document_item/attachment_document_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_failed_item/attachment_failed_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_image_item/attachment_image_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_loading_item/attachment_loading_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/message_attachment_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../../../../../../fakers/conversation/attachment_dto_faker.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockFileStorageDriver fileStorageDriver;
  late String retriedKey;
  late String openedImageUrl;

  Widget createWidget({
    required MessageAttachmentDto attachment,
    required AttachmentUploadStatus status,
    String resolvedUrl = 'https://cdn.equiny/file',
  }) {
    return ProviderScope(
      overrides: <Override>[
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MessageAttachmentItemView(
            attachment: attachment,
            status: status,
            resolvedUrl: resolvedUrl,
            onRetry: (String key) => retriedKey = key,
            onOpenImage: (String url) => openedImageUrl = url,
          ),
        ),
      ),
    );
  }

  setUp(() {
    fileStorageDriver = MockFileStorageDriver();
    retriedKey = '';
    openedImageUrl = '';
    when(
      () => fileStorageDriver.getFileUrl(any()),
    ).thenReturn('https://cdn.equiny/file');
  });

  group('MessageAttachmentItemView', () {
    testWidgets('should render loading item when status is sending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: AttachmentDtoFaker.fakeDto(),
        status: AttachmentUploadStatus.sending,
      ));

      expect(find.byType(AttachmentLoadingItemView), findsOneWidget);
    });

    testWidgets('should render failed item when status is failed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: AttachmentDtoFaker.fakeDto(),
        status: AttachmentUploadStatus.failed,
      ));

      expect(find.byType(AttachmentFailedItemView), findsOneWidget);
    });

    testWidgets('should render image item when status is ready and kind is image', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget(
          attachment: AttachmentDtoFaker.fakeDto(kind: 'image'),
          status: AttachmentUploadStatus.ready,
        ));

        expect(find.byType(AttachmentImageItemView), findsOneWidget);
      });
    });

    testWidgets('should render document item when status is ready and kind is pdf', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: AttachmentDtoFaker.fakePdfDto(),
        status: AttachmentUploadStatus.ready,
      ));

      expect(find.byType(AttachmentDocumentItemView), findsOneWidget);
    });

    testWidgets('should render nothing when kind is unsupported', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(
        attachment: AttachmentDtoFaker.fakeDto(kind: 'unknown'),
        status: AttachmentUploadStatus.ready,
      ));

      expect(find.byType(AttachmentImageItemView), findsNothing);
      expect(find.byType(AttachmentDocumentItemView), findsNothing);
    });
  });
}
