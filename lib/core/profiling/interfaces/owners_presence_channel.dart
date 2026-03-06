import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';

abstract class OwnersPresenceChannel {
  void listen({
    required void Function(OwnerPresenceDto presence) onPresenceChanged,
  });
}
