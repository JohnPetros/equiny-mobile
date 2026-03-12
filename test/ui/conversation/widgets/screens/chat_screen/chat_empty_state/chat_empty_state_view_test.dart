import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_empty_state/chat_empty_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<String> tappedSuggestions;
  var generateTapCount = 0;

  setUp(() {
    tappedSuggestions = <String>[];
    generateTapCount = 0;
  });

  Widget createWidget({
    bool isGeneratingIcebreaker = false,
    bool showIcebreakerCta = true,
    bool showSuggestionChips = true,
    String? icebreakerErrorMessage,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ChatEmptyStateView(
          onSuggestionTap: (String text) async {
            tappedSuggestions.add(text);
          },
          onGenerateIcebreaker: () async {
            generateTapCount++;
          },
          isGeneratingIcebreaker: isGeneratingIcebreaker,
          showIcebreakerCta: showIcebreakerCta,
          showSuggestionChips: showSuggestionChips,
          icebreakerErrorMessage: icebreakerErrorMessage,
        ),
      ),
    );
  }

  group('ChatEmptyStateView', () {
    testWidgets('should render title text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Inicie a conversa'), findsOneWidget);
    });

    testWidgets('should render subtitle text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(
        find.text('Envie a primeira mensagem ou use uma sugestao.'),
        findsOneWidget,
      );
    });

    testWidgets('should render chat bubble icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('should render three suggestion chips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(ActionChip), findsNWidgets(3));
      expect(find.text('Oi! Tudo bem com seu cavalo?'), findsOneWidget);
      expect(find.text('Podemos falar sobre localizacao?'), findsOneWidget);
      expect(find.text('Tem disponibilidade esta semana?'), findsOneWidget);
    });

    testWidgets(
      'should call onSuggestionTap with correct text when chip is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Oi! Tudo bem com seu cavalo?'));
        await tester.pump();

        expect(tappedSuggestions, <String>['Oi! Tudo bem com seu cavalo?']);
      },
    );

    testWidgets('should call onSuggestionTap for each tapped chip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Podemos falar sobre localizacao?'));
      await tester.pump();

      await tester.tap(find.text('Tem disponibilidade esta semana?'));
      await tester.pump();

      expect(tappedSuggestions, <String>[
        'Podemos falar sobre localizacao?',
        'Tem disponibilidade esta semana?',
      ]);
    });

    testWidgets('should render icebreaker button when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Gerar mensagem quebra-gelo'), findsOneWidget);
    });

    testWidgets('should hide chips when showSuggestionChips is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(showSuggestionChips: false));

      expect(find.byType(ActionChip), findsNothing);
    });

    testWidgets('should call onGenerateIcebreaker when button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Gerar mensagem quebra-gelo'));
      await tester.pump();

      expect(generateTapCount, 1);
    });

    testWidgets('should disable button and show loading while generating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(isGeneratingIcebreaker: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Gerar mensagem quebra-gelo'), findsNothing);
    });

    testWidgets('should show inline error message when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(icebreakerErrorMessage: 'Falha ao gerar sugestao'),
      );

      expect(find.text('Falha ao gerar sugestao'), findsOneWidget);
    });
  });
}
