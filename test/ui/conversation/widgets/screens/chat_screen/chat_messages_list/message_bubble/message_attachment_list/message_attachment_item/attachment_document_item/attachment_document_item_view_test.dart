import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/attachment_document_item/attachment_document_item_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFileStorageDriver extends Mock implements FileStorageDriver {}

void main() {
  late MockFileStorageDriver fileStorageDriver;

  Widget createWidget({
    IconData icon = Icons.picture_as_pdf_outlined,
    Color iconColor = const Color(0xFFFF6B6B),
    Color iconBackground = const Color(0x33FF6B6B),
    String name = 'report.pdf',
    String subtitle = '2.0 KB • Documento PDF',
    String filePath = 'attachments/chat/msg/report.pdf',
  }) {
    return ProviderScope(
      overrides: <Override>[
        fileStorageDriverProvider.overrideWithValue(fileStorageDriver),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: AttachmentDocumentItemView(
            icon: icon,
            iconColor: iconColor,
            iconBackground: iconBackground,
            name: name,
            subtitle: subtitle,
            filePath: filePath,
          ),
        ),
      ),
    );
  }

  setUp(() {
    fileStorageDriver = MockFileStorageDriver();
    when(
      () => fileStorageDriver.getFileUrl(any()),
    ).thenReturn('https://cdn.equiny/report.pdf');
  });

  group('AttachmentDocumentItemView', () {
    testWidgets('should render document name', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('report.pdf'), findsOneWidget);
    });

    testWidgets('should render subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('2.0 KB • Documento PDF'), findsOneWidget);
    });

    testWidgets('should render icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    });

    testWidgets('should not render subtitle when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(subtitle: ''));

      expect(find.text('report.pdf'), findsOneWidget);
    });
  });
}
