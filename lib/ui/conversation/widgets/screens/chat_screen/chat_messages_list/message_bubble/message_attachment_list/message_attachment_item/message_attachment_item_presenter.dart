import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class DocumentStyle {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;

  const DocumentStyle({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
  });
}

class MessageAttachmentItemPresenter {
  bool isImage(String kind) {
    return kind == 'image';
  }

  bool isDocument(String kind) {
    return kind == 'pdf' ||
        kind == 'docx' ||
        kind == 'txt' ||
        kind == 'document';
  }

  IconData attachmentIconData(String kind) {
    if (kind == 'image') {
      return Icons.image_outlined;
    }
    if (isDocument(kind)) {
      return Icons.description_outlined;
    }
    return Icons.attach_file;
  }

  Color iconColor(String kind) {
    return AppThemeColors.textSecondary;
  }

  DocumentStyle documentStyleFromExtension(String fileName) {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    switch (ext) {
      case 'pdf':
        return const DocumentStyle(
          icon: Icons.picture_as_pdf_outlined,
          iconColor: Color(0xFFFF6B6B),
          iconBackground: Color(0x33FF6B6B),
          label: 'Documento PDF',
        );
      case 'doc':
      case 'docx':
        return const DocumentStyle(
          icon: Icons.article_outlined,
          iconColor: Color(0xFF5B9BD5),
          iconBackground: Color(0x335B9BD5),
          label: 'Documento Word',
        );
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const DocumentStyle(
          icon: Icons.table_chart_outlined,
          iconColor: Color(0xFF70AD47),
          iconBackground: Color(0x3370AD47),
          label: 'Planilha',
        );
      case 'ppt':
      case 'pptx':
        return const DocumentStyle(
          icon: Icons.slideshow_outlined,
          iconColor: Color(0xFFED7D31),
          iconBackground: Color(0x33ED7D31),
          label: 'Apresentação',
        );
      case 'zip':
      case 'rar':
      case '7z':
        return const DocumentStyle(
          icon: Icons.folder_zip_outlined,
          iconColor: Color(0xFFFFC107),
          iconBackground: Color(0x33FFC107),
          label: 'Arquivo compactado',
        );
      case 'txt':
        return const DocumentStyle(
          icon: Icons.text_snippet_outlined,
          iconColor: Color(0xFFB8BBC2),
          iconBackground: Color(0x33B8BBC2),
          label: 'Arquivo de texto',
        );
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return const DocumentStyle(
          icon: Icons.video_file_outlined,
          iconColor: Color(0xFFAB7FD4),
          iconBackground: Color(0x33AB7FD4),
          label: 'Vídeo',
        );
      case 'mp3':
      case 'wav':
      case 'aac':
        return const DocumentStyle(
          icon: Icons.audio_file_outlined,
          iconColor: Color(0xFF4FC3F7),
          iconBackground: Color(0x334FC3F7),
          label: 'Áudio',
        );
      default:
        return const DocumentStyle(
          icon: Icons.insert_drive_file_outlined,
          iconColor: AppThemeColors.textSecondary,
          iconBackground: Color(0x33B8BBC2),
          label: 'Arquivo',
        );
    }
  }

  String formatFileSize(double sizeInBytes) {
    if (sizeInBytes <= 0) return '';
    if (sizeInBytes < 1024) return '${sizeInBytes.toStringAsFixed(0)} B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeInBytes < 1024 * 1024 * 1024) {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeInBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
