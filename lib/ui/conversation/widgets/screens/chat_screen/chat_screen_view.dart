import 'dart:async';

import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_error_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_loading_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_empty_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_image_viewer/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatScreenView extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreenView({required this.chatId, super.key});

  @override
  ConsumerState<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends ConsumerState<ChatScreenView> {
  bool _isScreenInFocus = false;

  Future<void> _openAttachmentPicker(ChatScreenPresenter presenter) async {
    await ChatAttachmentPicker.show(
      context,
      onPickImages: presenter.pickImageAttachments,
      onPickDocuments: presenter.pickDocumentAttachments,
    );
  }

  Future<void> _openImageViewer(String imageUrl) async {
    if (imageUrl.isEmpty) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatImageViewer(imageUrl: imageUrl),
      ),
    );
  }

  void _syncChannelConnection(
    ChatScreenPresenter presenter,
    bool shouldBeConnected,
  ) {
    if (_isScreenInFocus == shouldBeConnected) {
      return;
    }

    _isScreenInFocus = shouldBeConnected;
    if (shouldBeConnected) {
      unawaited(presenter.loadInitialMessages());
      unawaited(presenter.connectChannel());
      return;
    }

    unawaited(presenter.disconnectChannel());
  }

  @override
  Widget build(BuildContext context) {
    final ChatScreenPresenter presenter = ref.watch(
      chatScreenPresenterProvider(widget.chatId),
    );
    final bool isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncChannelConnection(presenter, isCurrentRoute);
    });

    return Scaffold(
      backgroundColor: AppThemeColors.background,
      body: SafeArea(
        child: Watch((BuildContext context) {
          if (presenter.isLoadingInitial.value) {
            return const ChatLoadingState();
          }

          if (presenter.errorMessage.value != null &&
              presenter.chat.value == null) {
            return ChatErrorState(
              message:
                  presenter.errorMessage.value ?? 'Erro ao carregar conversa.',
              onRetry: presenter.retry,
            );
          }

          return Column(
            children: <Widget>[
              if (presenter.chat.value?.recipient != null)
                ChatHeader(
                  recipient: presenter.chat.value!.recipient,
                  onBack: presenter.onBack,
                  onOpenProfile: () {},
                ),
              Expanded(
                child: presenter.showEmptyState.value
                    ? ChatEmptyState(
                        onSuggestionTap: presenter.sendSuggestedMessage,
                      )
                    : ChatMessagesList(
                        sections: presenter.groupedMessages.value,
                        isLoadingMore: presenter.isLoadingMore.value,
                        onReachTop: presenter.loadMoreMessages,
                        isMine: presenter.isMine,
                        formatTime: presenter.formatMessageHour,
                        uploadStatusMap: presenter.uploadStatusMap.value,
                        resolveFileUrl: presenter.resolveFileUrl,
                        onRetryAttachment: presenter.retryAttachmentUpload,
                        onOpenImage: (String url) =>
                            unawaited(_openImageViewer(url)),
                      ),
              ),
              ChatInputBar(
                draft: presenter.draft.value,
                isSending: presenter.isSending.value,
                pendingAttachments: presenter.pendingAttachments.value,
                onChanged: presenter.onDraftChanged,
                onSend: presenter.sendMessage,
                onAttachmentTap: () => _openAttachmentPicker(presenter),
                onRemoveAttachment: presenter.removePendingAttachment,
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    if (_isScreenInFocus) {
      final ChatScreenPresenter presenter = ref.read(
        chatScreenPresenterProvider(widget.chatId),
      );
      unawaited(presenter.disconnectChannel());
    }
    super.dispose();
  }
}
