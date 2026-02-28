import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/shared/abstracts/event.dart';

class _Payload {
  final HorseMatchDto horseMatch;

  _Payload({required this.horseMatch});
}

class HorseMatchNotifiedEvent extends Event<_Payload> {
  static const String name = 'profiling/horse.match.notified';

  HorseMatchNotifiedEvent({required HorseMatchDto horseMatch})
    : super(
        name: name,
        payload: _Payload(horseMatch: horseMatch),
      );
}
