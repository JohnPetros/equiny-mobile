import 'package:equiny/core/shared/constants/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TabNavigationView extends StatelessWidget {
  final String activeRoute;

  const TabNavigationView({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _selectedIndex(activeRoute);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF07090F),
      selectedItemColor: const Color(0xFFB79BFF),
      unselectedItemColor: const Color(0xFF6D7384),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Feed'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Matches'),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Conversations',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (int index) {
        final String route = _routeByIndex(index);
        if (route == activeRoute) {
          return;
        }
        context.go(route);
      },
    );
  }

  int _selectedIndex(String route) {
    switch (route) {
      case Routes.matches:
        return 1;
      case Routes.conversations:
        return 2;
      case Routes.profile:
        return 3;
      case Routes.feed:
      default:
        return 0;
    }
  }

  String _routeByIndex(int index) {
    switch (index) {
      case 0:
        return Routes.feed;
      case 1:
        return Routes.matches;
      case 2:
        return Routes.conversations;
      case 3:
      default:
        return Routes.profile;
    }
  }
}
