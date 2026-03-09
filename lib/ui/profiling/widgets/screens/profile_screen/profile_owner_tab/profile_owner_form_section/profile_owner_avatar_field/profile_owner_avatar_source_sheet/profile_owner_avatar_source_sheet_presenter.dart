class ProfileOwnerAvatarSourceSheetPresenter {
  const ProfileOwnerAvatarSourceSheetPresenter();

  String resolveTitle() {
    return 'Escolha uma opcao';
  }

  List<ProfileOwnerAvatarSourceOption> buildOptions({
    required bool showGalleryOption,
    required bool showRemoveOption,
  }) {
    final List<ProfileOwnerAvatarSourceOption> options =
        <ProfileOwnerAvatarSourceOption>[
          const ProfileOwnerAvatarSourceOption(
            type: ProfileOwnerAvatarSourceOptionType.camera,
            title: 'Tirar foto',
          ),
        ];

    if (showGalleryOption) {
      options.add(
        const ProfileOwnerAvatarSourceOption(
          type: ProfileOwnerAvatarSourceOptionType.gallery,
          title: 'Escolher da galeria',
        ),
      );
    }

    if (showRemoveOption) {
      options.add(
        const ProfileOwnerAvatarSourceOption(
          type: ProfileOwnerAvatarSourceOptionType.remove,
          title: 'Remover foto',
          isDestructive: true,
        ),
      );
    }

    return options;
  }
}

enum ProfileOwnerAvatarSourceOptionType { camera, gallery, remove }

class ProfileOwnerAvatarSourceOption {
  final ProfileOwnerAvatarSourceOptionType type;
  final String title;
  final bool isDestructive;

  const ProfileOwnerAvatarSourceOption({
    required this.type,
    required this.title,
    this.isDestructive = false,
  });
}
