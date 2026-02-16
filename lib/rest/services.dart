import 'package:equiny/core/auth/interfaces/auth_service.dart' as auth_service;
import 'package:equiny/core/profiling/interfaces/profiling_service.dart'
    as profiling_service;
import 'package:equiny/core/storage/interfaces/file_storage_service.dart'
    as file_storage_service;
import 'package:equiny/rest/auth/services/auth_service.dart';
import 'package:equiny/rest/profiling/services/profiling_service.dart'
    as profiling_service_impl;
import 'package:equiny/rest/rest_client.dart';
import 'package:equiny/rest/storage/services/file_storage_service.dart'
    as file_storage_service_impl;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<auth_service.AuthService>((ref) {
  return AuthService(ref.watch(restClientProvider));
});

final profilingServiceProvider = Provider<profiling_service.ProfilingService>((
  ref,
) {
  return profiling_service_impl.ProfilingService(ref.watch(restClientProvider));
});

final fileStorageServiceProvider =
    Provider<file_storage_service.FileStorageService>((ref) {
      return file_storage_service_impl.FileStorageService(
        ref.watch(restClientProvider),
      );
    });
