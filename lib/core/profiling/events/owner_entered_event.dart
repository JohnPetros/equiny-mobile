import 'package:equiny/core/shared/abstracts/event.dart';

class _Payload {
  final String ownerId;

  _Payload({required this.ownerId});
}

class OwnerEnteredEvent extends Event<_Payload> {
  static const String name = 'profiling/owner.entered';

  OwnerEnteredEvent({required String ownerId})
    : super(
        name: name,
        payload: _Payload(ownerId: ownerId),
      );
}
