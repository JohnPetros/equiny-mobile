class ProfileHorseActiveSectionPresenter {
  String? validateActivation({
    required bool isActivating,
    required bool canActivate,
  }) {
    if (isActivating && !canActivate) {
      return 'Seu cavalo ainda nao esta pronto para aparecer no feed.';
    }

    return null;
  }
}
