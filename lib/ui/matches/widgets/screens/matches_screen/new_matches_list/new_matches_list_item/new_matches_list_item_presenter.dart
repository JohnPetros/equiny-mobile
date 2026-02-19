import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewMatchesListItemPresenter {
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

final newMatchesListItemPresenterProvider =
    Provider.autoDispose<NewMatchesListItemPresenter>((ref) {
      return NewMatchesListItemPresenter();
    });
