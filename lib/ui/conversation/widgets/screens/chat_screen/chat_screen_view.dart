import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_error_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_loading_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_header/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_empty_state/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_input_bar/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ChatScreenView extends ConsumerWidget {
  final String chatId;

  const ChatScreenView({required this.chatId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChatScreenPresenter presenter = ref.watch(
      chatScreenPresenterProvider(chatId),
    );

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
                      ),
              ),
              ChatInputBar(
                draft: presenter.draft.value,
                isSending: presenter.isSending.value,
                onChanged: presenter.onDraftChanged,
                onSend: presenter.sendMessage,
              ),
            ],
          );
        }),
      ),
    );
  }
}
