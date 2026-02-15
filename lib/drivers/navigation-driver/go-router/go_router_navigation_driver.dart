import 'package:equiny/core/shared/interfaces/navigation_driver.dart';
import 'package:go_router/go_router.dart';

class GoRouterNavigationDriver implements NavigationDriver {
  final GoRouter _router;

  GoRouterNavigationDriver(this._router);

  @override
  bool canGoBack() {
    return _router.canPop();
  }

  @override
  void goBack() {
    if (_router.canPop()) {
      _router.pop();
    }
  }

  @override
  void goTo(String route, {Object? data}) {
    _router.go(route, extra: data);
  }
}
