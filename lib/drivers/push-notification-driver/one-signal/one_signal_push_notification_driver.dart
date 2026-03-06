import 'dart:async';

import 'package:equiny/core/shared/interfaces/push_notification_driver.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalPushNotificationDriver implements PushNotificationDriver {
  OneSignalPushNotificationDriver({required String appId}) : _appId = appId;

  final String _appId;
  bool _isInitialized = false;
  Future<void>? _initializeFuture;
  String? _registeredOwnerId;

  Future<void> _initialize() async {
    if (_isInitialized) {
      return;
    }

    final inFlightInitialization = _initializeFuture;
    if (inFlightInitialization != null) {
      await inFlightInitialization;
      return;
    }

    final completer = Completer<void>();
    _initializeFuture = completer.future;

    try {
      final normalizedAppId = _appId.trim();
      if (normalizedAppId.isEmpty) {
        throw ArgumentError('OneSignal appId cannot be empty');
      }

      OneSignal.Debug.setLogLevel(OSLogLevel.error);
      OneSignal.initialize(normalizedAppId);

      await _waitForUserBootstrap();
      _isInitialized = true;
      completer.complete();
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _initializeFuture = null;
    }
  }

  @override
  Future<bool> requestPermission({bool fallbackToSettings = true}) async {
    await _initialize();
    return await OneSignal.Notifications.requestPermission(fallbackToSettings);
  }

  @override
  Future<void> register({required String ownerId}) async {
    final normalizedOwnerId = ownerId.trim();
    if (normalizedOwnerId.isEmpty) {
      throw ArgumentError('OneSignal ownerId cannot be empty');
    }

    await _initialize();

    if (_registeredOwnerId == normalizedOwnerId) {
      return;
    }

    await _waitForUserBootstrap();

    await OneSignal.login(normalizedOwnerId);

    final externalId = await OneSignal.User.getExternalId();

    if (externalId != normalizedOwnerId) {
      OneSignal.User.addAlias('external_id', normalizedOwnerId);
    }

    _registeredOwnerId = normalizedOwnerId;
  }

  @override
  Future<void> unregister() async {
    if (!_isInitialized && _initializeFuture == null) {
      _registeredOwnerId = null;
      return;
    }

    await OneSignal.logout();
    _registeredOwnerId = null;
  }

  Future<void> _waitForUserBootstrap() async {
    for (int attempt = 0; attempt < 10; attempt++) {
      final oneSignalId = await OneSignal.User.getOnesignalId();
      if ((oneSignalId ?? '').isNotEmpty) {
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }
}
