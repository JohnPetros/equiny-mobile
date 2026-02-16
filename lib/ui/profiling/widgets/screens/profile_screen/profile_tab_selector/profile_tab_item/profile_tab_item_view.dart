import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_tab_selector/profile_tab_item/profile_tab_item_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTabItemView extends ConsumerWidget {
  final String label;
  final ProfileTab tab;
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;

  const ProfileTabItemView({
    required this.label,
    required this.tab,
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(profileTabItemPresenterProvider);
    final isActive = presenter.isActive(activeTab: activeTab, tab: tab);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: presenter.backgroundColor(isActive: isActive),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: presenter.textColor(isActive: isActive),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
