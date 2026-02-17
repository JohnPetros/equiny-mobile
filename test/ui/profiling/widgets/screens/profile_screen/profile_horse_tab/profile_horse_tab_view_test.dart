import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_form_section/profile_horse_form_section_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  FormGroup createForm() {
    return ProfileHorseFormSectionPresenter().buildForm();
  }

  Widget createWidget({
    required FormGroup form,
    required bool isHorseActive,
    required bool isLoading,
    required VoidCallback onAddImages,
    required ValueChanged<bool> onToggleHorseActive,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: ProfileHorseTabView(
            form: form,
            images: const <ImageDto>[],
            isHorseActive: isHorseActive,
            isLoading: isLoading,
            isUploading: false,
            isSyncingGallery: false,
            feedReadinessChecklist: const <String>[
              'Adicionar pelo menos 1 foto',
            ],
            horseErrorMessage: null,
            galleryErrorMessage: null,
            onAddImages: onAddImages,
            onSetPrimary: (_) {},
            onRemoveImage: (_) {},
            onRetryGallerySync: () {},
            onToggleHorseActive: onToggleHorseActive,
          ),
        ),
      ),
    );
  }

  group('ProfileHorseTabView', () {
    testWidgets('should render loading indicator when loading data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          isHorseActive: false,
          isLoading: true,
          onAddImages: () {},
          onToggleHorseActive: (_) {},
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('DADOS DO CAVALO'), findsNothing);
    });

    testWidgets('should render gallery form readiness and active sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          isHorseActive: false,
          isLoading: false,
          onAddImages: () {},
          onToggleHorseActive: (_) {},
        ),
      );

      expect(find.text('GALERIA'), findsOneWidget);
      expect(find.text('DADOS DO CAVALO'), findsOneWidget);
      expect(find.text('Pronto para o Feed'), findsOneWidget);
      expect(find.text('Ativar Cavalo'), findsOneWidget);
    });

    testWidgets('should call add images callback when add button is tapped', (
      WidgetTester tester,
    ) async {
      var addImagesCalls = 0;

      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          isHorseActive: false,
          isLoading: false,
          onAddImages: () => addImagesCalls += 1,
          onToggleHorseActive: (_) {},
        ),
      );

      await tester.tap(find.text('Adicionar'));
      await tester.pump();

      expect(addImagesCalls, 1);
    });

    testWidgets('should toggle horse active status when button is tapped', (
      WidgetTester tester,
    ) async {
      bool? toggledValue;

      await tester.pumpWidget(
        createWidget(
          form: createForm(),
          isHorseActive: false,
          isLoading: false,
          onAddImages: () {},
          onToggleHorseActive: (value) => toggledValue = value,
        ),
      );

      await tester.ensureVisible(find.text('Ativar Cavalo'));
      await tester.tap(find.text('Ativar Cavalo'));
      await tester.pump();

      expect(toggledValue, isTrue);
    });
  });
}
