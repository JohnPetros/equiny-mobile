import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

enum ProfileTab { horse, owner }

class ProfileScreenPresenter {
  final NavigationDriver _navigationDriver;

  final Signal<ProfileTab> activeTab = signal(ProfileTab.horse);
  late final ReadonlySignal<bool> isHorseTab;
  late final ReadonlySignal<bool> isOwnerTab;

  ProfileScreenPresenter(this._navigationDriver) {
    isHorseTab = computed(() => activeTab.value == ProfileTab.horse);
    isOwnerTab = computed(() => activeTab.value == ProfileTab.owner);
  }

  void switchTab(ProfileTab tab) {
    activeTab.value = tab;
  }

  void goBack() {
    if (_navigationDriver.canGoBack()) {
      _navigationDriver.goBack();
    }
  }
}

final profileScreenPresenterProvider = Provider<ProfileScreenPresenter>((ref) {
  return ProfileScreenPresenter(ref.watch(navigationDriverProvider));
});
