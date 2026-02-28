import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_image_viewer/chat_image_viewer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  Widget createWidget({String imageUrl = 'https://example.com/image.png'}) {
    return MaterialApp(
      home: ChatImageViewerView(imageUrl: imageUrl),
    );
  }

  group('ChatImageViewerView', () {
    testWidgets('should render Scaffold', (WidgetTester tester) async {
      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidget()),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should render AppBar with back button', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidget()),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render InteractiveViewer for zoom', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidget()),
      );

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('should render network image', (WidgetTester tester) async {
      await mockNetworkImagesFor(
        () => tester.pumpWidget(createWidget()),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
