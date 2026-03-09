import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/profile_owner_avatar_source_sheet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidget({
    required VoidCallback onPickFromCamera,
    required VoidCallback onPickFromGallery,
    required bool showRemoveOption,
    VoidCallback? onRemovePhoto,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return TextButton(
              onPressed: () {
                ProfileOwnerAvatarSourceSheetView.show(
                  context,
                  onPickFromCamera: onPickFromCamera,
                  onPickFromGallery: onPickFromGallery,
                  showRemoveOption: showRemoveOption,
                  onRemovePhoto: onRemovePhoto,
                );
              },
              child: const Text('Abrir'),
            );
          },
        ),
      ),
    );
  }

  group('ProfileOwnerAvatarSourceSheetView', () {
    testWidgets('should render camera and gallery options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          onPickFromCamera: () {},
          onPickFromGallery: () {},
          showRemoveOption: false,
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Escolha uma opcao'), findsOneWidget);
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
      expect(find.text('Remover foto'), findsNothing);
    });

    testWidgets('should call camera callback when camera option is tapped', (
      WidgetTester tester,
    ) async {
      var didPickFromCamera = false;

      await tester.pumpWidget(
        createWidget(
          onPickFromCamera: () => didPickFromCamera = true,
          onPickFromGallery: () {},
          showRemoveOption: false,
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tirar foto'));
      await tester.pumpAndSettle();

      expect(didPickFromCamera, isTrue);
      expect(find.text('Escolha uma opcao'), findsNothing);
    });

    testWidgets('should render and call remove callback when enabled', (
      WidgetTester tester,
    ) async {
      var didRemovePhoto = false;

      await tester.pumpWidget(
        createWidget(
          onPickFromCamera: () {},
          onPickFromGallery: () {},
          showRemoveOption: true,
          onRemovePhoto: () => didRemovePhoto = true,
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();

      expect(find.text('Remover foto'), findsOneWidget);

      await tester.tap(find.text('Remover foto'));
      await tester.pumpAndSettle();

      expect(didRemovePhoto, isTrue);
    });
  });
}
