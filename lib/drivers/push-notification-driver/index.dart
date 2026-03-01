import 'package:equiny/core/shared/interfaces/push_notification_driver.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/drivers/push-notification-driver/one-signal/one_signal_push_notification_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equiny/core/shared/constants/env_keys.dart';

final pushNotificationDriverProvider = Provider<PushNotificationDriver>((ref) {
  final envDriver = ref.watch(envDriverProvider);
  return OneSignalPushNotificationDriver(
    appId: envDriver.get(EnvKeys.oneSignalAppId),
  );
});
