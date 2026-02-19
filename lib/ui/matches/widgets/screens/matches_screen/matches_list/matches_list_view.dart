import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/matches_list/matches_list_item/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class MatchesListView extends StatelessWidget {
  final List<HorseMatchDto> items;
  final void Function(HorseMatchDto item) onTapItem;
  final Future<bool> Function(HorseMatchDto item)? onDeleteItem;

  const MatchesListView({
    required this.items,
    required this.onTapItem,
    this.onDeleteItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: const Text(
            'Vistos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sem matches vistos ainda.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        if (items.isNotEmpty)
          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (BuildContext context, int index) {
              final HorseMatchDto item = items[index];
              return MatchesListItem(
                item: item,
                onTap: () => onTapItem(item),
                onDelete: onDeleteItem,
              );
            },
          ),
      ],
    );
  }
}
