import 'dart:async';

import 'package:equiny/core/profiling/events/owner_entered_event.dart';
import 'package:equiny/core/profiling/events/owner_exited_event.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/env_keys.dart';
import 'package:equiny/core/shared/interfaces/websocket_client.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:equiny/router.dart';
import 'package:equiny/shared/providers/auth_state_provider.dart';
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
  Timer? _offlineGraceTimer;
  bool _isLifecycleResumed = true;

  static const Duration _offlineGracePeriod = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;
    _isLifecycleResumed =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
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
      _syncWebSocketSessionFromCurrentState();
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

    final websocketClient = ref.watch(websocketClientProvider);
    final envDriver = ref.watch(envDriverProvider);
    final isAuthenticated = ref.watch(authStateProvider);
    final cacheDriver = ref.watch(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
    final accessToken = cacheDriver.get(CacheKeys.accessToken) ?? '';

    _syncWebSocketSession(
      websocketClient: websocketClient,
      webSocketBaseUrl: envDriver.get(EnvKeys.equinyWebsocketUrl),
      isAuthenticated: isAuthenticated,
      ownerId: ownerId,
      accessToken: accessToken,
    );

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

  void _syncWebSocketSessionFromCurrentState() {
    final websocketClient = ref.read(websocketClientProvider);
    final envDriver = ref.read(envDriverProvider);
    final isAuthenticated = ref.read(authStateProvider);
    final cacheDriver = ref.read(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
    final accessToken = cacheDriver.get(CacheKeys.accessToken) ?? '';

    _syncWebSocketSession(
      websocketClient: websocketClient,
      webSocketBaseUrl: envDriver.get(EnvKeys.equinyWebsocketUrl),
      isAuthenticated: isAuthenticated,
      ownerId: ownerId,
      accessToken: accessToken,
    );
  }

  Future<void> _emitOwnerExitedAndDisconnect() async {
    final websocketClient = ref.read(websocketClientProvider);
    final cacheDriver = ref.read(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';

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
      _activeSessionKey = sessionKey;
    } finally {
      if (_inFlightSessionKey == sessionKey) {
        _inFlightSessionKey = null;
      }
    }
  }
}
