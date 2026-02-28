import 'dart:io';

import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/attachment_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/pending_attachment.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/conversation/events/message_received_event.dart';
import 'package:equiny/core/conversation/events/message_sent_event.dart';
import 'package:equiny/core/conversation/interfaces/conversation_channel.dart';
import 'package:equiny/core/conversation/interfaces/conversation_service.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/core/shared/responses/pagination_response.dart';
import 'package:equiny/core/shared/responses/rest_response.dart';
import 'package:equiny/core/storage/dtos/structures/upload_url_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/storage/interfaces/file_storage_service.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../fakers/conversation/chat_faker.dart';
import '../../../../../fakers/conversation/message_faker.dart';
import '../../../../../fakers/conversation/recipient_faker.dart';

class MockConversationService extends Mock implements ConversationService {}

class MockConversationChannel extends Mock implements ConversationChannel {}

class MockProfilingService extends Mock implements ProfilingService {}

class MockNavigationDriver extends Mock implements NavigationDriver {}

class MockCacheDriver extends Mock implements CacheDriver {}

class MockFileStorageService extends Mock implements FileStorageService {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

class MockDocumentPickerDriver extends Mock implements DocumentPickerDriver {}

class MockFile extends Mock implements File {}

void main() {
  late MockConversationService conversationService;
  late MockConversationChannel conversationChannel;
  late MockProfilingService profilingService;
  late MockNavigationDriver navigationDriver;
  late MockCacheDriver cacheDriver;
  late MockFileStorageService fileStorageService;
  late MockFileStorageDriver fileStorageDriver;
  late MockMediaPickerDriver mediaPickerDriver;
  late MockDocumentPickerDriver documentPickerDriver;
  late ChatScreenPresenter presenter;

  const String chatId = 'chat-id';

  setUpAll(() {
    registerFallbackValue(MessageSentEvent(
      messageContent: '',
      chatId: '',
      senderId: '',
      attachments: const <MessageAttachmentDto>[],
    ));
    registerFallbackValue(MockFile());
    registerFallbackValue(const UploadUrlDto(url: '', token: '', filePath: ''));
  });

  setUp(() {
    conversationService = MockConversationService();
    conversationChannel = MockConversationChannel();
    profilingService = MockProfilingService();
    navigationDriver = MockNavigationDriver();
    cacheDriver = MockCacheDriver();
    fileStorageService = MockFileStorageService();
    fileStorageDriver = MockFileStorageDriver();
    mediaPickerDriver = MockMediaPickerDriver();
    documentPickerDriver = MockDocumentPickerDriver();

    when(
      () => conversationChannel.listen(
        onMessageReceived: any(named: 'onMessageReceived'),
      ),
    ).thenReturn(() {});
    when(() => cacheDriver.get(any())).thenReturn('owner-id');

    presenter = ChatScreenPresenter(
      chatId,
      conversationService,
      conversationChannel,
      profilingService,
      navigationDriver,
      cacheDriver,
      fileStorageService,
      fileStorageDriver,
      mediaPickerDriver,
      documentPickerDriver,
    );
  });

  group('ChatScreenPresenter', () {
    group('initial state', () {
      test('should initialize with default signal values', () {
        expect(presenter.chat.value, isNull);
        expect(presenter.messages.value, isEmpty);
        expect(presenter.isLoadingInitial.value, isFalse);
        expect(presenter.isLoadingMore.value, isFalse);
        expect(presenter.isSending.value, isFalse);
        expect(presenter.isSocketConnected.value, isFalse);
        expect(presenter.draft.value, isEmpty);
        expect(presenter.nextCursor.value, isNull);
        expect(presenter.errorMessage.value, isNull);
        expect(presenter.isRecipientOnline.value, isFalse);
        expect(presenter.pendingAttachments.value, isEmpty);
        expect(presenter.uploadStatusMap.value, isEmpty);
      });

      test('should compute hasMessages as false when messages is empty', () {
        expect(presenter.hasMessages.value, isFalse);
      });

      test('should compute showEmptyState as true when not loading and no error and no messages', () {
        expect(presenter.showEmptyState.value, isTrue);
      });

      test('should compute canLoadMore as false when nextCursor is null', () {
        expect(presenter.canLoadMore.value, isFalse);
      });

      test('should compute canSend as false when socket is not connected', () {
        presenter.draft.value = 'hello';
        expect(presenter.canSend.value, isFalse);
      });
    });

    group('computed signals', () {
      test('should compute hasMessages as true when messages exist', () {
        presenter.messages.value = <MessageDto>[MessageFaker.fakeDto()];
        expect(presenter.hasMessages.value, isTrue);
      });

      test('should compute showEmptyState as false when loading', () {
        presenter.isLoadingInitial.value = true;
        expect(presenter.showEmptyState.value, isFalse);
      });

      test('should compute showEmptyState as false when error exists', () {
        presenter.errorMessage.value = 'error';
        expect(presenter.showEmptyState.value, isFalse);
      });

      test('should compute showEmptyState as false when messages exist', () {
        presenter.messages.value = <MessageDto>[MessageFaker.fakeDto()];
        expect(presenter.showEmptyState.value, isFalse);
      });

      test('should compute canLoadMore as true when not loading and nextCursor is non-empty', () {
        presenter.nextCursor.value = 'cursor-abc';
        expect(presenter.canLoadMore.value, isTrue);
      });

      test('should compute canLoadMore as false when isLoadingMore is true', () {
        presenter.isLoadingMore.value = true;
        presenter.nextCursor.value = 'cursor-abc';
        expect(presenter.canLoadMore.value, isFalse);
      });

      test('should compute canLoadMore as false when nextCursor is empty string', () {
        presenter.nextCursor.value = '';
        expect(presenter.canLoadMore.value, isFalse);
      });

      test('should compute canSend as true when not sending and draft non-empty and socket connected', () {
        presenter.draft.value = 'hello';
        presenter.isSocketConnected.value = true;
        expect(presenter.canSend.value, isTrue);
      });

      test('should compute canSend as true when not sending and pending attachments exist and socket connected', () {
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: MockFile(),
            kind: 'image',
            name: 'img.jpg',
            size: 100,
            status: AttachmentUploadStatus.ready,
          ),
        ];
        expect(presenter.canSend.value, isTrue);
      });

      test('should compute canSend as false when isSending is true', () {
        presenter.isSending.value = true;
        presenter.draft.value = 'hello';
        presenter.isSocketConnected.value = true;
        expect(presenter.canSend.value, isFalse);
      });

      test('should compute canSend as false when draft is empty and no pending attachments', () {
        presenter.isSocketConnected.value = true;
        expect(presenter.canSend.value, isFalse);
      });

      test('should compute headerSubtitle as Online agora when recipient is online', () {
        presenter.isRecipientOnline.value = true;
        expect(presenter.headerSubtitle.value, 'Online agora');
      });

      test('should compute headerSubtitle as Visto recentemente when recipient is offline and no lastPresenceAt', () {
        presenter.isRecipientOnline.value = false;
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(),
        );
        expect(presenter.headerSubtitle.value, 'Visto recentemente');
      });

      test('should compute headerSubtitle with formatted date when recipient has lastPresenceAt', () {
        presenter.isRecipientOnline.value = false;
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: const RecipientDto(
            id: 'recipient-id',
            name: 'Recipient',
            lastPresenceAt: null,
          ),
        );
        expect(presenter.headerSubtitle.value, 'Visto recentemente');
      });
    });

    group('loadChat', () {
      test('should set chat when fetchChats returns chat with matching id', () async {
        final chat = ChatFaker.fakeDto(id: chatId);
        when(() => conversationService.fetchChats()).thenAnswer(
          (_) async => RestResponse<List<ChatDto>>(body: <ChatDto>[chat]),
        );

        await presenter.loadChat();

        expect(presenter.chat.value, chat);
        expect(presenter.errorMessage.value, isNull);
      });

      test('should set error when fetchChats fails', () async {
        when(() => conversationService.fetchChats()).thenAnswer(
          (_) async => RestResponse<List<ChatDto>>(
            statusCode: 500,
            errorMessage: 'Erro de rede',
          ),
        );

        await presenter.loadChat();

        expect(presenter.chat.value, isNull);
        expect(presenter.errorMessage.value, 'Erro de rede');
      });

      test('should set error when chat with matching id is not found', () async {
        final otherChat = ChatFaker.fakeDto(id: 'other-chat-id');
        when(() => conversationService.fetchChats()).thenAnswer(
          (_) async => RestResponse<List<ChatDto>>(body: <ChatDto>[otherChat]),
        );

        await presenter.loadChat();

        expect(presenter.chat.value, isNull);
        expect(
          presenter.errorMessage.value,
          'Nao foi possivel localizar a conversa.',
        );
      });
    });

    group('loadInitialMessages', () {
      test('should set messages and nextCursor when fetchMessagesList succeeds', () async {
        final messages = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
          MessageFaker.fakeDto(id: 'msg-2', sentAt: DateTime(2026, 1, 1, 11, 0)),
        ];
        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            body: PaginationResponse<MessageDto>(
              items: messages,
              nextCursor: 'cursor-1',
            ),
          ),
        );

        await presenter.loadInitialMessages();

        expect(presenter.messages.value.length, 2);
        expect(presenter.nextCursor.value, 'cursor-1');
        expect(presenter.errorMessage.value, isNull);
      });

      test('should sort messages by sentAt ascending', () async {
        final messages = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-late', sentAt: DateTime(2026, 1, 1, 12, 0)),
          MessageFaker.fakeDto(id: 'msg-early', sentAt: DateTime(2026, 1, 1, 8, 0)),
        ];
        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            body: PaginationResponse<MessageDto>(items: messages),
          ),
        );

        await presenter.loadInitialMessages();

        expect(presenter.messages.value.first.id, 'msg-early');
        expect(presenter.messages.value.last.id, 'msg-late');
      });

      test('should set error when fetchMessagesList fails', () async {
        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: null,
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            statusCode: 500,
            errorMessage: 'Erro ao carregar mensagens',
          ),
        );

        await presenter.loadInitialMessages();

        expect(presenter.errorMessage.value, 'Erro ao carregar mensagens');
      });
    });

    group('loadMoreMessages', () {
      test('should append older messages and update nextCursor when loading more succeeds', () async {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
        ];
        presenter.nextCursor.value = 'cursor-1';

        final olderMessages = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-0', sentAt: DateTime(2026, 1, 1, 9, 0)),
        ];
        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: 'cursor-1',
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            body: PaginationResponse<MessageDto>(
              items: olderMessages,
              nextCursor: 'cursor-2',
            ),
          ),
        );

        await presenter.loadMoreMessages();

        expect(presenter.messages.value.length, 2);
        expect(presenter.messages.value.first.id, 'msg-0');
        expect(presenter.nextCursor.value, 'cursor-2');
        expect(presenter.isLoadingMore.value, isFalse);
      });

      test('should not load more when canLoadMore is false', () async {
        presenter.nextCursor.value = null;

        await presenter.loadMoreMessages();

        verifyNever(
          () => conversationService.fetchMessagesList(
            chatId: any(named: 'chatId'),
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
          ),
        );
      });

      test('should deduplicate messages when loading more', () async {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
        ];
        presenter.nextCursor.value = 'cursor-1';

        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: 'cursor-1',
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            body: PaginationResponse<MessageDto>(
              items: <MessageDto>[
                MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
                MessageFaker.fakeDto(id: 'msg-0', sentAt: DateTime(2026, 1, 1, 9, 0)),
              ],
              nextCursor: '',
            ),
          ),
        );

        await presenter.loadMoreMessages();

        expect(presenter.messages.value.length, 2);
      });

      test('should not update messages when loadMoreMessages fails', () async {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
        ];
        presenter.nextCursor.value = 'cursor-1';

        when(
          () => conversationService.fetchMessagesList(
            chatId: chatId,
            limit: 30,
            cursor: 'cursor-1',
          ),
        ).thenAnswer(
          (_) async => RestResponse<PaginationResponse<MessageDto>>(
            statusCode: 500,
            errorMessage: 'Erro',
          ),
        );

        await presenter.loadMoreMessages();

        expect(presenter.messages.value.length, 1);
        expect(presenter.isLoadingMore.value, isFalse);
      });
    });

    group('connectChannel', () {
      test('should set isSocketConnected to true when connecting', () async {
        await presenter.connectChannel();

        expect(presenter.isSocketConnected.value, isTrue);
      });

      test('should call listen on conversation channel', () async {
        await presenter.connectChannel();

        verify(
          () => conversationChannel.listen(
            onMessageReceived: any(named: 'onMessageReceived'),
          ),
        ).called(1);
      });

      test('should not subscribe twice when connectChannel called multiple times', () async {
        await presenter.connectChannel();
        await presenter.connectChannel();

        verify(
          () => conversationChannel.listen(
            onMessageReceived: any(named: 'onMessageReceived'),
          ),
        ).called(1);
      });
    });

    group('disconnectChannel', () {
      test('should set isSocketConnected to false when disconnecting', () async {
        await presenter.connectChannel();
        await presenter.disconnectChannel();

        expect(presenter.isSocketConnected.value, isFalse);
      });
    });

    group('onDraftChanged', () {
      test('should update draft signal with new value', () {
        presenter.onDraftChanged('Hello world');

        expect(presenter.draft.value, 'Hello world');
      });
    });

    group('addPendingAttachments', () {
      test('should add attachments to pending list', () {
        final attachment = PendingAttachment(
          localId: 'local-1',
          file: MockFile(),
          kind: 'image',
          name: 'photo.jpg',
          size: 1024,
          status: AttachmentUploadStatus.ready,
        );

        presenter.addPendingAttachments(<PendingAttachment>[attachment]);

        expect(presenter.pendingAttachments.value.length, 1);
        expect(presenter.pendingAttachments.value.first.localId, 'local-1');
      });

      test('should not add when attachments list is empty', () {
        presenter.addPendingAttachments(<PendingAttachment>[]);

        expect(presenter.pendingAttachments.value, isEmpty);
      });

      test('should limit total pending attachments to maxAttachmentsPerMessage', () {
        final attachments = List<PendingAttachment>.generate(
          5,
          (int index) => PendingAttachment(
            localId: 'local-$index',
            file: MockFile(),
            kind: 'image',
            name: 'photo-$index.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        );

        presenter.addPendingAttachments(attachments);

        expect(presenter.pendingAttachments.value.length, 3);
      });
    });

    group('removePendingAttachment', () {
      test('should remove attachment with matching localId', () {
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: MockFile(),
            kind: 'image',
            name: 'photo-1.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
          PendingAttachment(
            localId: 'local-2',
            file: MockFile(),
            kind: 'image',
            name: 'photo-2.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        ];

        presenter.removePendingAttachment('local-1');

        expect(presenter.pendingAttachments.value.length, 1);
        expect(presenter.pendingAttachments.value.first.localId, 'local-2');
      });
    });

    group('sendMessage', () {
      test('should not send when draft is empty and no attachments', () async {
        presenter.isSocketConnected.value = true;

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });

      test('should not send when socket is not connected', () async {
        presenter.draft.value = 'hello';

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });

      test('should not send when already sending', () async {
        presenter.isSending.value = true;
        presenter.draft.value = 'hello';
        presenter.isSocketConnected.value = true;

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });

      test('should not send when ownerId is empty', () async {
        when(() => cacheDriver.get(any())).thenReturn('');
        presenter.draft.value = 'hello';
        presenter.isSocketConnected.value = true;

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });

      test('should emit message via channel when draft is non-empty', () async {
        presenter.draft.value = 'Hello!';
        presenter.isSocketConnected.value = true;

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendMessage();

        final MessageSentEvent captured = verify(
          () => conversationChannel.emitMessageSentEvent(captureAny()),
        ).captured.first as MessageSentEvent;

        expect(captured.messageContent, 'Hello!');
        expect(captured.chatId, chatId);
        expect(captured.senderId, 'owner-id');
        expect(captured.attachments, isEmpty);
      });

      test('should clear draft and isSending after successful send', () async {
        presenter.draft.value = 'Hello!';
        presenter.isSocketConnected.value = true;

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendMessage();

        expect(presenter.draft.value, isEmpty);
        expect(presenter.isSending.value, isFalse);
      });

      test('should send with explicit content parameter', () async {
        presenter.draft.value = 'original';
        presenter.isSocketConnected.value = true;

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendMessage(content: 'Suggested message');

        final MessageSentEvent captured = verify(
          () => conversationChannel.emitMessageSentEvent(captureAny()),
        ).captured.first as MessageSentEvent;

        expect(captured.messageContent, 'Suggested message');
      });
    });

    group('sendSuggestedMessage', () {
      test('should delegate to sendMessage with content', () async {
        presenter.isSocketConnected.value = true;

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendSuggestedMessage('Ola!');

        final MessageSentEvent captured = verify(
          () => conversationChannel.emitMessageSentEvent(captureAny()),
        ).captured.first as MessageSentEvent;

        expect(captured.messageContent, 'Ola!');
      });
    });

    group('sendMessage with attachments', () {
      late MockFile mockFile;

      setUp(() {
        mockFile = MockFile();
        when(() => mockFile.path).thenReturn('/tmp/photo.jpg');
        when(() => mockFile.lengthSync()).thenReturn(1024);
      });

      test('should not upload attachments when pendingMessageId is not set', () async {
        presenter.draft.value = 'With photo';
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: mockFile,
            kind: 'image',
            name: 'photo.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        ];

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendMessage();

        verifyNever(
          () => fileStorageService.generateUploadUrlsForAttachments(
            chatId: any(named: 'chatId'),
            messageId: any(named: 'messageId'),
            attachments: any(named: 'attachments'),
          ),
        );
      });

      test('should not emit socket message when valid pending attachments have no uploaded counterparts', () async {
        presenter.draft.value = 'With photo';
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: mockFile,
            kind: 'image',
            name: 'photo.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        ];

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });

      test('should set isSending to false after sendMessage with unuploaded attachments', () async {
        presenter.draft.value = 'With photo';
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: mockFile,
            kind: 'image',
            name: 'photo.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        ];

        await presenter.sendMessage();

        expect(presenter.isSending.value, isFalse);
      });

      test('should emit socket message when only text and all pending have errors', () async {
        presenter.draft.value = 'Hello';
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: mockFile,
            kind: 'image',
            name: 'photo.jpg',
            size: 1024,
            status: AttachmentUploadStatus.failed,
            errorMessage: 'Imagem excede 2 MB.',
          ),
        ];

        when(
          () => conversationChannel.emitMessageSentEvent(any()),
        ).thenAnswer((_) async {});

        await presenter.sendMessage();

        verifyNever(
          () => fileStorageService.generateUploadUrlsForAttachments(
            chatId: any(named: 'chatId'),
            messageId: any(named: 'messageId'),
            attachments: any(named: 'attachments'),
          ),
        );
      });

      test('should not send when only pending attachments with errors exist and draft is empty', () async {
        presenter.isSocketConnected.value = true;
        presenter.pendingAttachments.value = <PendingAttachment>[
          PendingAttachment(
            localId: 'local-1',
            file: mockFile,
            kind: 'image',
            name: 'photo.jpg',
            size: 1024,
            status: AttachmentUploadStatus.failed,
            errorMessage: 'Imagem excede 2 MB.',
          ),
        ];

        await presenter.sendMessage();

        verifyNever(
          () => conversationChannel.emitMessageSentEvent(any()),
        );
      });
    });

    group('pickImageAttachments', () {
      test('should add picked images to pending attachments', () async {
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('/tmp/photo.jpg');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mediaPickerDriver.pickImages(maxImages: 3),
        ).thenAnswer((_) async => <File>[mockFile]);

        await presenter.pickImageAttachments();

        expect(presenter.pendingAttachments.value.length, 1);
      });

      test('should not pick when remaining slots is zero', () async {
        presenter.pendingAttachments.value = List<PendingAttachment>.generate(
          3,
          (int index) => PendingAttachment(
            localId: 'local-$index',
            file: MockFile(),
            kind: 'image',
            name: 'photo-$index.jpg',
            size: 1024,
            status: AttachmentUploadStatus.ready,
          ),
        );

        await presenter.pickImageAttachments();

        verifyNever(
          () => mediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
        );
      });
    });

    group('pickDocumentAttachments', () {
      test('should add picked documents to pending attachments', () async {
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('/tmp/document.pdf');
        when(() => mockFile.lengthSync()).thenReturn(2048);

        when(
          () => documentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile]);

        await presenter.pickDocumentAttachments();

        expect(presenter.pendingAttachments.value.length, 1);
      });
    });

    group('refreshPresence', () {
      test('should set isRecipientOnline when presence fetch succeeds', () async {
        presenter.chat.value = ChatFaker.fakeDto(
          id: chatId,
          recipient: RecipientFaker.fakeDto(id: 'recipient-1'),
        );

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'recipient-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            body: const OwnerPresenceDto(
              ownerId: 'recipient-1',
              isOnline: true,
              lastSeenAt: null,
            ),
          ),
        );

        await presenter.refreshPresence();

        expect(presenter.isRecipientOnline.value, isTrue);
      });

      test('should set isRecipientOnline to false when recipient id is empty', () async {
        presenter.chat.value = ChatFaker.fakeDto(
          id: chatId,
          recipient: RecipientFaker.fakeDto(id: ''),
        );

        await presenter.refreshPresence();

        expect(presenter.isRecipientOnline.value, isFalse);
      });

      test('should not update isRecipientOnline when presence fetch fails', () async {
        presenter.chat.value = ChatFaker.fakeDto(
          id: chatId,
          recipient: RecipientFaker.fakeDto(id: 'recipient-1'),
        );

        when(
          () => profilingService.fetchOwnerPresence(ownerId: 'recipient-1'),
        ).thenAnswer(
          (_) async => RestResponse<OwnerPresenceDto>(
            statusCode: 500,
            errorMessage: 'Erro',
          ),
        );

        await presenter.refreshPresence();

        expect(presenter.isRecipientOnline.value, isFalse);
      });
    });

    group('retry', () {
      test('should call fetchChats when retry is invoked', () async {
        when(() => conversationService.fetchChats()).thenAnswer(
          (_) async => RestResponse<List<ChatDto>>(body: const <ChatDto>[]),
        );

        presenter.retry();
        await Future<void>.delayed(Duration.zero);

        verify(() => conversationService.fetchChats()).called(1);
      });
    });

    group('onBack', () {
      test('should call goBack when navigation can go back', () {
        when(() => navigationDriver.canGoBack()).thenReturn(true);

        presenter.onBack();

        verify(() => navigationDriver.goBack()).called(1);
      });

      test('should navigate to inbox when navigation cannot go back', () {
        when(() => navigationDriver.canGoBack()).thenReturn(false);

        presenter.onBack();

        verify(() => navigationDriver.goTo(Routes.inbox)).called(1);
      });
    });

    group('isMine', () {
      test('should return true when message senderId differs from recipient id', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(id: 'recipient-id'),
        );

        final message = MessageFaker.fakeDto(senderId: 'owner-id');
        expect(presenter.isMine(message), isTrue);
      });

      test('should return false when message senderId equals recipient id', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(id: 'recipient-id'),
        );

        final message = MessageFaker.fakeDto(senderId: 'recipient-id');
        expect(presenter.isMine(message), isFalse);
      });
    });

    group('formatMessageHour', () {
      test('should format time as HH:mm', () {
        final result = presenter.formatMessageHour(DateTime(2026, 1, 1, 9, 5));
        expect(result, '09:05');
      });

      test('should pad hour and minute with leading zeros', () {
        final result = presenter.formatMessageHour(DateTime(2026, 1, 1, 0, 0));
        expect(result, '00:00');
      });
    });

    group('resolveFileUrl', () {
      test('should return file url from driver when key is non-empty', () {
        when(
          () => fileStorageDriver.getFileUrl('some-key'),
        ).thenReturn('https://cdn.equiny/some-key');

        expect(presenter.resolveFileUrl('some-key'), 'https://cdn.equiny/some-key');
      });

      test('should return empty string when key is empty', () {
        expect(presenter.resolveFileUrl(''), isEmpty);
      });
    });

    group('resolveRecipientAvatarUrl', () {
      test('should return empty string when chat is null', () {
        expect(presenter.resolveRecipientAvatarUrl(), isEmpty);
      });

      test('should return empty string when recipient has no avatar', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(),
        );

        expect(presenter.resolveRecipientAvatarUrl(), isEmpty);
      });

      test('should return file url when recipient has avatar with key', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(
            avatar: const ImageDto(key: 'avatar-key', name: 'avatar.jpg'),
          ),
        );

        when(
          () => fileStorageDriver.getFileUrl('avatar-key'),
        ).thenReturn('https://cdn.equiny/avatar-key');

        expect(
          presenter.resolveRecipientAvatarUrl(),
          'https://cdn.equiny/avatar-key',
        );
      });
    });

    group('resolveRecipientName', () {
      test('should return Conversa when chat is null', () {
        expect(presenter.resolveRecipientName(), 'Conversa');
      });

      test('should return recipient name when available', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(name: 'Maria'),
        );

        expect(presenter.resolveRecipientName(), 'Maria');
      });

      test('should return Conversa when recipient name is empty', () {
        presenter.chat.value = ChatFaker.fakeDto(
          recipient: RecipientFaker.fakeDto(name: '  '),
        );

        expect(presenter.resolveRecipientName(), 'Conversa');
      });
    });

    group('groupedMessages', () {
      test('should group messages by date', () {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
          MessageFaker.fakeDto(id: 'msg-2', sentAt: DateTime(2026, 1, 1, 11, 0)),
          MessageFaker.fakeDto(id: 'msg-3', sentAt: DateTime(2026, 1, 2, 9, 0)),
        ];

        final groups = presenter.groupedMessages.value;

        expect(groups.length, 2);
        expect(groups[0].messages.length, 2);
        expect(groups[1].messages.length, 1);
      });

      test('should sort groups by date ascending', () {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 5, 10, 0)),
          MessageFaker.fakeDto(id: 'msg-2', sentAt: DateTime(2026, 1, 3, 9, 0)),
        ];

        final groups = presenter.groupedMessages.value;

        expect(groups.length, 2);
        expect(groups[0].date, DateTime(2026, 1, 3));
        expect(groups[1].date, DateTime(2026, 1, 5));
      });

      test('should return empty list when no messages', () {
        expect(presenter.groupedMessages.value, isEmpty);
      });

      test('should format date label as HOJE for today', () {
        final now = DateTime.now();
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(
            id: 'msg-1',
            sentAt: DateTime(now.year, now.month, now.day, 10, 0),
          ),
        ];

        expect(presenter.groupedMessages.value.first.label, 'HOJE');
      });

      test('should format date label as ONTEM for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(
            id: 'msg-1',
            sentAt: DateTime(yesterday.year, yesterday.month, yesterday.day, 10, 0),
          ),
        ];

        expect(presenter.groupedMessages.value.first.label, 'ONTEM');
      });

      test('should format date label as DD DE MMM for older dates', () {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(
            id: 'msg-1',
            sentAt: DateTime(2025, 3, 15, 10, 0),
          ),
        ];

        expect(presenter.groupedMessages.value.first.label, '15 DE MAR');
      });
    });

    group('message received via channel', () {
      test('should add received message to messages list', () async {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
        ];

        late void Function(MessageReceivedEvent) onMessageReceivedCallback;
        when(
          () => conversationChannel.listen(
            onMessageReceived: any(named: 'onMessageReceived'),
          ),
        ).thenAnswer((Invocation invocation) {
          onMessageReceivedCallback = invocation.namedArguments[#onMessageReceived]
              as void Function(MessageReceivedEvent);
          return () {};
        });

        await presenter.connectChannel();

        final newMessage = MessageFaker.fakeDto(
          id: 'msg-new',
          sentAt: DateTime(2026, 1, 1, 12, 0),
        );
        onMessageReceivedCallback(
          MessageReceivedEvent(message: newMessage, chatId: chatId),
        );

        expect(presenter.messages.value.length, 2);
        expect(presenter.messages.value.last.id, 'msg-new');
      });

      test('should update upload status map for received message attachments', () async {
        late void Function(MessageReceivedEvent) onMessageReceivedCallback;
        when(
          () => conversationChannel.listen(
            onMessageReceived: any(named: 'onMessageReceived'),
          ),
        ).thenAnswer((Invocation invocation) {
          onMessageReceivedCallback = invocation.namedArguments[#onMessageReceived]
              as void Function(MessageReceivedEvent);
          return () {};
        });

        await presenter.connectChannel();

        final newMessage = MessageFaker.fakeDto(
          id: 'msg-new',
          sentAt: DateTime(2026, 1, 1, 12, 0),
          attachments: <MessageAttachmentDto>[
            const MessageAttachmentDto(
              kind: 'image',
              key: 'file-key',
              name: 'photo.jpg',
              size: 1024,
            ),
          ],
        );
        onMessageReceivedCallback(
          MessageReceivedEvent(message: newMessage, chatId: chatId),
        );

        expect(
          presenter.uploadStatusMap.value['file-key'],
          AttachmentUploadStatus.ready,
        );
      });

      test('should deduplicate received message if already present', () async {
        presenter.messages.value = <MessageDto>[
          MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
        ];

        late void Function(MessageReceivedEvent) onMessageReceivedCallback;
        when(
          () => conversationChannel.listen(
            onMessageReceived: any(named: 'onMessageReceived'),
          ),
        ).thenAnswer((Invocation invocation) {
          onMessageReceivedCallback = invocation.namedArguments[#onMessageReceived]
              as void Function(MessageReceivedEvent);
          return () {};
        });

        await presenter.connectChannel();

        onMessageReceivedCallback(
          MessageReceivedEvent(
            message: MessageFaker.fakeDto(id: 'msg-1', sentAt: DateTime(2026, 1, 1, 10, 0)),
            chatId: chatId,
          ),
        );

        expect(presenter.messages.value.length, 1);
      });
    });
  });
}
