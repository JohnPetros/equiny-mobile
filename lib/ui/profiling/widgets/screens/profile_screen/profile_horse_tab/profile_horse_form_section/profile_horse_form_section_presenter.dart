import 'package:reactive_forms/reactive_forms.dart';

class ProfileHorseFormSectionPresenter {
  FormGroup buildForm() {
    return FormGroup(<String, AbstractControl<Object?>>{
      'name': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
      'birthMonth': FormControl<int>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(1),
          Validators.max(12),
        ],
      ),
      'birthYear': FormControl<int>(validators: <Validator<dynamic>>[]),
      'breed': FormControl<String>(),
      'sex': FormControl<String>(
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'height': FormControl<double>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(0.5),
          Validators.max(3.0),
        ],
      ),
      'city': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
        ],
      ),
      'state': FormControl<String>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.minLength(2),
          Validators.maxLength(60),
        ],
      ),
      'latitude': FormControl<double>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(-90),
          Validators.max(90),
        ],
      ),
      'longitude': FormControl<double>(
        validators: <Validator<dynamic>>[
          Validators.required,
          Validators.min(-180),
          Validators.max(180),
        ],
      ),
      'description': FormControl<String>(),
    });
  }
}
