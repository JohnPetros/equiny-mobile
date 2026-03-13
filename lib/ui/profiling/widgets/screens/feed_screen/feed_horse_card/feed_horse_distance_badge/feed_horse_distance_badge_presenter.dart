import 'dart:math' as math;

class FeedHorseDistanceBadgePresenter {
  static const double _earthRadiusInKm = 6371;

  const FeedHorseDistanceBadgePresenter();

  String distanceLabel({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    if (!_isValidCoordinate(originLatitude, originLongitude) ||
        !_isValidCoordinate(destinationLatitude, destinationLongitude)) {
      return '-- km';
    }

    final double distanceInKm = _calculateDistanceInKm(
      originLatitude: originLatitude,
      originLongitude: originLongitude,
      destinationLatitude: destinationLatitude,
      destinationLongitude: destinationLongitude,
    );

    if (distanceInKm.isNaN || distanceInKm.isInfinite) {
      return '-- km';
    }

    if (distanceInKm % 1 == 0) {
      return '${distanceInKm.toInt()} km';
    }

    return '${distanceInKm.toInt()} km';
  }

  double _calculateDistanceInKm({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    final double deltaLatitude = _toRadians(
      destinationLatitude - originLatitude,
    );
    final double deltaLongitude = _toRadians(
      destinationLongitude - originLongitude,
    );
    final double originLatitudeInRadians = _toRadians(originLatitude);
    final double destinationLatitudeInRadians = _toRadians(destinationLatitude);

    final double haversineDeltaLatitude = math.sin(deltaLatitude / 2);
    final double haversineDeltaLongitude = math.sin(deltaLongitude / 2);

    final double haversineFormula =
        (haversineDeltaLatitude * haversineDeltaLatitude) +
        (math.cos(originLatitudeInRadians) *
            math.cos(destinationLatitudeInRadians) *
            haversineDeltaLongitude *
            haversineDeltaLongitude);

    final double arc =
        2 *
        math.atan2(
          math.sqrt(haversineFormula),
          math.sqrt(1 - haversineFormula),
        );

    return _earthRadiusInKm * arc;
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    final bool isLatitudeValid = latitude >= -90 && latitude <= 90;
    final bool isLongitudeValid = longitude >= -180 && longitude <= 180;
    final bool isNotZeroCoordinate = !(latitude == 0 && longitude == 0);

    return isLatitudeValid && isLongitudeValid && isNotZeroCoordinate;
  }

  double _toRadians(double value) {
    return value * (math.pi / 180);
  }
}
