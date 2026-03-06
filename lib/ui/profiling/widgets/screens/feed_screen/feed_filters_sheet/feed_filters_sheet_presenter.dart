import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:signals/signals.dart';

class FeedFiltersSheetPresenter {
  final Signal<FormGroup> form = signal(
    FormGroup(<String, AbstractControl<Object?>>{}),
  );
  final Signal<List<String>> selectedBreeds = signal(<String>[]);

  late final ReadonlySignal<bool> canApply;
  late final ReadonlySignal<int> activeFiltersCount;

  FeedFiltersSheetPresenter(HorseFeedFiltersDto initialFilters) {
    form.value = buildForm(initialFilters);
    selectedBreeds.value = <String>[...initialFilters.breeds];
    canApply = computed(() => form.value.valid);
    activeFiltersCount = computed(() {
      int count = 0;
      if (selectedBreeds.value.isNotEmpty) {
        count += 1;
      }
      final String city = (form.value.control('city').value as String? ?? '')
          .trim();
      final String state = (form.value.control('state').value as String? ?? '')
          .trim();
      if (city.isNotEmpty || state.isNotEmpty) {
        count += 1;
      }
      final int minAge = form.value.control('minAge').value as int? ?? 1;
      final int maxAge = form.value.control('maxAge').value as int? ?? 30;
      if (minAge != 1 || maxAge != 30) {
        count += 1;
      }
      return count;
    });
  }

  FormGroup buildForm(HorseFeedFiltersDto initialFilters) {
    return FormGroup(<String, AbstractControl<Object?>>{
      'sex': FormControl<String>(value: initialFilters.sex),
      'minAge': FormControl<int>(
        value: initialFilters.ageRange.min,
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'maxAge': FormControl<int>(
        value: initialFilters.ageRange.max,
        validators: <Validator<dynamic>>[Validators.required],
      ),
      'city': FormControl<String>(value: initialFilters.location.city),
      'state': FormControl<String>(value: initialFilters.location.state),
    });
  }

  void toggleBreed(String breed) {
    final bool exists = selectedBreeds.value.contains(breed);
    selectedBreeds.value = exists
        ? selectedBreeds.value.where((String item) => item != breed).toList()
        : <String>[...selectedBreeds.value, breed];
  }

  HorseFeedFiltersDto toDto() {
    return HorseFeedFiltersDto(
      sex: form.value.control('sex').value as String? ?? '',
      breeds: selectedBreeds.value,
      ageRange: AgeRangeDto(
        min: form.value.control('minAge').value as int? ?? 1,
        max: form.value.control('maxAge').value as int? ?? 30,
      ),
      location: LocationDto(
        city: (form.value.control('city').value as String? ?? '').trim(),
        state: (form.value.control('state').value as String? ?? '')
            .trim()
            .toUpperCase(),
      ),
      limit: 10,
    );
  }

  void resetFromDto(HorseFeedFiltersDto filters) {
    form.value.patchValue(<String, Object?>{
      'sex': filters.sex,
      'minAge': filters.ageRange.min,
      'maxAge': filters.ageRange.max,
      'city': filters.location.city,
      'state': filters.location.state,
    });
    selectedBreeds.value = <String>[...filters.breeds];
  }
}
