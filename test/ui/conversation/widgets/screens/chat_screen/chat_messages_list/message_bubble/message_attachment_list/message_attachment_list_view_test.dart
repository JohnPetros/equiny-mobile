import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/message_attachment_item_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../../../../../fakers/conversation/attachment_dto_faker.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockFileStorageDriver fileStorageDriver;

  Widget createWidget({
    List<MessageAttachmentDto> attachments = const <MessageAttachmentDto>[],
    Map<String, AttachmentUploadStatus> uploadStatusMap =
        const <String, AttachmentUploadStatus>{},
  }) {
    return ProviderScope(
      overrides: <Override>[
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MessageAttachmentListView(
            attachments: attachments,
            uploadStatusMap: uploadStatusMap,
            resolveFileUrl: (String key) => 'https://cdn.equiny/$key',
            onRetry: (_) {},
            onOpenImage: (_) {},
          ),
        ),
      ),
    );
  }

  setUp(() {
    fileStorageDriver = MockFileStorageDriver();
    when(
      () => fileStorageDriver.getFileUrl(any()),
    ).thenReturn('https://cdn.equiny/file');
  });

  group('MessageAttachmentListView', () {
    testWidgets('should render nothing when attachments is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(MessageAttachmentItemView), findsNothing);
    });

    testWidgets('should render one item per attachment', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget(
          attachments: AttachmentDtoFaker.fakeManyDto(length: 2),
        ));

        expect(find.byType(MessageAttachmentItemView), findsNWidgets(2));
      });
    });

    testWidgets('should pass correct status from uploadStatusMap', (
      WidgetTester tester,
    ) async {
      final attachment = AttachmentDtoFaker.fakeDto(
        key: 'file-key',
        kind: 'image',
      );

      await tester.pumpWidget(createWidget(
        attachments: <MessageAttachmentDto>[attachment],
        uploadStatusMap: <String, AttachmentUploadStatus>{
          'file-key': AttachmentUploadStatus.sending,
        },
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
