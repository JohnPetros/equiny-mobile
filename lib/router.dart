import 'package:equiny/core/shared/constants/routes.dart';
import 'package:equiny/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.signUp,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.signUp,
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreenView();
        },
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(body: Center(child: Text('Entrar')));
        },
      ),
      GoRoute(
        path: Routes.createHorse,
        builder: (BuildContext context, GoRouterState state) {
          return const Scaffold(body: Center(child: Text('Criar cavalo')));
        },
      ),
    ],
  );
});
