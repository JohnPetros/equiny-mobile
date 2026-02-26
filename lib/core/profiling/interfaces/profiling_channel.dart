import 'package:equiny/core/profiling/events/owner_entered_event.dart';
import 'package:equiny/core/profiling/events/owner_exited_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_registered_event.dart';
import 'package:equiny/core/profiling/events/owner_presence_unregistered_event.dart';

abstract class ProfilingChannel {
  Future<void> emitOwnerEnteredEvent(OwnerEnteredEvent event);

  Future<void> emitOwnerExitedEvent(OwnerExitedEvent event);

  void Function() listen({
    required void Function(OwnerPresenceRegisteredEvent event)
    onOwnerPresenceRegistered,
    required void Function(OwnerPresenceUnregisteredEvent event)
    onOwnerPresenceUnregistered,
  });
}
