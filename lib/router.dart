import 'dart:async';

import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/core/profiling/dtos/structures/feed_horse_dto.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/shared/widgets/components/tab_navigation/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/chat_screen/index.dart';
import 'package:equiny/ui/conversation/widgets/screens/inbox_screen/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_horse_details_screen/index.dart';
import 'package:equiny/ui/profiling/feed/widgets/screens/feed_screen/index.dart';
import 'package:equiny/ui/matches/widgets/screens/matches_screen/index.dart';
import 'package:equiny/rest/services.dart';
import 'package:equiny/ui/profiling/widgets/screens/profile_screen/index.dart';
import 'package:equiny/ui/profiling/widgets/screens/onboarding_screen/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final cacheDriver = ref.watch(cacheDriverProvider);
  final profilingService = ref.watch(profilingServiceProvider);

  return GoRouter(
    initialLocation: Routes.signIn,
    redirect: (BuildContext context, GoRouterState state) async {
      final String currentRoute = state.matchedLocation;
      final bool isAuthenticated =
          (cacheDriver.get(CacheKeys.accessToken) ?? '').isNotEmpty;

      final bool isSignIn = currentRoute == Routes.signIn;
      final bool isSignUp = currentRoute == Routes.signUp;

      if (!isAuthenticated) {
        if (isSignIn || isSignUp) {
          return null;
        }
        return Routes.signIn;
      }

      if (isSignIn || isSignUp) {
        return Routes.feed;
      }

      final ownerResponse = await profilingService.fetchOwner();
      if (ownerResponse.isFailure) {
        unawaited(cacheDriver.set(CacheKeys.accessToken, ''));
        unawaited(cacheDriver.set(CacheKeys.onboardingCompleted, ''));
        return isSignIn || isSignUp ? null : Routes.signIn;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.signIn,
        builder: (BuildContext context, GoRouterState state) {
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: TabNavigation(
              activeRoute: state.matchedLocation,
            ),
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: Routes.feed,
            builder: (BuildContext context, GoRouterState state) {
              return const FeedScreen();
            },
          ),
          GoRoute(
            path: Routes.matches,
            builder: (BuildContext context, GoRouterState state) {
              return const MatchesScreen();
            },
          ),
          GoRoute(
            path: Routes.inbox,
            builder: (BuildContext context, GoRouterState state) {
              return const InboxScreen();
            },
          ),
          GoRoute(
            path: Routes.profile,
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
      GoRoute(
        path: Routes.feedHorseDetails,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! FeedHorseDto) {
            return const FeedScreen();
          }

          return FeedHorseDetailsScreen(horse: extra);
        },
      ),
      GoRoute(
        path: Routes.chat,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          final String chatId = extra is String ? extra : '';
          if (chatId.isEmpty) {
            return const InboxScreen();
          }
          return ChatScreen(chatId: chatId);
        },
      ),
    ],
  );
});
