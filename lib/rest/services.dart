import 'package:equiny/core/auth/interfaces/auth_service.dart' as auth_service;
import 'package:equiny/rest/auth/services/auth_service.dart';
import 'package:equiny/rest/rest_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<auth_service.AuthService>((ref) {
  return AuthService(ref.watch(restClientProvider));
});
