import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:signals/signals.dart';

import '../../../../../fakers/conversation/chat_faker.dart';
import '../../../../../fakers/conversation/message_faker.dart';
import '../../../../../fakers/conversation/recipient_faker.dart';

class MockChatScreenPresenter extends Mock implements ChatScreenPresenter {}

class MockChatHeaderPresenter extends Mock implements ChatHeaderPresenter {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockChatScreenPresenter presenter;
  late MockChatHeaderPresenter headerPresenter;
  late MockFileStorageDriver fileStorageDriver;

  late Signal<ChatDto?> chat;
  late Signal<List<MessageDto>> messages;
  late Signal<bool> isLoadingInitial;
  late Signal<bool> isLoadingMore;
  late Signal<bool> isSending;
  late Signal<bool> isSocketConnected;
  late Signal<String> draft;
  late Signal<String?> nextCursor;
  late Signal<String?> errorMessage;
  late Signal<bool> isRecipientOnline;
  late Signal<List<PendingAttachment>> pendingAttachments;
  late Signal<Map<String, AttachmentUploadStatus>> uploadStatusMap;
  late Signal<bool> hasMessages;
  late Signal<bool> showEmptyState;
  late Signal<bool> canLoadMore;
  late Signal<bool> canSend;
  late Signal<List<ChatDateSectionDto>> groupedMessages;
  late Signal<String> headerSubtitle;

  late Signal<bool> headerIsRecipientOnline;
  late Signal<String> headerPresenceLabel;

  const String chatId = 'chat-id';

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        chatScreenPresenterProvider(chatId).overrideWithValue(presenter),
        chatHeaderPresenterProvider.overrideWithValue(headerPresenter),
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: const MaterialApp(
        home: ChatScreenView(chatId: chatId),
      ),
    );
  }

  setUpAll(() {
    registerFallbackValue(RecipientFaker.fakeDto());
    registerFallbackValue(MessageFaker.fakeDto());
  });

  setUp(() {
    presenter = MockChatScreenPresenter();
    headerPresenter = MockChatHeaderPresenter();
    fileStorageDriver = MockFileStorageDriver();

    chat = signal<ChatDto?>(null);
    messages = signal<List<MessageDto>>(<MessageDto>[]);
    isLoadingInitial = signal(false);
    isLoadingMore = signal(false);
    isSending = signal(false);
    isSocketConnected = signal(false);
    draft = signal('');
    nextCursor = signal<String?>(null);
    errorMessage = signal<String?>(null);
    isRecipientOnline = signal(false);
    pendingAttachments = signal<List<PendingAttachment>>(<PendingAttachment>[]);
    uploadStatusMap = signal<Map<String, AttachmentUploadStatus>>(
      <String, AttachmentUploadStatus>{},
    );
    hasMessages = signal(false);
    showEmptyState = signal(true);
    canLoadMore = signal(false);
    canSend = signal(false);
    groupedMessages = signal<List<ChatDateSectionDto>>(
      <ChatDateSectionDto>[],
    );
    headerSubtitle = signal('');

    headerIsRecipientOnline = signal(false);
    headerPresenceLabel = signal('');

    when(() => presenter.chat).thenReturn(chat);
    when(() => presenter.messages).thenReturn(messages);
    when(() => presenter.isLoadingInitial).thenReturn(isLoadingInitial);
    when(() => presenter.isLoadingMore).thenReturn(isLoadingMore);
    when(() => presenter.isSending).thenReturn(isSending);
    when(() => presenter.isSocketConnected).thenReturn(isSocketConnected);
    when(() => presenter.draft).thenReturn(draft);
    when(() => presenter.nextCursor).thenReturn(nextCursor);
    when(() => presenter.errorMessage).thenReturn(errorMessage);
    when(() => presenter.isRecipientOnline).thenReturn(isRecipientOnline);
    when(() => presenter.pendingAttachments).thenReturn(pendingAttachments);
    when(() => presenter.uploadStatusMap).thenReturn(uploadStatusMap);
    when(() => presenter.hasMessages).thenReturn(hasMessages);
    when(() => presenter.showEmptyState).thenReturn(showEmptyState);
    when(() => presenter.canLoadMore).thenReturn(canLoadMore);
    when(() => presenter.canSend).thenReturn(canSend);
    when(() => presenter.groupedMessages).thenReturn(groupedMessages);
    when(() => presenter.headerSubtitle).thenReturn(headerSubtitle);

    when(() => presenter.retry()).thenReturn(null);
    when(() => presenter.onBack()).thenReturn(null);
    when(() => presenter.onDraftChanged(any())).thenReturn(null);
    when(() => presenter.sendMessage()).thenAnswer((_) async {});
    when(() => presenter.sendSuggestedMessage(any())).thenAnswer((_) async {});
    when(() => presenter.loadMoreMessages()).thenAnswer((_) async {});
    when(() => presenter.loadInitialMessages()).thenAnswer((_) async {});
    when(() => presenter.connectChannel()).thenAnswer((_) async {});
    when(() => presenter.disconnectChannel()).thenAnswer((_) async {});
    when(() => presenter.isMine(any())).thenReturn(true);
    when(() => presenter.formatMessageHour(any())).thenReturn('10:30');
    when(() => presenter.resolveFileUrl(any())).thenReturn('');
    when(() => presenter.retryAttachmentUpload(any())).thenAnswer((_) async {});
    when(() => presenter.removePendingAttachment(any())).thenReturn(null);
    when(() => presenter.pickImageAttachments()).thenAnswer((_) async {});
    when(() => presenter.pickDocumentAttachments()).thenAnswer((_) async {});

    when(() => headerPresenter.isRecipientOnline).thenReturn(
      headerIsRecipientOnline,
    );
    when(() => headerPresenter.presenceLabel).thenReturn(headerPresenceLabel);
    when(() => headerPresenter.resolveAvatarUrl(any())).thenReturn('');
    when(() => headerPresenter.loadPresence(any())).thenAnswer((_) async {});
    when(() => headerPresenter.disconnectRealtime()).thenReturn(null);

    when(() => fileStorageDriver.getFileUrl(any())).thenReturn('');
  });

  group('ChatScreenView', () {
    testWidgets('should render loading state when isLoadingInitial is true', (
      WidgetTester tester,
    ) async {
      isLoadingInitial.value = true;

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render error state when errorMessage is set and chat is null', (
      WidgetTester tester,
    ) async {
      errorMessage.value = 'Erro ao carregar conversa.';

      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Erro ao carregar conversa.'), findsOneWidget);
    });

    testWidgets('should call retry when retry button is tapped in error state', (
      WidgetTester tester,
    ) async {
      errorMessage.value = 'Erro ao carregar conversa.';

      await tester.pumpWidget(createWidget());
      await tester.pump();

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      verify(() => presenter.retry()).called(1);
    });

    testWidgets('should render empty state when showEmptyState is true', (
      WidgetTester tester,
    ) async {
      showEmptyState.value = true;
      chat.value = ChatFaker.fakeDto(
        id: chatId,
        recipient: RecipientFaker.fakeDto(name: 'Maria'),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pump();
      });

      expect(find.textContaining('sugestao'), findsWidgets);
    });

    testWidgets('should render chat header when chat has recipient', (
      WidgetTester tester,
    ) async {
      showEmptyState.value = false;
      hasMessages.value = true;
      chat.value = ChatFaker.fakeDto(
        id: chatId,
        recipient: RecipientFaker.fakeDto(name: 'Maria'),
      );
      groupedMessages.value = <ChatDateSectionDto>[
        ChatDateSectionDto(
          date: DateTime(2026, 1, 1),
          label: 'HOJE',
          messages: <MessageDto>[MessageFaker.fakeDto()],
        ),
      ];

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pump();
      });

      expect(find.text('Maria'), findsOneWidget);
    });

    testWidgets('should render chat input bar in content state', (
      WidgetTester tester,
    ) async {
      showEmptyState.value = false;
      hasMessages.value = true;
      chat.value = ChatFaker.fakeDto(
        id: chatId,
        recipient: RecipientFaker.fakeDto(name: 'Maria'),
      );
      groupedMessages.value = <ChatDateSectionDto>[
        ChatDateSectionDto(
          date: DateTime(2026, 1, 1),
          label: 'HOJE',
          messages: <MessageDto>[MessageFaker.fakeDto()],
        ),
      ];

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pump();
      });

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should call onBack when back button is tapped', (
      WidgetTester tester,
    ) async {
      showEmptyState.value = false;
      hasMessages.value = true;
      chat.value = ChatFaker.fakeDto(
        id: chatId,
        recipient: RecipientFaker.fakeDto(name: 'Maria'),
      );
      groupedMessages.value = <ChatDateSectionDto>[
        ChatDateSectionDto(
          date: DateTime(2026, 1, 1),
          label: 'HOJE',
          messages: <MessageDto>[MessageFaker.fakeDto()],
        ),
      ];

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pump();
      });

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      verify(() => presenter.onBack()).called(1);
    });
  });
}
