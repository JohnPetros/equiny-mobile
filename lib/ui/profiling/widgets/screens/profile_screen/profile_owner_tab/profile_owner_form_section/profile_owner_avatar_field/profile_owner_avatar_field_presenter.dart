class ProfileOwnerAvatarFieldPresenter {
  const ProfileOwnerAvatarFieldPresenter();

  bool isAvatarAvailable(String? avatarUrl) {
    return (avatarUrl ?? '').trim().isNotEmpty;
  }

  String resolveAvatarUrl(String? avatarUrl) {
    return (avatarUrl ?? '').trim();
  }

  String resolveActionLabel({
    required String? avatarUrl,
    required bool isUploading,
  }) {
    if (isUploading) {
      return 'Enviando foto...';
    }

    if (isAvatarAvailable(avatarUrl)) {
      return 'Trocar foto';
    }

    return 'Adicionar foto';
  }
}
