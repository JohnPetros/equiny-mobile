import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatInputBarView extends StatefulWidget {
  final String draft;
  final bool isSending;
  final void Function(String value) onChanged;
  final Future<void> Function() onSend;

  const ChatInputBarView({
    required this.draft,
    required this.isSending,
    required this.onChanged,
    required this.onSend,
    super.key,
  });

  @override
  State<ChatInputBarView> createState() => _ChatInputBarViewState();
}

class _ChatInputBarViewState extends State<ChatInputBarView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.draft);
  }

  @override
  void didUpdateWidget(covariant ChatInputBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.draft) {
      _controller.text = widget.draft;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppThemeColors.background,
        border: Border(top: BorderSide(color: AppThemeColors.border)),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.add_circle_outline),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(hintText: 'Digite uma mensagem'),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            onPressed: widget.isSending ? null : widget.onSend,
            icon: widget.isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
