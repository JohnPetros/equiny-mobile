import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_tab_selector/profile_tab_item/index.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileTabSelectorView extends StatelessWidget {
  final ProfileTab activeTab;
  final ValueChanged<ProfileTab> onTabChanged;

  const ProfileTabSelectorView({
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Row(
        children: <Widget>[
          ProfileTabItem(
            label: 'Cavalo',
            tab: ProfileTab.horse,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
          ProfileTabItem(
            label: 'Dono',
            tab: ProfileTab.owner,
            activeTab: activeTab,
            onTabChanged: onTabChanged,
          ),
        ],
      ),
    );
  }
}
