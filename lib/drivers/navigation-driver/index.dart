import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:equiny/drivers/navigation-driver/go-router/go_router_navigation_driver.dart';
import 'package:equiny/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationDriverProvider = Provider<NavigationDriver>((ref) {
  return GoRouterNavigationDriver(ref.watch(routerProvider));
});
