import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:signals/signals.dart';

import '../../../../../../fakers/conversation/recipient_faker.dart';

class MockChatHeaderPresenter extends Mock implements ChatHeaderPresenter {}

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockChatHeaderPresenter presenter;
  late Signal<bool> isRecipientOnline;
  late Signal<String> presenceLabel;
  late int backCount;
  late int profileCount;

  setUpAll(() {
    registerFallbackValue(RecipientFaker.fakeDto());
  });

  setUp(() {
    presenter = MockChatHeaderPresenter();
    isRecipientOnline = signal(false);
    presenceLabel = signal('offline');
    backCount = 0;
    profileCount = 0;

    when(() => presenter.isRecipientOnline).thenReturn(isRecipientOnline);
    when(() => presenter.presenceLabel).thenReturn(presenceLabel);
    when(
      () => presenter.resolveAvatarUrl(any()),
    ).thenReturn('');
    when(
      () => presenter.loadPresence(any()),
    ).thenAnswer((_) async {});
  });

  Widget createWidget({RecipientDto? recipient}) {
    return ProviderScope(
      overrides: <Override>[
        chatHeaderPresenterProvider.overrideWithValue(presenter),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: ChatHeaderView(
            recipient: recipient ?? RecipientFaker.fakeDto(name: 'Maria'),
            onBack: () => backCount++,
            onOpenProfile: () => profileCount++,
          ),
        ),
      ),
    );
  }

  group('ChatHeaderView', () {
    testWidgets('should render recipient name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Maria'), findsOneWidget);
    });

    testWidgets('should render presence label', (WidgetTester tester) async {
      presenceLabel.value = 'visto por ultimo em 15/06 14:30';

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('visto por ultimo em 15/06 14:30'), findsOneWidget);
    });

    testWidgets('should render back button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should call onBack when back button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCount, 1);
    });

    testWidgets('should render profile button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Ver perfil'), findsOneWidget);
    });

    testWidgets('should call onOpenProfile when profile button is pressed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver perfil'));
      await tester.pump();

      expect(profileCount, 1);
    });

    testWidgets('should render pets icon when no avatar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('should render avatar image when url is present', (
      WidgetTester tester,
    ) async {
      when(
        () => presenter.resolveAvatarUrl(any()),
      ).thenReturn('https://example.com/avatar.jpg');

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();
      });

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should call loadPresence on init', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verify(() => presenter.loadPresence(any())).called(1);
    });
  });
}
