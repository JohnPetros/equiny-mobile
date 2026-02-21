import 'package:equiny/core/conversation/dtos/entities/chat_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:signals/signals.dart';

import '../../../../../fakers/conversation/chat_faker.dart';

class MockInboxScreenPresenter extends Mock implements InboxScreenPresenter {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockInboxScreenPresenter presenter;
  late MockFileStorageDriver fileStorageDriver;
  late Signal<List<ChatDto>> chats;
  late Signal<bool> isLoadingInitial;
  late Signal<String?> errorMessage;
  late Signal<List<ChatDto>> sortedChats;
  late Signal<int> unreadConversationsCount;
  late Signal<bool> isEmptyState;
  late Signal<bool> hasError;

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        inboxScreenPresenterProvider.overrideWithValue(presenter),
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: const MaterialApp(home: InboxScreenView()),
    );
  }

  setUpAll(() {
    registerFallbackValue(ChatFaker.fakeDto());
  });

  setUp(() {
    presenter = MockInboxScreenPresenter();
    fileStorageDriver = MockFileStorageDriver();
    chats = signal(<ChatDto>[]);
    isLoadingInitial = signal(false);
    errorMessage = signal(null);
    sortedChats = signal(<ChatDto>[]);
    unreadConversationsCount = signal(0);
    isEmptyState = signal(false);
    hasError = signal(false);

    when(() => presenter.chats).thenReturn(chats);
    when(() => presenter.isLoadingInitial).thenReturn(isLoadingInitial);
    when(() => presenter.errorMessage).thenReturn(errorMessage);
    when(() => presenter.sortedChats).thenReturn(sortedChats);
    when(
      () => presenter.unreadConversationsCount,
    ).thenReturn(unreadConversationsCount);
    when(() => presenter.isEmptyState).thenReturn(isEmptyState);
    when(() => presenter.hasError).thenReturn(hasError);
    when(() => presenter.retry()).thenAnswer((_) async {});
    when(() => presenter.goToMatches()).thenReturn(null);
    when(() => presenter.openChat(any())).thenReturn(null);
    when(() => presenter.buildRecipientInitials(any())).thenReturn('RN');
    when(() => presenter.formatRelativeTimestamp(any())).thenReturn('10:30');
    when(() => fileStorageDriver.getImageUrl(any())).thenReturn('');
  });

  group('InboxScreenView', () {
    testWidgets('should render loading state when initial load is active', (
      WidgetTester tester,
    ) async {
      isLoadingInitial.value = true;

      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should render error state and retry on tap', (
      WidgetTester tester,
    ) async {
      hasError.value = true;
      errorMessage.value = 'Erro ao carregar';

      await tester.pumpWidget(createWidget());

      expect(find.text('Erro ao carregar'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tentar novamente'));
      await tester.pump();

      verify(() => presenter.retry()).called(1);
    });

    testWidgets('should render empty state and go to matches on tap', (
      WidgetTester tester,
    ) async {
      isEmptyState.value = true;

      await tester.pumpWidget(createWidget());

      expect(find.text('Sem conversas ainda'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Ir para Matches'));
      await tester.pump();

      verify(() => presenter.goToMatches()).called(1);
    });

    testWidgets('should render content state and open chat on item tap', (
      WidgetTester tester,
    ) async {
      sortedChats.value = <ChatDto>[
        ChatFaker.fakeDto(id: 'chat-1', unreadCount: 1),
      ];
      unreadConversationsCount.value = 1;

      await tester.pumpWidget(createWidget());

      expect(find.text('Conversas'), findsOneWidget);
      expect(find.text('Recipient Name'), findsOneWidget);

      await tester.tap(find.text('Recipient Name'));
      await tester.pump();

      verify(() => presenter.openChat(any())).called(1);
    });
  });
}
