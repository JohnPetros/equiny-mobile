import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/message_attachment_item/message_attachment_item_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MessageAttachmentItemPresenter presenter;

  setUp(() {
    presenter = MessageAttachmentItemPresenter();
  });

  group('MessageAttachmentItemPresenter', () {
    test('should identify image kind', () {
      expect(presenter.isImage('image'), isTrue);
      expect(presenter.isImage('pdf'), isFalse);
      expect(presenter.isImage('docx'), isFalse);
    });

    test('should identify document kinds', () {
      expect(presenter.isDocument('pdf'), isTrue);
      expect(presenter.isDocument('docx'), isTrue);
      expect(presenter.isDocument('txt'), isTrue);
      expect(presenter.isDocument('document'), isTrue);
      expect(presenter.isDocument('image'), isFalse);
    });

    test('should return correct icon data for image', () {
      expect(presenter.attachmentIconData('image'), Icons.image_outlined);
    });

    test('should return correct icon data for document', () {
      expect(
        presenter.attachmentIconData('pdf'),
        Icons.description_outlined,
      );
    });

    test('should return fallback icon for unknown kind', () {
      expect(presenter.attachmentIconData('unknown'), Icons.attach_file);
    });

    group('documentStyleFromExtension', () {
      test('should return PDF style for .pdf file', () {
        final style = presenter.documentStyleFromExtension('report.pdf');
        expect(style.label, 'Documento PDF');
        expect(style.icon, Icons.picture_as_pdf_outlined);
      });

      test('should return Word style for .docx file', () {
        final style = presenter.documentStyleFromExtension('report.docx');
        expect(style.label, 'Documento Word');
      });

      test('should return text style for .txt file', () {
        final style = presenter.documentStyleFromExtension('notes.txt');
        expect(style.label, 'Arquivo de texto');
      });

      test('should return default style for unknown extension', () {
        final style = presenter.documentStyleFromExtension('file.xyz');
        expect(style.label, 'Arquivo');
      });

      test('should return default style for file without extension', () {
        final style = presenter.documentStyleFromExtension('noext');
        expect(style.label, 'Arquivo');
      });
    });

    group('formatFileSize', () {
      test('should return empty string for zero size', () {
        expect(presenter.formatFileSize(0), '');
      });

      test('should format bytes', () {
        expect(presenter.formatFileSize(500), '500 B');
      });

      test('should format kilobytes', () {
        expect(presenter.formatFileSize(2048), '2.0 KB');
      });

      test('should format megabytes', () {
        expect(presenter.formatFileSize(1048576), '1.0 MB');
      });

      test('should format gigabytes', () {
        expect(presenter.formatFileSize(1073741824), '1.0 GB');
      });
    });
  });
}
