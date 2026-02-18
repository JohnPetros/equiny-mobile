import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';

class HorseFeedResultDto {
  final List<FeedHorseDto> items;
  final String nextCursor;
  final int limit;

  const HorseFeedResultDto({
    required this.items,
    required this.nextCursor,
    required this.limit,
  });
}
