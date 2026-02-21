import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:signals/signals.dart';

class FeedHorseDetailsScreenPresenter {
  final FeedHorseDto horse;
  final FileStorageDriver? fileStorageDriver;

  final Signal<bool> isLoadingDetails = signal(false);
  final Signal<String?> detailsError = signal(null);
  final Signal<int> currentImageIndex = signal(0);

  late final ReadonlySignal<String> horseAgeLabel;
  late final ReadonlySignal<bool> hasGallery;
  late final ReadonlySignal<String?> currentImageUrl;
  late final ReadonlySignal<String> sexLabel;
  late final ReadonlySignal<String> locationLabel;
  late final ReadonlySignal<String> heightLabel;
  late final ReadonlySignal<String> breedLabel;

  FeedHorseDetailsScreenPresenter(this.horse, {this.fileStorageDriver}) {
    horseAgeLabel = computed(() {
      final DateTime now = DateTime.now();
      final int birthYear = horse.birthYear;
      if (birthYear <= 0) {
        return '--';
      }

      final int birthMonth = horse.birthMonth.clamp(1, 12);
      int age = now.year - birthYear;
      if (now.month < birthMonth) {
        age -= 1;
      }

      if (age <= 0) {
        return '0';
      }
      return '$age';
    });

    hasGallery = computed(() => horse.imageUrls.isNotEmpty);

    currentImageUrl = computed(() {
      if (horse.imageUrls.isEmpty) {
        return null;
      }

      final int index = currentImageIndex.value;
      final String key = horse
          .imageUrls[index < 0 || index >= horse.imageUrls.length ? 0 : index];

      if (fileStorageDriver == null) {
        return key;
      }

      return fileStorageDriver!.getImageUrl(key);
    });

    sexLabel = computed(() {
      final String normalized = horse.sex.trim().toLowerCase();
      if (normalized == 'female' || normalized == 'femea') {
        return 'Femea';
      }
      if (normalized == 'male' || normalized == 'macho') {
        return 'Macho';
      }
      return horse.sex;
    });

    locationLabel = computed(() {
      return '${horse.location.city}, ${horse.location.state}';
    });

    heightLabel = computed(() => '${horse.height.toStringAsFixed(2)}m');

    breedLabel = computed(() {
      final String breed = horse.breed.trim();
      if (breed.isEmpty) {
        return 'Nao informado';
      }
      return breed;
    });
  }

  void nextImage() {
    if (horse.imageUrls.isEmpty) {
      return;
    }

    currentImageIndex.value =
        (currentImageIndex.value + 1) % horse.imageUrls.length;
  }

  void previousImage() {
    if (horse.imageUrls.isEmpty) {
      return;
    }

    final int next = currentImageIndex.value - 1;
    currentImageIndex.value = next < 0 ? horse.imageUrls.length - 1 : next;
  }
}
