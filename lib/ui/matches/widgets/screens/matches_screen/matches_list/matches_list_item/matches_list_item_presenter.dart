import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesListItemPresenter {
  String formatRelativeTime(DateTime createdAt) {
    final Duration diff = DateTime.now().difference(createdAt);

    if (diff.inMinutes < 1) {
      return 'Agora mesmo';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} min atras';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} h atras';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} dias atras';
    }

    final int weeks = (diff.inDays / 7).floor();
    return '$weeks sem atras';
  }

  String buildOwnerInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(' ')
        .where((String part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

final matchesListItemPresenterProvider =
    Provider.autoDispose<MatchesListItemPresenter>((ref) {
      return MatchesListItemPresenter();
    });
