import 'package:equiny/core/auth/interfaces/auth_service.dart' as auth_service;
import 'package:equiny/core/matching/interfaces/matching_service.dart'
    as matching_service;
import 'package:equiny/core/profiling/interfaces/profiling_service.dart'
    as profiling_service;
import 'package:equiny/core/storage/interfaces/file_storage_service.dart'
    as file_storage_service;
import 'package:equiny/rest/services/matching_service.dart'
    as matching_service_impl;
import 'package:equiny/rest/services/auth_service.dart';
import 'package:equiny/rest/services/profiling_service.dart'
    as profiling_service_impl;
import 'package:equiny/rest/rest_client.dart';
import 'package:equiny/rest/services/file_storage_service.dart'
    as file_storage_service_impl;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equiny/rest/services/location_service.dart'
    as location_service_impl;
import 'package:equiny/rest/location_rest_client.dart' as location_rest_client;
import 'package:equiny/drivers/cache-driver/index.dart';

final authServiceProvider = Provider<auth_service.AuthService>((ref) {
  return AuthService(
    ref.watch(restClientProvider),
    ref.watch(cacheDriverProvider),
  );
});

final profilingServiceProvider = Provider<profiling_service.ProfilingService>((
  ref,
) {
  return profiling_service_impl.ProfilingService(
    ref.watch(restClientProvider),
    ref.watch(cacheDriverProvider),
  );
});

final matchingServiceProvider = Provider<matching_service.MatchingService>((
  ref,
) {
  return matching_service_impl.MatchingService(
    ref.watch(restClientProvider),
    ref.watch(cacheDriverProvider),
  );
});

final fileStorageServiceProvider =
    Provider<file_storage_service.FileStorageService>((ref) {
      return file_storage_service_impl.FileStorageService(
        ref.watch(restClientProvider),
        ref.watch(cacheDriverProvider),
      );
    });

final locationServiceProvider = Provider<location_service_impl.LocationService>(
  (ref) {
    final restClient = ref.read(location_rest_client.restClientProvider);
    return location_service_impl.LocationService(
      restClient,
      ref.watch(cacheDriverProvider),
    );
  },
);
