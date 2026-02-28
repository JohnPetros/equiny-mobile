import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';
import 'package:equiny/core/conversation/enums/attachment_upload_status.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatMessagesListView extends StatefulWidget {
  final List<ChatDateSectionDto> sections;
  final Future<void> Function() onReachTop;
  final bool isLoadingMore;
  final bool Function(MessageDto message) isMine;
  final String Function(DateTime sentAt) formatTime;
  final Map<String, AttachmentUploadStatus> uploadStatusMap;
  final String Function(String key) resolveFileUrl;
  final void Function(String key) onRetryAttachment;
  final void Function(String url) onOpenImage;

  const ChatMessagesListView({
    required this.sections,
    required this.onReachTop,
    required this.isLoadingMore,
    required this.isMine,
    required this.formatTime,
    required this.uploadStatusMap,
    required this.resolveFileUrl,
    required this.onRetryAttachment,
    required this.onOpenImage,
    super.key,
  });

  @override
  State<ChatMessagesListView> createState() => _ChatMessagesListViewState();
}

class _ChatMessagesListViewState extends State<ChatMessagesListView> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(ChatMessagesListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sections != oldWidget.sections) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.pixels <= 100 && !_isLoading) {
          _isLoading = true;
          widget.onReachTop().whenComplete(() => _isLoading = false);
        }
        return false;
      },
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        children: <Widget>[
          if (widget.isLoadingMore)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          for (final section in widget.sections) ...<Widget>[
            DateSeparator(label: section.label),
            for (final message in section.messages)
              MessageBubble(
                message: message.content,
                isMine: widget.isMine(message),
                timeLabel: widget.formatTime(message.sentAt),
                isReadByRecipient: message.isReadByRecipient,
                attachments: message.attachments,
                uploadStatusMap: widget.uploadStatusMap,
                resolveFileUrl: widget.resolveFileUrl,
                onRetryAttachment: widget.onRetryAttachment,
                onOpenImage: widget.onOpenImage,
              ),
          ],
        ],
      ),
    );
  }
}
