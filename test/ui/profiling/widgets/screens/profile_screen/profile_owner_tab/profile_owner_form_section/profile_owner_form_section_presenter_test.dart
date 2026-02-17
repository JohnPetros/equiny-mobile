import 'package:equiny/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProfileOwnerFormSectionPresenter presenter;

  setUp(() {
    presenter = ProfileOwnerFormSectionPresenter();
  });

  group('ProfileOwnerFormSectionPresenter', () {
    test('should build form with expected controls', () {
      final form = presenter.buildForm();

      expect(form.contains('name'), isTrue);
      expect(form.contains('email'), isTrue);
      expect(form.contains('phone'), isTrue);
      expect(form.contains('bio'), isTrue);
      expect(form.control('email').disabled, isTrue);
    });

    test('should invalidate phone when not 11 digits', () {
      final form = presenter.buildForm();
      form.control('phone').value = '123';
      form.control('name').value = 'Joao Silva';
      form.control('email').value = 'joao@equiny.com';

      form.updateValueAndValidity();

      expect(form.control('phone').valid, isFalse);
      expect(form.control('phone').hasErrors, isTrue);
      expect(form.control('phone').errors.containsKey('invalidPhone'), isTrue);
    });

    test('should keep phone valid when empty or 11 digits', () {
      final form = presenter.buildForm();

      form.control('phone').value = '';
      form.updateValueAndValidity();
      expect(form.control('phone').valid, isTrue);

      form.control('phone').value = '11999999999';
      form.updateValueAndValidity();
      expect(form.control('phone').valid, isTrue);
    });
  });
}
