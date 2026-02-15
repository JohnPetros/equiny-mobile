import 'package:equiny/core/shared/interfaces/env_driver.dart';
import 'package:equiny/drivers/env-driver/dto-env/dot_env_driver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final envDriverProvider = Provider<EnvDriver>((ref) {
  return DotEnvDriver();
});
