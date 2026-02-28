import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../../../../fakers/conversation/attachment_dto_faker.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockFileStorageDriver fileStorageDriver;

  Widget createWidget({
    String message = 'Ola!',
    bool isMine = true,
    String timeLabel = '10:30',
    bool isReadByRecipient = false,
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
          body: MessageBubbleView(
            message: message,
            isMine: isMine,
            timeLabel: timeLabel,
            isReadByRecipient: isReadByRecipient,
            attachments: attachments,
            uploadStatusMap: uploadStatusMap,
            resolveFileUrl: (String key) => 'https://cdn.equiny/$key',
            onRetryAttachment: (_) {},
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

  group('MessageBubbleView', () {
    testWidgets('should render message text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(message: 'Ola, tudo bem?'));

      expect(find.text('Ola, tudo bem?'), findsOneWidget);
    });

    testWidgets('should render time label', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(timeLabel: '14:30'));

      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('should align to the right when isMine is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isMine: true));

      final Align align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('should align to the left when isMine is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isMine: false));

      final Align align = tester.widget<Align>(find.byType(Align).first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('should show done_all icon when read by recipient and isMine', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(isMine: true, isReadByRecipient: true),
      );

      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('should show done icon when not read by recipient and isMine', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(isMine: true, isReadByRecipient: false),
      );

      expect(find.byIcon(Icons.done), findsOneWidget);
    });

    testWidgets('should not show read receipt icon when not isMine', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isMine: false));

      expect(find.byIcon(Icons.done), findsNothing);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('should not render text when message is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(message: '   '));

      expect(find.text('   '), findsNothing);
    });

    testWidgets('should render attachments when provided', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget(
          attachments: <MessageAttachmentDto>[
            AttachmentDtoFaker.fakeDto(kind: 'image'),
          ],
        ));

        expect(find.text('image.jpg'), findsOneWidget);
      });
    });
  });
}
