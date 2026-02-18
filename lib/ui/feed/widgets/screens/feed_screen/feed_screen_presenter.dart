import 'dart:async';
import 'dart:convert';

import 'package:equiny/core/matching/dtos/structures/swipe_dto.dart';
import 'package:equiny/core/matching/interfaces/matching_service.dart';
import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/age_range_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_feed_filters_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/location_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/cache_driver.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class FeedScreenPresenter {
  final ProfilingService _profilingService;
  final MatchingService _matchingService;
  final CacheDriver _cacheDriver;
  final NavigationDriver _navigationDriver;

  final Signal<List<FeedHorseDto>> cards = signal(<FeedHorseDto>[]);
  final Signal<HorseFeedFiltersDto?> filters = signal(null);
  final Signal<int> currentIndex = signal(0);
  final Signal<String> nextCursor = signal('');
  final Signal<String?> currentHorseId = signal(null);
  final Signal<bool> isLoadingInitial = signal(false);
  final Signal<bool> isLoadingMore = signal(false);
  final Signal<bool> isApplyingFilters = signal(false);
  final Signal<bool> isSubmittingSwipe = signal(false);
  final Signal<bool> isBlocked = signal(false);
  final Signal<String?> errorMessage = signal(null);
  final Signal<String?> blockedMessage = signal(null);

  late final ReadonlySignal<FeedHorseDto?> currentCard;
  late final ReadonlySignal<bool> hasCards;
  late final ReadonlySignal<bool> hasNextPage;
  late final ReadonlySignal<int> activeFiltersCount;
  late final ReadonlySignal<bool> isEndOfFeed;

  FeedScreenPresenter(
    this._profilingService,
    this._matchingService,
    this._cacheDriver,
    this._navigationDriver,
  ) {
    currentCard = computed(() {
      final List<FeedHorseDto> value = cards.value;
      if (currentIndex.value < 0 || currentIndex.value >= value.length) {
        return null;
      }
      return value[currentIndex.value];
    });
    hasCards = computed(() => cards.value.isNotEmpty);
    hasNextPage = computed(() => nextCursor.value.isNotEmpty);
    activeFiltersCount = computed(() {
      final HorseFeedFiltersDto? value = filters.value;
      if (value == null) {
        return 0;
      }

      int count = 0;
      if (value.breeds.isNotEmpty) {
        count += 1;
      }
      if (value.location.city.trim().isNotEmpty ||
          value.location.state.trim().isNotEmpty) {
        count += 1;
      }
      if (value.ageRange.min != 1 || value.ageRange.max != 30) {
        count += 1;
      }

      return count;
    });
    isEndOfFeed = computed(() {
      return !isLoadingInitial.value &&
          cards.value.isEmpty &&
          nextCursor.value.isEmpty &&
          errorMessage.value == null &&
          !isBlocked.value;
    });
  }

  void init() {
    unawaited(loadInitialFeed());
  }

  Future<void> loadInitialFeed() async {
    isLoadingInitial.value = true;
    errorMessage.value = null;
    isBlocked.value = false;
    blockedMessage.value = null;
    nextCursor.value = '';
    currentIndex.value = 0;

    final horseResponse = await _profilingService.fetchOwnerHorses();
    if (horseResponse.isFailure) {
      isLoadingInitial.value = false;
      errorMessage.value = horseResponse.errorMessage;
      return;
    }

    final List<HorseDto> horses = horseResponse.body;
    if (horses.isEmpty) {
      _blockFeed('Cadastre um cavalo para comecar a usar o feed.');
      return;
    }

    final HorseDto horse = horses.firstWhere(
      (HorseDto item) => item.isActive,
      orElse: () => horses.first,
    );
    final String horseId = horse.id ?? '';
    if (horseId.isEmpty) {
      _blockFeed('Nao foi possivel identificar o cavalo ativo.');
      return;
    }

    currentHorseId.value = horseId;

    if (horse.name.trim().isEmpty ||
        horse.sex.trim().isEmpty ||
        horse.location.state.trim().isEmpty) {
      _blockFeed(
        'Complete os dados obrigatorios do cavalo para liberar o feed.',
      );
      return;
    }

    final galleryResponse = await _profilingService.fetchHorseGallery(
      horseId: horseId,
    );
    if (galleryResponse.isFailure || galleryResponse.body.images.isEmpty) {
      _blockFeed('Adicione pelo menos uma foto do cavalo para liberar o feed.');
      return;
    }

    final HorseFeedFiltersDto defaultFilters = _buildDefaultFilters(horse);
    final HorseFeedFiltersDto resolvedFilters =
        _readCachedFilters(defaultFilters) ?? defaultFilters;

    filters.value = resolvedFilters;
    await _fetchFeed(resetCards: true);
    isLoadingInitial.value = false;
  }

  Future<void> loadNextPage() async {
    if (isLoadingMore.value || nextCursor.value.isEmpty || isBlocked.value) {
      return;
    }

    isLoadingMore.value = true;
    errorMessage.value = null;
    await _fetchFeed(resetCards: false);
    isLoadingMore.value = false;
  }

  Future<void> retry() async {
    await loadInitialFeed();
  }

  Future<void> applyFilters(HorseFeedFiltersDto nextFilters) async {
    if (isApplyingFilters.value || isBlocked.value) {
      return;
    }

    isApplyingFilters.value = true;
    filters.value = nextFilters;
    await _saveCachedFilters(nextFilters);
    nextCursor.value = '';
    currentIndex.value = 0;
    await _fetchFeed(resetCards: true);
    isApplyingFilters.value = false;
  }

  Future<void> clearFilters() async {
    final horseResponse = await _profilingService.fetchOwnerHorses();
    if (horseResponse.isFailure || horseResponse.body.isEmpty) {
      return;
    }

    final HorseDto horse = horseResponse.body.firstWhere(
      (HorseDto item) => item.isActive,
      orElse: () => horseResponse.body.first,
    );

    final HorseFeedFiltersDto defaultFilters = _buildDefaultFilters(horse);
    await applyFilters(defaultFilters);
  }

  Future<void> likeCurrentHorse() async {
    await _submitSwipe(decision: 'like');
  }

  Future<void> dislikeCurrentHorse() async {
    await _submitSwipe(decision: 'dislike');
  }

  void goToHorseDetails() {
    final FeedHorseDto? horse = currentCard.value;
    if (horse == null) {
      return;
    }

    _navigationDriver.goTo(Routes.feedHorseDetails, data: horse);
  }

  void goToProfile() {
    _navigationDriver.goTo(Routes.profile);
  }

  Future<void> _submitSwipe({required String decision}) async {
    final FeedHorseDto? horse = currentCard.value;
    final String fromHorseId = currentHorseId.value ?? '';

    if (horse == null || fromHorseId.isEmpty || isSubmittingSwipe.value) {
      return;
    }

    isSubmittingSwipe.value = true;
    errorMessage.value = null;

    final response = await _matchingService.swipeHorse(
      swipeDto: SwipeDto(
        toHorseId: horse.id,
        fromHorseId: fromHorseId,
        decision: decision,
      ),
    );

    if (response.isFailure) {
      isSubmittingSwipe.value = false;
      errorMessage.value = response.errorMessage;
      return;
    }

    final List<FeedHorseDto> updatedCards = <FeedHorseDto>[
      ...cards.value,
    ]..removeAt(currentIndex.value);
    cards.value = updatedCards;

    if (cards.value.isEmpty && nextCursor.value.isNotEmpty) {
      await loadNextPage();
    }

    isSubmittingSwipe.value = false;
  }

  Future<void> _fetchFeed({required bool resetCards}) async {
    final String horseId = currentHorseId.value ?? '';
    final HorseFeedFiltersDto? value = filters.value;

    if (horseId.isEmpty || value == null) {
      errorMessage.value = 'Nao foi possivel carregar o feed.';
      return;
    }

    final response = await _profilingService.fetchHorseFeed(
      horseId: horseId,
      sex: value.sex,
      breeds: value.breeds,
      ageRange: value.ageRange,
      location: value.location,
      limit: value.limit,
      cursor: nextCursor.value,
    );

    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      return;
    }

    final nextItems = response.body.items;
    cards.value = resetCards
        ? nextItems
        : <FeedHorseDto>[...cards.value, ...nextItems];
    nextCursor.value = response.body.nextCursor;
  }

  HorseFeedFiltersDto _buildDefaultFilters(HorseDto horse) {
    return HorseFeedFiltersDto(
      sex: _oppositeSex(horse.sex),
      breeds: const <String>[],
      ageRange: const AgeRangeDto(min: 1, max: 30),
      location: LocationDto(
        city: horse.location.city,
        state: horse.location.state,
      ),
      limit: 10,
    );
  }

  String _oppositeSex(String sex) {
    final normalized = sex.trim().toLowerCase();
    if (normalized == 'male' || normalized == 'macho') {
      return 'female';
    }
    if (normalized == 'female' || normalized == 'femea') {
      return 'male';
    }
    return '';
  }

  HorseFeedFiltersDto? _readCachedFilters(HorseFeedFiltersDto fallback) {
    final String? cached = _cacheDriver.get(CacheKeys.feedFilters);
    if (cached == null || cached.isEmpty) {
      return null;
    }

    try {
      final raw = jsonDecode(cached) as Map<String, dynamic>;
      return HorseFeedFiltersDto(
        sex: raw['sex']?.toString() ?? fallback.sex,
        breeds: (raw['breeds'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic item) => item.toString())
            .toList(),
        ageRange: AgeRangeDto(
          min:
              int.tryParse(raw['ageMin']?.toString() ?? '') ??
              fallback.ageRange.min,
          max:
              int.tryParse(raw['ageMax']?.toString() ?? '') ??
              fallback.ageRange.max,
        ),
        location: LocationDto(
          city: raw['city']?.toString() ?? fallback.location.city,
          state: raw['state']?.toString() ?? fallback.location.state,
        ),
        cursor: null,
        limit: 10,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCachedFilters(HorseFeedFiltersDto value) async {
    final payload = <String, dynamic>{
      'sex': value.sex,
      'breeds': value.breeds,
      'ageMin': value.ageRange.min,
      'ageMax': value.ageRange.max,
      'city': value.location.city,
      'state': value.location.state,
    };

    await _cacheDriver.set(CacheKeys.feedFilters, jsonEncode(payload));
  }

  void _blockFeed(String message) {
    isBlocked.value = true;
    blockedMessage.value = message;
    isLoadingInitial.value = false;
    cards.value = <FeedHorseDto>[];
    nextCursor.value = '';
  }
}

final feedScreenPresenterProvider = Provider.autoDispose<FeedScreenPresenter>((
  ref,
) {
  final presenter = FeedScreenPresenter(
    ref.watch(profilingServiceProvider),
    ref.watch(matchingServiceProvider),
    ref.watch(cacheDriverProvider),
    ref.watch(navigationDriverProvider),
  );
  presenter.init();
  return presenter;
});
