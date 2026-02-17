import 'package:equiny/core/profiling/dtos/entities/owner_dto.dart';

class OwnerFaker {
  static OwnerDto fakeDto({
    String? id,
    String? name,
    String? email,
    String? accountId,
    bool? hasCompletedOnboarding,
    String? phone,
    String? bio,
  }) {
    return OwnerDto(
      id: id ?? 'owner-1',
      name: name ?? 'Joao Silva',
      email: email ?? 'joao@equiny.com',
      accountId: accountId ?? 'account-1',
      hasCompletedOnboarding: hasCompletedOnboarding ?? true,
      phone: phone ?? '11999999999',
      bio: bio ?? 'Criador de cavalos.',
    );
  }
}
