import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:reactive_forms/reactive_forms.dart';

class ProfileHorseFeedReadinessSectionPresenter {
  List<String> buildChecklist({
    required FormGroup form,
    required List<ImageDto> images,
  }) {
    final List<String> pending = <String>[];

    if ((form.control('name').value as String? ?? '').trim().isEmpty) {
      pending.add('Preencher nome do cavalo');
    }

    if ((form.control('sex').value as String? ?? '').trim().isEmpty) {
      pending.add('Definir sexo');
    }

    if ((form.control('city').value as String? ?? '').trim().isEmpty ||
        (form.control('state').value as String? ?? '').trim().isEmpty) {
      pending.add('Informar localizacao (cidade/UF)');
    }

    if (images.isEmpty) {
      pending.add('Adicionar pelo menos 1 foto');
    }

    return pending;
  }
}
