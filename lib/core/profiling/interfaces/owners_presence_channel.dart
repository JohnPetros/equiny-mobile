import 'package:equiny/core/profiling/dtos/structures/owner_presence_dto.dart';
import 'package:equiny/core/shared/interfaces/channel.dart';

abstract class OwnersPresenceChannel extends Channel {
  void listen({
    required void Function(OwnerPresenceDto presence) onPresenceChanged,
  });
}
