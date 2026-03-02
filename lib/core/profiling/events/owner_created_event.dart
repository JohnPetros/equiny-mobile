import 'package:equiny/core/shared/abstracts/event.dart';

class _Payload {
  final String ownerId;

  _Payload({required this.ownerId});
}

class OwnerCreatedEvent extends Event<_Payload> {
  static const String name = 'profiling/owner.created';

  OwnerCreatedEvent({required String ownerId})
    : super(
        name: name,
        payload: _Payload(ownerId: ownerId),
      );
}
