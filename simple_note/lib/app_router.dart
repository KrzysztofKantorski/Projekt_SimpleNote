import 'package:go_router/go_router.dart';
import 'package:simple_note/viewmodels/app_state_viewmodel.dart';
import 'models/note/note_model.dart';
// Importy widoków
import 'views/onboarding_view.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/addnote_view.dart';
import 'views/editnote_view.dart';
import 'views/note_view.dart';
import 'views/community_view.dart';

class AppRouter {
  static GoRouter createRouter(AppStateViewModel appStateViewModel) {
    return GoRouter(
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
              path: 'add-note',
              name: 'add_note',
              builder: (context, state) => const AddNoteView(),
            ),
            GoRoute(
              path: 'edit', 
              name: 'edit_note',
              builder: (context, state) => const NoteEditorView(),
            ),
            GoRoute(
              path: 'details',
              name: 'note_details',
              builder: (context, state) {
                final noteData = state.extra as NoteModel;
                return NoteDetailsTestView(note: noteData);
              },
            ),
            GoRoute(
              path: 'community',
              name: 'community',
              builder: (context, state) => const CommunityTestView(),)
          ],
        ),
      ],

      // === LOGIKA PRZEKIEROWAŃ ===
      redirect: (context, state) {
        final AppState status = appStateViewModel.currentState;
        final String currentLocation = state.uri.toString();

        if (status == AppState.loading) {
          return null; 
        }
        if (status == AppState.onboarding && currentLocation != '/onboarding') {
          return '/onboarding';
        }

        if (status == AppState.unauthenticated && currentLocation != '/login' && currentLocation != '/onboarding') {
          return '/login';
        }

        if (status == AppState.authenticated && (currentLocation == '/login' || currentLocation == '/onboarding')) {
          return '/home';
        }

        return null;
      },
    );
  }
}