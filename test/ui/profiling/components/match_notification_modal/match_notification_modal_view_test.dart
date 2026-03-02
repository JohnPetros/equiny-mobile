import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/profiling/components/match_notification_modal/match_notification_modal_presenter.dart';
import 'package:equiny/ui/profiling/components/match_notification_modal/match_notification_modal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:signals/signals.dart';

import '../../../../fakers/profiling/horse_match_faker.dart';

class MockMatchNotificationModalPresenter extends Mock
    implements MatchNotificationModalPresenter {}

void main() {
  late MockMatchNotificationModalPresenter presenter;
  late Signal<HorseMatchDto?> currentMatch;
  late Signal<bool> isCreatingChat;
  late Signal<String?> chatError;
  late Signal<String?> horseImageUrl;

  Widget createWidget() {
    return ProviderScope(
      overrides: <Override>[
        matchNotificationModalPresenterProvider.overrideWithValue(presenter),
      ],
      child: const MaterialApp(home: MatchNotificationModalView()),
    );
  }

  setUp(() {
    presenter = MockMatchNotificationModalPresenter();
    currentMatch = signal<HorseMatchDto?>(null);
    isCreatingChat = signal(false);
    chatError = signal<String?>(null);
    horseImageUrl = signal<String?>('https://cdn.equiny/horse-image.jpg');

    when(() => presenter.currentMatch).thenReturn(currentMatch);
    when(() => presenter.isCreatingChat).thenReturn(isCreatingChat);
    when(() => presenter.chatError).thenReturn(chatError);
    when(() => presenter.horseImageUrl).thenReturn(horseImageUrl);
    when(() => presenter.handleClose()).thenReturn(true);
    when(() => presenter.handleContinue()).thenReturn(true);
    when(() => presenter.handleGoToChat()).thenAnswer((_) async => true);
  });

  group('MatchNotificationModalView', () {
    testWidgets('should render empty content when there is no current match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Deu match!'), findsNothing);
    });

    testWidgets('should render match details when current match exists', (
      WidgetTester tester,
    ) async {
      currentMatch.value = HorseMatchFaker.fakeDto(ownerHorseName: 'Aurora');

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();
      });

      expect(find.text('Deu match!'), findsOneWidget);
      expect(find.text('Você e Aurora curtiram um ao outro.'), findsOneWidget);
      expect(find.text('Ir para o chat'), findsOneWidget);
      expect(find.text('Continuar deslizando'), findsOneWidget);
    });

    testWidgets(
      'should call continue and close modal when continue button is tapped',
      (WidgetTester tester) async {
        currentMatch.value = HorseMatchFaker.fakeDto(ownerHorseName: 'Aurora');

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createWidget());
          await tester.pumpAndSettle();
        });

        await tester.tap(find.text('Continuar deslizando'));
        await tester.pump();

        verify(() => presenter.handleContinue()).called(1);
      },
    );

    testWidgets('should show loading state in chat button when creating chat', (
      WidgetTester tester,
    ) async {
      currentMatch.value = HorseMatchFaker.fakeDto(ownerHorseName: 'Aurora');
      isCreatingChat.value = true;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pump(const Duration(milliseconds: 500));
      });

      expect(find.text('Abrindo chat...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show chat error message when chat error is not empty', (
      WidgetTester tester,
    ) async {
      currentMatch.value = HorseMatchFaker.fakeDto(ownerHorseName: 'Aurora');
      chatError.value = 'Nao foi possivel abrir o chat.';

      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();
      });

      expect(find.text('Nao foi possivel abrir o chat.'), findsOneWidget);
    });
  });
}
