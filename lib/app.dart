import 'dart:async';

import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/env_keys.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:equiny/router.dart';
import 'package:equiny/shared/providers/auth_state_provider.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:equiny/websocket/websocket_client.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    final websocketClient = ref.watch(websocketClientProvider);
    final envDriver = ref.watch(envDriverProvider);
    final isAuthenticated = ref.watch(authStateProvider);
    final cacheDriver = ref.watch(cacheDriverProvider);
    final ownerId = cacheDriver.get(CacheKeys.ownerId) ?? '';
    final accessToken = cacheDriver.get(CacheKeys.accessToken) ?? '';

    if (isAuthenticated && ownerId.isNotEmpty && accessToken.isNotEmpty) {
      unawaited(
        websocketClient.connect(
          '${envDriver.get(EnvKeys.equinyWebsocketUrl)}/websocket/$ownerId?token=$accessToken',
        ),
      );
    } else {
      unawaited(websocketClient.disconnect());
    }

    return MaterialApp.router(
      title: 'Equiny',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
