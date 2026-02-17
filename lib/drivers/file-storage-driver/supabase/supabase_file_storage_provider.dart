import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/core/shared/interfaces/env_driver.dart';

class SupabaseFileStorageDriver implements FileStorageDriver {
  final EnvDriver envDriver;

  SupabaseFileStorageDriver(this.envDriver);

  @override
  String getImageUrl(String imageFileKey) {
    return '${envDriver.get('SUPABASE_STORAGE_URL')}/images/$imageFileKey';
  }
}
