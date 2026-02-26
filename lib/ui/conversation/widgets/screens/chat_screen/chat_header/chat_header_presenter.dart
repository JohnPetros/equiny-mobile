import 'package:equiny/core/conversation/dtos/entities/recipient_dto.dart';
import 'package:equiny/core/profiling/events/owner_presence_registered_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_unregistered_event.dart';
import 'package:equiny/core/profiling/interfaces/profiling_channel.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/file-storage-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/websocket/channels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class ChatHeaderPresenter {
  final FileStorageDriver _fileStorageDriver;
  final ProfilingService _profilingService;
  final ProfilingChannel _profilingChannel;
  void Function()? _unsubscribePresence;
  String _listenedRecipientId = '';

  final Signal<bool> isRecipientOnline = signal(false);
  final Signal<String> presenceLabel = signal('');

  ChatHeaderPresenter(
    this._fileStorageDriver,
    this._profilingService,
    this._profilingChannel,
  );

  Future<void> loadPresence(RecipientDto recipient) async {
    final String recipientId = recipient.id ?? '';
    if (recipientId.isEmpty) {
      disconnectRealtime();
      isRecipientOnline.value = false;
      presenceLabel.value = 'visto por ultimo em --/-- --:--';
      return;
    }

    _connectRealtime(recipientId);

    final response = await _profilingService.fetchOwnerPresence(
      ownerId: recipientId,
    );
    if (response.isFailure) {
      isRecipientOnline.value = false;
      _updatePresenceLabel(recipient.lastPresenceAt);
      return;
    }

    isRecipientOnline.value = response.body.isOnline;
    if (response.body.isOnline) {
      presenceLabel.value = 'online';
    } else {
      _updatePresenceLabel(response.body.lastSeenAt);
    }
  }

  void _connectRealtime(String recipientId) {
    if (_listenedRecipientId == recipientId && _unsubscribePresence != null) {
      return;
    }

    _unsubscribePresence?.call();
    _listenedRecipientId = recipientId;
    _unsubscribePresence = _profilingChannel.listen(
      onOwnerPresenceRegistered: _onOwnerPresenceRegistered,
      onOwnerPresenceUnregistered: _onOwnerPresenceUnregistered,
    );
  }

  void _onOwnerPresenceRegistered(OwnerPresenceRegisteredEvent event) {
    if (event.payload.ownerId != _listenedRecipientId) {
      return;
    }

    isRecipientOnline.value = true;
    presenceLabel.value = 'online';
  }

  void _onOwnerPresenceUnregistered(OwnerPresenceUnregisteredEvent event) {
    if (event.payload.ownerId != _listenedRecipientId) {
      return;
    }

    isRecipientOnline.value = false;
    _updatePresenceLabel(DateTime.now());
  }

  void disconnectRealtime() {
    _unsubscribePresence?.call();
    _unsubscribePresence = null;
    _listenedRecipientId = '';
  }

  void _updatePresenceLabel(DateTime? lastSeenAt) {
    if (lastSeenAt == null) {
      presenceLabel.value = 'visto por ultimo em --/-- --:--';
      return;
    }
    presenceLabel.value = 'visto por ultimo em ${_formatDateTime(lastSeenAt)}';
  }

  String resolveAvatarUrl(RecipientDto recipient) {
    final String key = recipient.avatar?.key ?? '';
    if (key.trim().isEmpty) {
      return '';
    }

    return _fileStorageDriver.getFileUrl(key);
  }

  String _formatDateTime(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();
    final String day = localDateTime.day.toString().padLeft(2, '0');
    final String month = localDateTime.month.toString().padLeft(2, '0');
    final String hour = localDateTime.hour.toString().padLeft(2, '0');
    final String minute = localDateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

final chatHeaderPresenterProvider = Provider.autoDispose<ChatHeaderPresenter>((
  ref,
) {
  final presenter = ChatHeaderPresenter(
    ref.watch(fileStorageDriverProvider),
    ref.watch(profilingServiceProvider),
    ref.watch(profilingChannelProvider),
  );
  ref.onDispose(presenter.disconnectRealtime);
  return presenter;
});
