import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MessageBubblePresenter {
  Color bubbleBackground(bool isMine) {
    return isMine ? AppThemeColors.primary : AppThemeColors.surface;
  }

  Color textColor(bool isMine) {
    return isMine ? AppThemeColors.border : AppThemeColors.textSecondary;
  }
}
