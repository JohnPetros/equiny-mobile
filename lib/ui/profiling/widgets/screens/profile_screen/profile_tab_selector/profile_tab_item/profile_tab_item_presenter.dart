import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileTabItemPresenter {
  bool isActive({required ProfileTab activeTab, required ProfileTab tab}) {
    return activeTab == tab;
  }

  Color backgroundColor({required bool isActive}) {
    return isActive ? AppThemeColors.primary : Colors.transparent;
  }

  Color textColor({required bool isActive}) {
    return isActive ? const Color(0xFF222026) : AppThemeColors.textMain;
  }
}

final profileTabItemPresenterProvider = Provider<ProfileTabItemPresenter>((
  ref,
) {
  return ProfileTabItemPresenter();
});
