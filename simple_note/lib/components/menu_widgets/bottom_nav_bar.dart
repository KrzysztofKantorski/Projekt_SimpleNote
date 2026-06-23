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
          BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0? Icons.home_filled : Icons.home_outlined,
            color: currentIndex == 0 ? Colors.black : Colors.grey,
          ),
          label: 'Notatki',
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
            label: 'Dodaj',
          ),
          // Avatar użytkownika
          BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? Icons.groups_rounded : Icons.groups_outlined,
            color: currentIndex == 2 ? Colors.black : Colors.grey,
          ),
          label: 'Społeczność',
        ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: const Color(0xFF888888),
      ),
    );
  }
}
