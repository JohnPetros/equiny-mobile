import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:equiny/drivers/env-driver/index.dart';
import 'package:equiny/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileStorageDriverProvider = Provider<FileStorageDriver>((ref) {
  final envDriver = ref.read(envDriverProvider);
  return SupabaseFileStorageDriver(envDriver);
});
