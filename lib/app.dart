import 'dart:async';

import 'package:equiny/core/profiling/events/horse_match_notified_event.dart';
import 'package:equiny/core/profiling/events/owner_entered_event.dart';
import 'package:equiny/core/profiling/events/owner_exited_event.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/env_keys.dart';
import 'package:equiny/core/shared/interfaces/push_notification_driver.dart';
import 'package:equiny/core/shared/interfaces/websocket_client.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/drivers/push-notification-driver/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:equiny/router.dart';
import 'package:equiny/shared/providers/auth_state_provider.dart';
import 'package:equiny/ui/profiling/components/match_notification_modal/index.dart';
import 'package:equiny/ui/profiling/components/match_notification_modal/match_notification_modal_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:equiny/websocket/channels.dart';
import 'package:equiny/websocket/websocket_client.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  String? _activeSessionKey;
  String? _inFlightSessionKey;
  String? _activePushOwnerId;
  String? _inFlightPushOwnerId;
  ProviderSubscription<bool>? _authStateSubscription;
  Timer? _offlineGraceTimer;
  bool _isLifecycleResumed = true;
  void Function()? _profilingRealtimeUnsubscribe;
  bool _isMatchNotificationModalVisible = false;

  static const Duration _offlineGracePeriod = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;
    _isLifecycleResumed =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;

    _authStateSubscription = ref.listenManual<bool>(
      authStateProvider,
      (_, _) => _syncSessionsFromState(),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authStateSubscription?.close();
    _clearProfilingRealtimeSubscription();
    _offlineGraceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _isLifecycleResumed = true;
      _offlineGraceTimer?.cancel();
      _offlineGraceTimer = null;
      _syncSessionsFromState();
      return;
    }

    _isLifecycleResumed = false;
    _offlineGraceTimer?.cancel();
    _offlineGraceTimer = Timer(_offlineGracePeriod, () {
      if (!mounted || _isLifecycleResumed) {
        return;
      }
      unawaited(_emitOwnerExitedAndDisconnect());
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Equiny',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }

  void _syncWebSocketSession({
    required WebSocketClient websocketClient,
    required String webSocketBaseUrl,
    required bool isAuthenticated,
    required String ownerId,
    required String accessToken,
  }) {
    if (!isAuthenticated || ownerId.isEmpty || accessToken.isEmpty) {
      _offlineGraceTimer?.cancel();
      _offlineGraceTimer = null;
      _activeSessionKey = null;
      _inFlightSessionKey = null;
      _clearProfilingRealtimeSubscription();
      unawaited(websocketClient.disconnect());
      return;
    }

    if (!_isLifecycleResumed) {
      return;
    }

    final String sessionKey = '$ownerId:$accessToken';
    if (_activeSessionKey == sessionKey || _inFlightSessionKey == sessionKey) {
      return;
    }

    _inFlightSessionKey = sessionKey;

    unawaited(
      _connectAndNotifyOwnerEntered(
        websocketClient: websocketClient,
        webSocketBaseUrl: webSocketBaseUrl,
        ownerId: ownerId,
        accessToken: accessToken,
        sessionKey: sessionKey,
      ),
    );
  }

  void _syncSessionsFromState() {
    final websocketClient = ref.read(websocketClientProvider);
    final envDriver = ref.read(envDriverProvider);
    final pushNotificationDriver = ref.read(pushNotificationDriverProvider);
    final isAuthenticated = ref.read(authStateProvider);
    final cacheDriver = ref.read(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
    final accessToken = cacheDriver.get(CacheKeys.accessToken) ?? '';
    final hasCompletedOnboarding =
        (cacheDriver.get(CacheKeys.onboardingCompleted) ?? '') == 'true';

    _syncWebSocketSession(
      websocketClient: websocketClient,
      webSocketBaseUrl: envDriver.get(EnvKeys.equinyWebsocketUrl),
      isAuthenticated: isAuthenticated,
      ownerId: ownerId,
      accessToken: accessToken,
    );

    _syncPushSession(
      pushNotificationDriver: pushNotificationDriver,
      isAuthenticated: isAuthenticated,
      ownerId: ownerId,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  void _syncPushSession({
    required PushNotificationDriver pushNotificationDriver,
    required bool isAuthenticated,
    required String ownerId,
    required bool hasCompletedOnboarding,
  }) {
    if (!isAuthenticated || ownerId.isEmpty) {
      if (_activePushOwnerId == null && _inFlightPushOwnerId == null) {
        return;
      }

      _activePushOwnerId = null;
      _inFlightPushOwnerId = null;
      unawaited(pushNotificationDriver.unregister());
      return;
    }

    if (_activePushOwnerId == ownerId || _inFlightPushOwnerId == ownerId) {
      return;
    }

    _inFlightPushOwnerId = ownerId;

    unawaited(
      _initializeAndBindPushSession(
        pushNotificationDriver: pushNotificationDriver,
        ownerId: ownerId,
        hasCompletedOnboarding: hasCompletedOnboarding,
      ),
    );
  }

  Future<void> _initializeAndBindPushSession({
    required PushNotificationDriver pushNotificationDriver,
    required String ownerId,
    required bool hasCompletedOnboarding,
  }) async {
    try {
      if (hasCompletedOnboarding) {
        await pushNotificationDriver.requestPermission();
      }

      final bool isAuthenticated = ref.read(authStateProvider);
      final cacheDriver = ref.read(cacheDriverProvider);
      final String currentOwnerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
      if (!isAuthenticated || currentOwnerId != ownerId) {
        return;
      }

      await pushNotificationDriver.register(ownerId: ownerId);
      _activePushOwnerId = ownerId;
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to bind OneSignal session for ownerId=$ownerId: $error\n$stackTrace',
      );
      _activePushOwnerId = null;
    } finally {
      if (_inFlightPushOwnerId == ownerId) {
        _inFlightPushOwnerId = null;
      }
    }
  }

  Future<void> _emitOwnerExitedAndDisconnect() async {
    final websocketClient = ref.read(websocketClientProvider);
    final cacheDriver = ref.read(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';

    _clearProfilingRealtimeSubscription();

    if (ownerId.isNotEmpty) {
      final profilingChannel = ref.read(profilingChannelProvider);
      await profilingChannel.emitOwnerExitedEvent(
        OwnerExitedEvent(ownerId: ownerId),
      );
    }

    _activeSessionKey = null;
    _inFlightSessionKey = null;
    await websocketClient.disconnect();
  }

  Future<void> _connectAndNotifyOwnerEntered({
    required WebSocketClient websocketClient,
    required String webSocketBaseUrl,
    required String ownerId,
    required String accessToken,
    required String sessionKey,
  }) async {
    try {
      await websocketClient.connect(
        '$webSocketBaseUrl/websocket/$ownerId?token=$accessToken',
      );
      final bool isAuthenticated = ref.read(authStateProvider);
      final cacheDriver = ref.read(cacheDriverProvider);
      final String currentOwnerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
      final String currentAccessToken =
          cacheDriver.get(CacheKeys.accessToken) ?? '';
      final String currentSessionKey = '$currentOwnerId:$currentAccessToken';
      if (!isAuthenticated || currentSessionKey != sessionKey) {
        return;
      }

      final profilingChannel = ref.read(profilingChannelProvider);
      await profilingChannel.emitOwnerEnteredEvent(
        OwnerEnteredEvent(ownerId: currentOwnerId),
      );
      _profilingRealtimeUnsubscribe?.call();
      _profilingRealtimeUnsubscribe = profilingChannel.listen(
        onOwnerPresenceRegistered: (_) {},
        onOwnerPresenceUnregistered: (_) {},
        onHorseMatchNotified: _handleMatchNotified,
        onOwnerCreated: (_) {},
      );
      _activeSessionKey = sessionKey;
    } finally {
      if (_inFlightSessionKey == sessionKey) {
        _inFlightSessionKey = null;
      }
    }
  }

  void _clearProfilingRealtimeSubscription() {
    _profilingRealtimeUnsubscribe?.call();
    _profilingRealtimeUnsubscribe = null;
  }

  void _handleMatchNotified(HorseMatchNotifiedEvent event) {
    if (!mounted) {
      return;
    }

    final router = ref.read(routerProvider);
    final BuildContext? navigatorContext =
        router.routerDelegate.navigatorKey.currentContext;

    if (navigatorContext == null) {
      return;
    }

    final presenter = ref.read(matchNotificationModalPresenterProvider);
    if (!_isMatchNotificationModalVisible) {
      presenter.clear();
      presenter.enqueue(event.payload.horseMatch);
      _isMatchNotificationModalVisible = true;

      unawaited(
        showGeneralDialog<void>(
          context: navigatorContext,
          useRootNavigator: true,
          barrierDismissible: false,
          barrierColor: Colors.black.withValues(alpha: 0.75),
          barrierLabel: 'Match Notification',
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (_, _, _) => const MatchNotificationModal(),
        ).whenComplete(() {
          _isMatchNotificationModalVisible = false;
          ref.invalidate(matchNotificationModalPresenterProvider);
        }),
      );
      return;
    }

    presenter.enqueue(event.payload.horseMatch);
  }
}
