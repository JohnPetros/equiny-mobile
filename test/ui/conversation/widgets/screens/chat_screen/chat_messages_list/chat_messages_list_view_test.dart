import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/chat_messages_list_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/date_separator_view.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../fakers/conversation/chat_date_section_faker.dart';
import '../../../../../../fakers/conversation/message_faker.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockFileStorageDriver fileStorageDriver;

  Widget createWidget({
    List<ChatDateSectionDto> sections = const <ChatDateSectionDto>[],
    bool isLoadingMore = false,
  }) {
    return ProviderScope(
      overrides: <Override>[
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ChatMessagesListView(
            sections: sections,
            onReachTop: () async {},
            isLoadingMore: isLoadingMore,
            isMine: (MessageDto message) => message.senderId == 'owner-id',
            formatTime: (DateTime sentAt) =>
                '${sentAt.hour.toString().padLeft(2, '0')}:${sentAt.minute.toString().padLeft(2, '0')}',
            uploadStatusMap: const <String, AttachmentUploadStatus>{},
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

  group('ChatMessagesListView', () {
    testWidgets('should render date separators and message bubbles', (
      WidgetTester tester,
    ) async {
      final sections = <ChatDateSectionDto>[
        ChatDateSectionDto(
          date: DateTime(2026, 1, 1),
          label: 'HOJE',
          messages: <MessageDto>[
            MessageFaker.fakeDto(content: 'Ola!', senderId: 'owner-id'),
            MessageFaker.fakeDto(
              id: 'msg-2',
              content: 'Tudo bem?',
              senderId: 'other-id',
            ),
          ],
        ),
      ];

      await tester.pumpWidget(createWidget(sections: sections));

      expect(find.byType(DateSeparatorView), findsOneWidget);
      expect(find.byType(MessageBubbleView), findsNWidgets(2));
      expect(find.text('Ola!'), findsOneWidget);
      expect(find.text('Tudo bem?'), findsOneWidget);
    });

    testWidgets('should render loading indicator when isLoadingMore is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(isLoadingMore: true),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not render loading indicator when isLoadingMore is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(isLoadingMore: false),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should render multiple sections', (
      WidgetTester tester,
    ) async {
      final sections = ChatDateSectionFaker.fakeManyDto(length: 2);

      await tester.pumpWidget(createWidget(sections: sections));

      expect(find.byType(DateSeparatorView), findsNWidgets(2));
    });
  });
}
