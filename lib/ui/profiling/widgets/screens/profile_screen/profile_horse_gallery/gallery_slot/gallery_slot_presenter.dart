import 'package:equiny/core/profiling/dtos/structures/image_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GallerySlotPresenter {
  bool isPrimary({required int slotIndex}) {
    return slotIndex == 0;
  }

  bool hasImage({required int slotIndex, required int totalImages}) {
    return slotIndex < totalImages;
  }

  ImageDto? getImage({required int slotIndex, required List<ImageDto> images}) {
    if (slotIndex < images.length) {
      return images[slotIndex];
    }
    return null;
  }

  String? getImageUrl({
    required ImageDto? image,
    required String Function(String) getUrlFromKey,
  }) {
    if (image == null) return null;
    return getUrlFromKey(image.key);
  }

  bool canSetPrimary({required int slotIndex, required int totalImages}) {
    return hasImage(slotIndex: slotIndex, totalImages: totalImages) &&
        slotIndex > 0;
  }

  bool canRemove({required int slotIndex, required int totalImages}) {
    return hasImage(slotIndex: slotIndex, totalImages: totalImages);
  }

  bool canAdd({
    required int slotIndex,
    required int totalImages,
    required int maxImages,
    required bool isUploading,
  }) {
    return !hasImage(slotIndex: slotIndex, totalImages: totalImages) &&
        !isUploading &&
        totalImages < maxImages;
  }
}

final gallerySlotPresenterProvider = Provider<GallerySlotPresenter>((ref) {
  return GallerySlotPresenter();
});
