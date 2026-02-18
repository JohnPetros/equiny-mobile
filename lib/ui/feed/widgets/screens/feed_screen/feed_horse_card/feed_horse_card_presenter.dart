import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/storage/interfaces/file_storage_driver.dart';
import 'package:signals/signals.dart';

class FeedHorseCardPresenter {
  final FeedHorseDto horse;
  final Signal<int> currentImageIndex = signal(0);
  final FileStorageDriver _fileStorageDriver;

  late final ReadonlySignal<String?> currentImageUrl;

  FeedHorseCardPresenter(this.horse, this._fileStorageDriver) {
    currentImageUrl = computed(() {
      if (horse.imageUrls.isEmpty) {
        return null;
      }
      if (currentImageIndex.value < 0 ||
          currentImageIndex.value >= horse.imageUrls.length) {
        return _fileStorageDriver.getImageUrl(horse.imageUrls.first);
      }
      return _fileStorageDriver.getImageUrl(
        horse.imageUrls[currentImageIndex.value],
      );
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
