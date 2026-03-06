import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ChatAttachmentPickerView extends StatelessWidget {
  final Future<void> Function() onPickImages;
  final Future<void> Function() onPickDocuments;

  const ChatAttachmentPickerView({
    required this.onPickImages,
    required this.onPickDocuments,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onPickImages,
    required Future<void> Function() onPickDocuments,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppThemeColors.surface,
      builder: (BuildContext context) {
        return ChatAttachmentPickerView(
          onPickImages: onPickImages,
          onPickDocuments: onPickDocuments,
        );
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    Future<void> Function() callback,
  ) async {
    Navigator.of(context).pop();
    await callback();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Imagem'),
            onTap: () => _handleAction(context, onPickImages),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Documento'),
            onTap: () => _handleAction(context, onPickDocuments),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
