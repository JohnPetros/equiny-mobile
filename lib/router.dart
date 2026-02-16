import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/core/shared/constants/cache_keys.dart';
import 'package:equiny/drivers/cache-driver/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_in_screen/index.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/index.dart';
import 'package:equiny/ui/home/widgets/screens/home_screen/index.dart';
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
    initialLocation: Routes.profile,
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

      final ownerResponse = await profilingService.fetchOwner();
      if (ownerResponse.isFailure) {
        return Routes.signIn;
      }
      final bool hasCompletedOnboarding =
          ownerResponse.body.hasCompletedOnboarding;
      if (!hasCompletedOnboarding) {
        return Routes.onboarding;
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
      GoRoute(
        path: Routes.home,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: Routes.profile,
        builder: (BuildContext context, GoRouterState state) {
          return const ProfileScreen();
        },
      ),
    ],
  );
});
