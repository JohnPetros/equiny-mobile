import 'dart:async';

import 'package:equiny/core/matching/interfaces/matching_service.dart';
import 'package:equiny/core/profiling/dtos/entities/horse_dto.dart';
import 'package:equiny/core/profiling/dtos/structures/horse_match_dto.dart';
import 'package:equiny/core/profiling/interfaces/profiling_service.dart';
import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/drivers/navigation-driver/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signals/signals.dart';

class MatchesScreenPresenter {
  final ProfilingService _profilingService;
  final MatchingService _matchingService;
  final NavigationDriver _navigationDriver;

  final Signal<List<HorseMatchDto>> matches = signal(<HorseMatchDto>[]);
  final Signal<bool> isLoadingInitial = signal(false);
  final Signal<String?> errorMessage = signal(null);
  final Signal<String?> activeHorseId = signal(null);
  final Signal<HorseMatchDto?> selectedMatch = signal(null);
  final Signal<bool> isOptionsDialogOpen = signal(false);

  late final ReadonlySignal<List<HorseMatchDto>> newMatches;
  late final ReadonlySignal<List<HorseMatchDto>> seenMatches;
  late final ReadonlySignal<int> newCount;
  late final ReadonlySignal<bool> isEmptyState;
  late final ReadonlySignal<bool> hasError;

  MatchesScreenPresenter(
    this._profilingService,
    this._matchingService,
    this._navigationDriver,
  ) {
    newMatches = computed(() {
      final List<HorseMatchDto> items = matches.value
          .where((HorseMatchDto item) => !item.isViewed)
          .toList();
      items.sort(_sortByCreatedAtDesc);
      return items;
    });

    seenMatches = computed(() {
      final List<HorseMatchDto> items = matches.value
          .where((HorseMatchDto item) => item.isViewed)
          .toList();
      items.sort(_sortByCreatedAtDesc);
      return items;
    });

    newCount = computed(() => newMatches.value.length);
    hasError = computed(() => errorMessage.value != null);
    isEmptyState = computed(() {
      return !isLoadingInitial.value &&
          !hasError.value &&
          matches.value.isEmpty;
    });
  }

  void init() {
    unawaited(loadMatches());
  }

  Future<void> retry() async {
    await loadMatches();
  }

  Future<void> loadMatches() async {
    isLoadingInitial.value = true;
    errorMessage.value = null;

    final ownerHorsesResponse = await _profilingService.fetchOwnerHorses();
    if (ownerHorsesResponse.isFailure) {
      errorMessage.value = ownerHorsesResponse.errorMessage;
      isLoadingInitial.value = false;
      return;
    }

    final List<HorseDto> horses = ownerHorsesResponse.body;
    if (horses.isEmpty) {
      matches.value = <HorseMatchDto>[];
      isLoadingInitial.value = false;
      return;
    }

    final HorseDto activeHorse = horses.firstWhere(
      (HorseDto horse) => horse.isActive,
      orElse: () => horses.first,
    );

    final String horseId = activeHorse.id ?? '';
    if (horseId.isEmpty) {
      errorMessage.value = 'Nao foi possivel identificar o cavalo ativo.';
      isLoadingInitial.value = false;
      return;
    }

    activeHorseId.value = horseId;

    final response = await _profilingService.fetchHorseMatches(
      horseId: horseId,
    );
    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      isLoadingInitial.value = false;
      return;
    }

    final List<HorseMatchDto> sorted = <HorseMatchDto>[...response.body]
      ..sort(_sortByCreatedAtDesc);
    matches.value = sorted;
    isLoadingInitial.value = false;
  }

  void openMatchOptions(HorseMatchDto match) {
    selectedMatch.value = match;
    isOptionsDialogOpen.value = true;
  }

  void closeMatchOptions() {
    isOptionsDialogOpen.value = false;
    selectedMatch.value = null;
  }

  Future<void> _viewMatchAndNavigateTo(String route) async {
    final HorseMatchDto? match = selectedMatch.value;
    final String horseId = activeHorseId.value ?? '';
    if (match == null || horseId.isEmpty) {
      closeMatchOptions();
      _navigationDriver.goTo(route);
      return;
    }

    if (!match.isViewed) {
      final response = await _profilingService.viewHorseMatch(
        fromHorseId: horseId,
        toHorseId: match.ownerHorseId,
      );

      if (response.isSuccessful) {
        matches.value = matches.value.map((HorseMatchDto item) {
          if (item.ownerHorseId != match.ownerHorseId) {
            return item;
          }

          return HorseMatchDto(
            ownerId: item.ownerId,
            ownerName: item.ownerName,
            ownerAvatar: item.ownerAvatar,
            ownerHorseId: item.ownerHorseId,
            ownerLocation: item.ownerLocation,
            isViewed: true,
            createdAt: item.createdAt,
          );
        }).toList()..sort(_sortByCreatedAtDesc);
      }

      if (response.isFailure) {
        errorMessage.value = response.errorMessage;
        return;
      }
    }

    closeMatchOptions();
    _navigationDriver.goTo(route);
  }

  Future<void> handleTapViewProfile() async {
    await _viewMatchAndNavigateTo(Routes.conversations);
  }

  Future<void> handleTapSendMessage() async {
    await _viewMatchAndNavigateTo(Routes.conversations);
  }

  void goToFeed() {
    _navigationDriver.goTo(Routes.feed);
  }

  int _sortByCreatedAtDesc(HorseMatchDto a, HorseMatchDto b) {
    return b.createdAt.compareTo(a.createdAt);
  }

  Future<bool> handleDeleteMatch(HorseMatchDto match) async {
    final String horseId = activeHorseId.value ?? '';
    if (horseId.isEmpty) {
      errorMessage.value = 'Nao foi possivel identificar o cavalo ativo.';
      return false;
    }

    final response = await _matchingService.dismatchHorse(
      fromHorseId: horseId,
      toHorseId: match.ownerHorseId,
    );

    if (response.isFailure) {
      errorMessage.value = response.errorMessage;
      return false;
    }

    await loadMatches();

    return true;
  }
}

final matchesScreenPresenterProvider =
    Provider.autoDispose<MatchesScreenPresenter>((ref) {
      final presenter = MatchesScreenPresenter(
        ref.watch(profilingServiceProvider),
        ref.watch(matchingServiceProvider),
        ref.watch(navigationDriverProvider),
      );
      presenter.init();
      return presenter;
    });
