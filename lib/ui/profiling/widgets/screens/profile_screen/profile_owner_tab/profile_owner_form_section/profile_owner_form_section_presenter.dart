import 'package:reactive_forms/reactive_forms.dart';

class ProfileOwnerFormSectionPresenter {
  FormGroup buildForm() {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
      'email': FormControl<String>(
        disabled: true,
        validators: <Validator<dynamic>>[Validators.required, Validators.email],
      ),
      'phone': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.delegate(_optionalPhoneValidator),
        ],
      ),
      'bio': FormControl<String>(
        validators: <Validator<dynamic>>[Validators.maxLength(300)],
      ),
    });
  }

  static Map<String, dynamic>? _optionalPhoneValidator(
    AbstractControl<dynamic> control,
  ) {
    final String value = (control.value as String? ?? '').trim();
    if (value.isEmpty) {
      return null;
    }

    final bool hasOnlyDigits = RegExp(r'^\d+$').hasMatch(value);
    if (!hasOnlyDigits || value.length != 11) {
      return <String, dynamic>{'invalidPhone': true};
    }

    return null;
  }
}
