import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageAttachmentItemPresenter {
  bool isImage(String kind) {
    return kind == 'image';
  }

  bool isDocument(String kind) {
    return kind == 'pdf' || kind == 'docx' || kind == 'txt';
  }

  IconData attachmentIconData(String kind) {
    switch (kind) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'docx':
        return Icons.description_outlined;
      case 'txt':
        return Icons.article_outlined;
      default:
        return Icons.attach_file;
    }
  }

  Color iconColor(String kind) {
    if (kind == 'pdf') {
      return AppThemeColors.error;
    }
    return AppThemeColors.textSecondary;
  }
}
