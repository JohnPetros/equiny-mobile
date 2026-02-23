import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/shared/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

enum ProfileTab { horse, owner }

class ProfileScreenPresenter {
  final CacheDriver _cacheDriver;
  final NavigationDriver _navigationDriver;
  final AuthStateNotifier _authStateNotifier;

  final Signal<ProfileTab> activeTab = signal(ProfileTab.horse);
  late final ReadonlySignal<bool> isHorseTab;
  late final ReadonlySignal<bool> isOwnerTab;

  ProfileScreenPresenter(
    this._cacheDriver,
    this._navigationDriver,
    this._authStateNotifier,
  ) {
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

  Future<void> logout() async {
    await _cacheDriver.delete(CacheKeys.accessToken);
    _authStateNotifier.setAuthenticated(false);
    _navigationDriver.goTo(Routes.signIn);
  }
}

final profileScreenPresenterProvider = Provider<ProfileScreenPresenter>((ref) {
  return ProfileScreenPresenter(
    ref.watch(cacheDriverProvider),
    ref.watch(navigationDriverProvider),
    ref.read(authStateProvider.notifier),
  );
});
