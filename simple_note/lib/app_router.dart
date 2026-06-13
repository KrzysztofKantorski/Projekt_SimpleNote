import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_note/viewmodels/app_state_viewmodel.dart';

// Importy Twoich widoków
import 'views/onboarding_view.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/search_view.dart'; 

class AppRouter {
  static GoRouter createRouter(AppStateViewModel appStateViewModel) {
    return GoRouter(
      // Zmieniamy punkt startowy na /login
      initialLocation: '/login',
      refreshListenable: appStateViewModel,
      
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingView(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeView(),
          routes: [
            GoRoute(
              path: 'search',
              name: 'search',
              builder: (context, state) => const SearchNotesView(),
            ),
          ],
        ),
      ],

      // === ZMODYFIKOWANA LOGIKA PRZEKIEROWAŃ ===
      redirect: (context, state) {
        final AppState status = appStateViewModel.currentState;
        final String currentLocation = state.uri.toString();

        // 1. Jeśli aplikacja JEST W TRAKCIE ŁADOWANIA, nie rób żadnych przekierowań.
        // Pozwól jej dokończyć initializeAppState() na ekranie startowym.
        if (status == AppState.loading) {
          return null; 
        }

        // 2. Jeśli trzeba pokazać onboarding
        if (status == AppState.onboarding && currentLocation != '/onboarding') {
          return '/onboarding';
        }

        // 3. Jeśli użytkownik jest NIEZALOGOWANY
        if (status == AppState.unauthenticated && currentLocation != '/login' && currentLocation != '/onboarding') {
          return '/login';
        }

        // 4. Jeśli użytkownik JEST ZALOGOWANY, a próbuje wrócić na ekrany startowe
        if (status == AppState.authenticated && (currentLocation == '/login' || currentLocation == '/onboarding')) {
          return '/home';
        }

        return null;
      },
    );
  }
}