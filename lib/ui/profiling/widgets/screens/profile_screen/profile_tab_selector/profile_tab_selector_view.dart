import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart';
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppThemeColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppThemeColors.border),
      ),
      child: Row(
        children: <Widget>[
          _buildTab(label: 'Cavalo', tab: ProfileTab.horse),
          _buildTab(label: 'Dono', tab: ProfileTab.owner),
        ],
      ),
    );
  }

  Widget _buildTab({required String label, required ProfileTab tab}) {
    final bool isActive = activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isActive ? AppThemeColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF222026)
                  : AppThemeColors.textMain,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
