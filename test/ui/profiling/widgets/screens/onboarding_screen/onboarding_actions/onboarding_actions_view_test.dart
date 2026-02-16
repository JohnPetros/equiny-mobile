import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_actions/onboarding_actions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({
    bool isFirstStep = false,
    bool isLastStep = false,
    bool canAdvance = false,
    bool canFinish = false,
    bool isLoading = false,
    VoidCallback? onBack,
    VoidCallback? onNext,
    VoidCallback? onFinish,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingActionsView(
          isFirstStep: isFirstStep,
          isLastStep: isLastStep,
          canAdvance: canAdvance,
          canFinish: canFinish,
          isLoading: isLoading,
          onBack: onBack ?? () {},
          onNext: onNext ?? () {},
          onFinish: onFinish ?? () {},
        ),
      ),
    );
  }

  group('OnboardingActionsView', () {
    testWidgets('should disable back button when first step', (
      WidgetTester tester,
    ) async {
      var backCalls = 0;

      await tester.pumpWidget(
        createWidget(isFirstStep: true, onBack: () => backCalls += 1),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalls, 0);
    });

    testWidgets('should enable advance button when allowed', (
      WidgetTester tester,
    ) async {
      var nextCalls = 0;

      await tester.pumpWidget(
        createWidget(canAdvance: true, onNext: () => nextCalls += 1),
      );

      await tester.tap(find.text('Avancar'));
      await tester.pump();

      expect(nextCalls, 1);
    });

    testWidgets('should call onFinish when last step and enabled', (
      WidgetTester tester,
    ) async {
      var finishCalls = 0;

      await tester.pumpWidget(
        createWidget(
          isLastStep: true,
          canFinish: true,
          onFinish: () => finishCalls += 1,
        ),
      );

      await tester.tap(find.text('Concluir cadastro'));
      await tester.pump();

      expect(finishCalls, 1);
    });

    testWidgets('should show loading indicator and disable actions', (
      WidgetTester tester,
    ) async {
      var backCalls = 0;
      var nextCalls = 0;

      await tester.pumpWidget(
        createWidget(
          isLoading: true,
          onBack: () => backCalls += 1,
          onNext: () => nextCalls += 1,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.text('Avancar'));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalls, 0);
      expect(nextCalls, 0);
    });
  });
}
