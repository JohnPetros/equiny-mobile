import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubblePresenter {
  Color bubbleBackground(bool isMine) {
    return isMine ? AppThemeColors.primary : AppThemeColors.surface;
  }

  Color textColor(bool isMine) {
    return isMine ? AppThemeColors.border : AppThemeColors.textSecondary;
  }

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
}
