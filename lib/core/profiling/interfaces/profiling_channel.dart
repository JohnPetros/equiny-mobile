import 'package:equiny/core/shared/types/json.dart';
import 'package:equiny/core/profiling/events/owner_entered_event.dart';

abstract class ProfilingChannel {
  Future<void> emitOwnerEnteredEvent(OwnerEnteredEvent event);

  void onMessageReceived(Function(Json) callback);
}
