import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_progress_header/onboarding_progress_header_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({
    required int stepIndex,
    required int totalSteps,
    required String title,
    required String subtitle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingProgressHeaderView(
          stepIndex: stepIndex,
          totalSteps: totalSteps,
          title: title,
          subtitle: subtitle,
        ),
      ),
    );
  }

  group('OnboardingProgressHeaderView', () {
    testWidgets('should render title, subtitle and progress label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          stepIndex: 1,
          totalSteps: 4,
          title: 'Titulo',
          subtitle: 'Subtitulo',
        ),
      );

      expect(find.text('Etapa 2 de 4'), findsOneWidget);
      expect(find.text('Titulo'), findsOneWidget);
      expect(find.text('Subtitulo'), findsOneWidget);

      final Finder bars = find.byWidgetPredicate(
        (Widget widget) =>
            widget is Container && widget.constraints?.minHeight == 6,
      );
      expect(bars, findsNWidgets(4));
    });

    testWidgets('should hide subtitle when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(
          stepIndex: 0,
          totalSteps: 3,
          title: 'Titulo',
          subtitle: '',
        ),
      );

      final Finder emptySubtitle = find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data == '',
      );
      expect(emptySubtitle, findsNothing);
    });

    testWidgets('should clamp total steps when invalid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          stepIndex: 0,
          totalSteps: 0,
          title: 'Titulo',
          subtitle: 'Sub',
        ),
      );

      expect(find.text('Etapa 1 de 1'), findsOneWidget);
    });
  });
}
