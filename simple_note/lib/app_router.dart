import 'package:go_router/go_router.dart';
import 'package:simple_note/viewmodels/app_state_viewmodel.dart';
import 'models/note/note_model.dart';
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
          builder: (_, _) => const OnboardingView(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (_, _) => const LoginView(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (_, _) => const HomeView(),
          routes: [
            GoRoute(
              path: 'add-note',
              name: 'add_note',
              builder: (_, _) => const AddNoteView(),
            ),
            GoRoute(
              path: 'edit',
              name: 'edit_note',
              builder: (_, _) => const NoteEditorView(),
            ),
            GoRoute(
              path: 'details',
              name: 'note_details',
              builder: (_, state) =>
                  NoteDetailsTestView(note: state.extra as NoteModel),
            ),
            GoRoute(
              path: 'community',
              name: 'community',
              builder: (_, _) => const CommunityTestView(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final status = appStateViewModel.currentState;
        final location = state.uri.toString();

        if (status == AppState.loading) return null;

        if (status == AppState.onboarding && location != '/onboarding') {
          return '/onboarding';
        }
        if (status == AppState.unauthenticated &&
            location != '/login' &&
            location != '/onboarding') {
          return '/login';
        }
        if (status == AppState.authenticated &&
            (location == '/login' || location == '/onboarding')) {
          return '/home';
        }

        return null;
      },
    );
  }
}