import 'package:flutter/material.dart';

/// Dolna nawigacja aplikacji
/// 0 = Home (notatki), 1 = Add (TODO), 2 = Profile (ustawienia)
class SnBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String? avatarUrl;

  const SnBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          // Dom
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          // Dodaj notatkę (TODO)
          BottomNavigationBarItem(
            icon: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.black),
            ),
            label: 'Add',
          ),
          // Avatar użytkownika
          BottomNavigationBarItem(
            icon: _AvatarIcon(url: avatarUrl, isActive: currentIndex == 2),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF888888),
      ),
    );
  }
}

class _AvatarIcon extends StatelessWidget {
  final String? url;
  final bool isActive;

  const _AvatarIcon({this.url, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFDDDDDD),
        border: isActive
            ? Border.all(color: Colors.black, width: 2)
            : null,
        image: url != null
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover)
            : null,
      ),
      child: url == null
          ? const Icon(Icons.person, size: 16, color: Color(0xFF888888))
          : null,
    );
  }
}
