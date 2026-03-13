import 'package:equiny/ui/profiling/widgets/screens/feed_screen/feed_horse_card/feed_horse_distance_badge/feed_horse_distance_badge_presenter.dart';
import 'package:flutter/material.dart';

class FeedHorseDistanceBadgeView extends StatelessWidget {
  final double originLatitude;
  final double originLongitude;
  final double destinationLatitude;
  final double destinationLongitude;

  const FeedHorseDistanceBadgeView({
    required this.originLatitude,
    required this.originLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const FeedHorseDistanceBadgePresenter presenter =
        FeedHorseDistanceBadgePresenter();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.near_me_outlined,
            size: 14,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 6),
          Text(
            presenter.distanceLabel(
              originLatitude: originLatitude,
              originLongitude: originLongitude,
              destinationLatitude: destinationLatitude,
              destinationLongitude: destinationLongitude,
            ),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
