import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/new_matches_list/new_matches_list_item/index.dart';
import 'package:flutter/material.dart';

class NewMatchesListView extends StatelessWidget {
  final List<HorseMatchDto> items;
  final void Function(HorseMatchDto item) onTapItem;

  const NewMatchesListView({
    required this.items,
    required this.onTapItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Novos',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              final HorseMatchDto item = items[index];
              return NewMatchesListItem(item: item, onTap: () => onTapItem(item));
            },
          ),
        ),
      ],
    );
  }
}
