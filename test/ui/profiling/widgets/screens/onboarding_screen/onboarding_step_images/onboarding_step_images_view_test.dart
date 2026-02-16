import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_images/onboarding_step_images_view.dart';
import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../fakers/profiling/image_faker.dart';

void main() {
  Widget createWidget({
    required bool isUploading,
    required String? errorMessage,
    required List<ImageDto> images,
    required VoidCallback onAddImages,
    required VoidCallback onRetry,
    required void Function(ImageDto) onRemoveImage,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OnboardingStepImagesView(
          images: images,
          isUploading: isUploading,
          errorMessage: errorMessage,
          onAddImages: onAddImages,
          onRetry: onRetry,
          onRemoveImage: onRemoveImage,
        ),
      ),
    );
  }

  group('OnboardingStepImagesView', () {
    testWidgets('should disable add button when uploading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          isUploading: true,
          errorMessage: null,
          images: const <ImageDto>[],
          onAddImages: () {},
          onRetry: () {},
          onRemoveImage: (_) {},
        ),
      );

      final Finder buttonFinder = find.widgetWithText(
        OutlinedButton,
        'Enviando...',
      );
      final OutlinedButton button = tester.widget(buttonFinder);

      expect(button.onPressed, isNull);
    });

    testWidgets('should show error message and retry action', (
      WidgetTester tester,
    ) async {
      var retryCalls = 0;

      await tester.pumpWidget(
        createWidget(
          isUploading: false,
          errorMessage: 'Falha ao enviar',
          images: const <ImageDto>[],
          onAddImages: () {},
          onRetry: () => retryCalls += 1,
          onRemoveImage: (_) {},
        ),
      );

      expect(find.text('Falha ao enviar'), findsOneWidget);

      await tester.tap(find.text('Tentar novamente'));
      await tester.pump();

      expect(retryCalls, 1);
    });

    testWidgets('should show empty state when there are no images', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          isUploading: false,
          errorMessage: null,
          images: const <ImageDto>[],
          onAddImages: () {},
          onRetry: () {},
          onRemoveImage: (_) {},
        ),
      );

      expect(find.text('Nenhuma imagem enviada ainda.'), findsOneWidget);
    });

    testWidgets('should remove image when delete is tapped', (
      WidgetTester tester,
    ) async {
      final image = ImageFaker.fakeDto(key: 'img-1', name: 'cavalo.png');
      ImageDto? removedImage;

      await tester.pumpWidget(
        createWidget(
          isUploading: false,
          errorMessage: null,
          images: <ImageDto>[image],
          onAddImages: () {},
          onRetry: () {},
          onRemoveImage: (img) => removedImage = img,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(removedImage, image);
    });
  });
}
