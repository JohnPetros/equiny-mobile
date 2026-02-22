import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatHeaderPresenter {
  final FileStorageDriver _fileStorageDriver;

  ChatHeaderPresenter(this._fileStorageDriver);

  bool isOnline(RecipientDto recipient) {
    final DateTime? lastPresenceAt = recipient.lastPresenceAt;
    if (lastPresenceAt == null) {
      return false;
    }

    return DateTime.now().difference(lastPresenceAt).inMinutes < 5;
  }

  String resolveAvatarUrl(RecipientDto recipient) {
    final String key = recipient.avatar?.key ?? '';
    if (key.trim().isEmpty) {
      return '';
    }

    return _fileStorageDriver.getFileUrl(key);
  }

  String resolvePresenceLabel(RecipientDto recipient) {
    if (isOnline(recipient)) {
      return 'online';
    }

    final DateTime? lastPresenceAt = recipient.lastPresenceAt;
    if (lastPresenceAt == null) {
      return 'visto por ultimo em --/-- --:--';
    }

    return 'visto por ultimo em ${_mockFormatDateTime(lastPresenceAt)}';
  }

  String _mockFormatDateTime(DateTime dateTime) {
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

final chatHeaderPresenterProvider = Provider<ChatHeaderPresenter>((ref) {
  return ChatHeaderPresenter(ref.watch(fileStorageDriverProvider));
});
