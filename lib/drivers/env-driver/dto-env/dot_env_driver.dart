import 'package:equiny/core/shared/interfaces/env_driver.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvDriver implements EnvDriver {
  @override
  String get(String key) {
    return dotenv.env[key] ?? '';
  }
}
