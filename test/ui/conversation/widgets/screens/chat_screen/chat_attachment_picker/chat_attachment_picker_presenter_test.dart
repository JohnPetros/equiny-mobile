import 'dart:io';

import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/core/shared/interfaces/document_picker_driver.dart';
import 'package:equiny/core/shared/interfaces/media_picker_driver.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_presenter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMediaPickerDriver extends Mock implements MediaPickerDriver {}

class MockDocumentPickerDriver extends Mock implements DocumentPickerDriver {}

class MockFile extends Mock implements File {}

void main() {
  late MockMediaPickerDriver mockMediaPickerDriver;
  late MockDocumentPickerDriver mockDocumentPickerDriver;
  late ChatAttachmentPickerPresenter presenter;

  setUp(() {
    mockMediaPickerDriver = MockMediaPickerDriver();
    mockDocumentPickerDriver = MockDocumentPickerDriver();
    presenter = ChatAttachmentPickerPresenter(
      mockMediaPickerDriver,
      mockDocumentPickerDriver,
    );
  });

  group('ChatAttachmentPickerPresenter', () {
    group('pickImages', () {
      test('should return empty list when remainingSlots is zero', () async {
        final result = await presenter.pickImages(remainingSlots: 0);

        expect(result, isEmpty);
        verifyNever(
          () => mockMediaPickerDriver.pickImages(maxImages: any(named: 'maxImages')),
        );
      });

      test('should return empty list when remainingSlots is negative', () async {
        final result = await presenter.pickImages(remainingSlots: -1);

        expect(result, isEmpty);
      });

      test('should call pickImages with correct maxImages', () async {
        when(
          () => mockMediaPickerDriver.pickImages(maxImages: 2),
        ).thenAnswer((_) async => <File>[]);

        await presenter.pickImages(remainingSlots: 2);

        verify(
          () => mockMediaPickerDriver.pickImages(maxImages: 2),
        ).called(1);
      });

      test('should return pending attachments for picked images', () async {
        final mockFile = MockFile();
        final separator = Platform.pathSeparator;
        when(
          () => mockFile.path,
        ).thenReturn('${separator}path${separator}to${separator}image.jpg');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mockMediaPickerDriver.pickImages(maxImages: 3),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickImages(remainingSlots: 3);

        expect(result.length, 1);
        expect(result.first.kind, 'image');
        expect(result.first.name, 'image.jpg');
        expect(result.first.size, 1024.0);
        expect(result.first.status, AttachmentUploadStatus.ready);
        expect(result.first.errorMessage, isNull);
      });

      test('should mark image as failed when exceeding size limit', () async {
        final mockFile = MockFile();
        final separator = Platform.pathSeparator;
        when(
          () => mockFile.path,
        ).thenReturn('${separator}path${separator}to${separator}large.jpg');
        when(() => mockFile.lengthSync()).thenReturn(3 * 1024 * 1024);

        when(
          () => mockMediaPickerDriver.pickImages(maxImages: 3),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickImages(remainingSlots: 3);

        expect(result.first.status, AttachmentUploadStatus.failed);
        expect(result.first.errorMessage, 'Imagem excede 2 MB.');
      });
    });

    group('pickDocuments', () {
      test('should return empty list when remainingSlots is zero', () async {
        final result = await presenter.pickDocuments(remainingSlots: 0);

        expect(result, isEmpty);
        verifyNever(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        );
      });

      test('should call pickDocuments with allowed extensions', () async {
        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: ChatAttachmentPickerPresenter.allowedDocumentExtensions,
          ),
        ).thenAnswer((_) async => <File>[]);

        await presenter.pickDocuments(remainingSlots: 3);

        verify(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: ChatAttachmentPickerPresenter.allowedDocumentExtensions,
          ),
        ).called(1);
      });

      test('should respect remainingSlots by truncating file list', () async {
        final separator = Platform.pathSeparator;
        final mockFile1 = MockFile();
        when(() => mockFile1.path).thenReturn('${separator}path${separator}to${separator}doc1.pdf');
        when(() => mockFile1.lengthSync()).thenReturn(1024);

        final mockFile2 = MockFile();
        when(() => mockFile2.path).thenReturn('${separator}path${separator}to${separator}doc2.pdf');
        when(() => mockFile2.lengthSync()).thenReturn(1024);

        final mockFile3 = MockFile();
        when(() => mockFile3.path).thenReturn('${separator}path${separator}to${separator}doc3.pdf');
        when(() => mockFile3.lengthSync()).thenReturn(1024);

        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile1, mockFile2, mockFile3]);

        final result = await presenter.pickDocuments(remainingSlots: 1);

        expect(result.length, 1);
      });

      test('should resolve kind from pdf extension', () async {
        final separator = Platform.pathSeparator;
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('${separator}path${separator}to${separator}report.pdf');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickDocuments(remainingSlots: 3);

        expect(result.first.kind, 'pdf');
      });

      test('should resolve kind from docx extension', () async {
        final separator = Platform.pathSeparator;
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('${separator}path${separator}to${separator}report.docx');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickDocuments(remainingSlots: 3);

        expect(result.first.kind, 'docx');
      });

      test('should resolve kind from txt extension', () async {
        final separator = Platform.pathSeparator;
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('${separator}path${separator}to${separator}notes.txt');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickDocuments(remainingSlots: 3);

        expect(result.first.kind, 'txt');
      });

      test('should resolve unknown extension as document', () async {
        final separator = Platform.pathSeparator;
        final mockFile = MockFile();
        when(() => mockFile.path).thenReturn('${separator}path${separator}to${separator}data.csv');
        when(() => mockFile.lengthSync()).thenReturn(1024);

        when(
          () => mockDocumentPickerDriver.pickDocuments(
            allowedExtensions: any(named: 'allowedExtensions'),
          ),
        ).thenAnswer((_) async => <File>[mockFile]);

        final result = await presenter.pickDocuments(remainingSlots: 3);

        expect(result.first.kind, 'document');
      });
    });

    group('validateFileSize', () {
      test('should return null for image within limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(1 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'image');

        expect(result, isNull);
      });

      test('should return error for image exceeding limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(3 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'image');

        expect(result, 'Imagem excede 2 MB.');
      });

      test('should return null for pdf within limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(2 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'pdf');

        expect(result, isNull);
      });

      test('should return error for pdf exceeding limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(4 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'pdf');

        expect(result, 'PDF excede 3 MB.');
      });

      test('should return null for docx within limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(1 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'docx');

        expect(result, isNull);
      });

      test('should return error for docx exceeding limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(3 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'docx');

        expect(result, 'DOCX excede 2 MB.');
      });

      test('should return null for txt within limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(50 * 1024);

        final result = presenter.validateFileSize(mockFile, 'txt');

        expect(result, isNull);
      });

      test('should return error for txt exceeding limit', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(200 * 1024);

        final result = presenter.validateFileSize(mockFile, 'txt');

        expect(result, 'TXT excede 100 KB.');
      });

      test('should return null for unknown kind', () {
        final mockFile = MockFile();
        when(() => mockFile.lengthSync()).thenReturn(10 * 1024 * 1024);

        final result = presenter.validateFileSize(mockFile, 'unknown');

        expect(result, isNull);
      });
    });

    group('constants', () {
      test('should have maxAttachmentsPerMessage as 3', () {
        expect(ChatAttachmentPickerPresenter.maxAttachmentsPerMessage, 3);
      });

      test('should have imageMaxBytes as 2 MB', () {
        expect(ChatAttachmentPickerPresenter.imageMaxBytes, 2 * 1024 * 1024);
      });

      test('should have pdfMaxBytes as 3 MB', () {
        expect(ChatAttachmentPickerPresenter.pdfMaxBytes, 3 * 1024 * 1024);
      });

      test('should have allowed document extensions', () {
        expect(
          ChatAttachmentPickerPresenter.allowedDocumentExtensions,
          <String>['pdf', 'docx', 'txt'],
        );
      });
    });
  });
}
