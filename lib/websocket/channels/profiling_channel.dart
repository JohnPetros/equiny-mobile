import 'package:equiny/core/profiling/events/owner_entered_event.dart';
import 'package:equiny/core/profiling/events/owner_exited_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_registered_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_unregistered_event.dart';
import 'package:equiny/core/profiling/interfaces/profiling_channel.dart'
    as profiling_channel;
import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/websocket/channels/channel.dart';

class ProfilingChannel extends Channel
    implements profiling_channel.ProfilingChannel {
  ProfilingChannel(super.websocketClient);

  String _resolveOwnerId(Json payload) {
    return payload['owner_id']?.toString() ?? '';
  }

  @override
  void Function() listen({
    required void Function(OwnerPresenceRegisteredEvent event)
    onOwnerPresenceRegistered,
    required void Function(OwnerPresenceUnregisteredEvent event)
    onOwnerPresenceUnregistered,
  }) {
    return super.websocketClient.onData((Json data) {
      final (String name, Json payload) = parseEvent(data);
      switch (name) {
        case OwnerPresenceRegisteredEvent.name:
        case OwnerEnteredEvent.name:
          onOwnerPresenceRegistered(
            OwnerPresenceRegisteredEvent(ownerId: _resolveOwnerId(payload)),
          );
          break;
        case OwnerPresenceUnregisteredEvent.name:
        case OwnerExitedEvent.name:
          onOwnerPresenceUnregistered(
            OwnerPresenceUnregisteredEvent(ownerId: _resolveOwnerId(payload)),
          );
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> emitOwnerEnteredEvent(OwnerEnteredEvent event) async {
    await super.websocketClient.send(<String, dynamic>{
      'name': event.getName(),
      'payload': <String, dynamic>{'owner_id': event.payload.ownerId},
    });
  }

  @override
  Future<void> emitOwnerExitedEvent(OwnerExitedEvent event) async {
    await super.websocketClient.send(<String, dynamic>{
      'name': event.getName(),
      'payload': <String, dynamic>{'owner_id': event.payload.ownerId},
    });
  }
}
