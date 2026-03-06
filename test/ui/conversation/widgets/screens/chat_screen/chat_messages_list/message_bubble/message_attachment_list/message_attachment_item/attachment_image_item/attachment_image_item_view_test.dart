import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_image_item/attachment_image_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  late String openedUrl;

  Widget createWidget({
    String name = 'photo.jpg',
    String resolvedUrl = 'https://cdn.equiny/photo.jpg',
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AttachmentImageItemView(
          name: name,
          resolvedUrl: resolvedUrl,
          onOpenImage: (String url) => openedUrl = url,
        ),
      ),
    );
  }

  setUp(() {
    openedUrl = '';
  });

  group('AttachmentImageItemView', () {
    testWidgets('should render file name', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());

        expect(find.text('photo.jpg'), findsOneWidget);
      });
    });

    testWidgets('should render network image when url is not empty', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());

        expect(find.byType(Image), findsOneWidget);
      });
    });

    testWidgets('should render placeholder icon when url is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(resolvedUrl: ''));

      final placeholderIcons = find.byIcon(Icons.image_outlined);
      expect(placeholderIcons, findsNWidgets(2));
    });

    testWidgets('should call onOpenImage when tapped with valid url', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.byType(GestureDetector).first);
        await tester.pump();

        expect(openedUrl, 'https://cdn.equiny/photo.jpg');
      });
    });
  });
}
