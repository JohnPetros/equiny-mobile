import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateNotifier extends StateNotifier<bool> {
  final CacheDriver _cacheDriver;
  final ProfilingService _profilingService;

  AuthStateNotifier(super.state, this._cacheDriver, this._profilingService);

  Future<void> loadInitialState() async {
    final accessToken = await Future<String?>.value(
      _cacheDriver.get(CacheKeys.accessToken),
    );

    if ((accessToken ?? '').isEmpty) {
      if (mounted) {
        state = false;
      }
      return;
    }

    final ownerResponse = await _profilingService.fetchOwner();

    if (!mounted) {
      return;
    }

    if (ownerResponse.isFailure) {
      await _cacheDriver.delete(CacheKeys.accessToken);
      await _cacheDriver.delete(CacheKeys.ownerId);
      await _cacheDriver.delete(CacheKeys.onboardingCompleted);
      if (!mounted) {
        return;
      }
      state = false;
      return;
    }

    state = true;
  }

  void setAuthenticated(bool isAuthenticated) {
    state = isAuthenticated;
  }
}

final authStateProvider = StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  final cacheDriver = ref.watch(cacheDriverProvider);
  final profilingService = ref.watch(profilingServiceProvider);
  final notifier = AuthStateNotifier(false, cacheDriver, profilingService);

  notifier.loadInitialState();

  return notifier;
});
