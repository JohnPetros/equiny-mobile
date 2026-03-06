import 'package:equiny/ui/profiling/components/match_notification_modal/match_horse_avatar/match_horse_avatar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  Widget createWidget({String? imageUrl}) {
    return MaterialApp(
      home: Scaffold(body: MatchHorseAvatarView(imageUrl: imageUrl)),
    );
  }

  group('MatchHorseAvatarView', () {
    testWidgets('should render placeholder icon when image url is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(imageUrl: '   '));

      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('should render network image when image url is provided', (
      WidgetTester tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createWidget(imageUrl: 'https://cdn.equiny/horse-image.jpg'),
        );
        await tester.pumpAndSettle();
      });

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
