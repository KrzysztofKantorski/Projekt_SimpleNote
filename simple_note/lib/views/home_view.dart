import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';
import '../viewmodels/app_state_viewmodel.dart';
import '../components/menu_widgets/menu_widgets.dart';
import 'search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}


class _HomeViewState extends State<HomeView>{
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    // Od razu po wyrenderowaniu widoku zlecamy pobranie profilu.
    // listen: false jest tu wymagane, bo jesteśmy w funkcji inicjalizującej.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteViewModel>(context, listen: false).fetchUsersNotes();
    });
  }
  void _onNavTap(int index) {
    if (index == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodawanie notatki — wkrótce!')),
      );
    } else if (index == 1) {
      // TODO: ekran dodawania notatki
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodawanie notatki — wkrótce!')),
      );
    } else if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodawanie notatki — wkrótce!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = Provider.of<NoteViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
              // — AppBar —
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
                child: Row(
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      // TODO: otwieranie wyszukiwarki notatek innych użytkowników
                      icon: const Icon(Icons.search, size: 24),
                      onPressed: ()  {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchNotesView()),
                        );
                       },
                     ),
                    //Logout button
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        //Dalete token
                          await Provider.of<AuthViewModel>(context, listen: false).logout();
              
                        //Delete data from view
                          Provider.of<UserViewModel>(context, listen: false).clearUser();
              
                        //Navigate to login
                          Provider.of<AppStateViewModel>(context, listen: false).logoutSuccess();
                      },
                      tooltip: 'Wyloguj',
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: Color(0xFFEEEEEE)),
              Expanded(
                child: _buildBodyContent(noteViewModel),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SnBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }


Widget _buildBodyContent(NoteViewModel viewModel) {
  // 1. STAN ŁADOWANIA
  if (viewModel.isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // 2. STAN BŁĘDU
  if (viewModel.errorMessage != null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Błąd: ${viewModel.errorMessage}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchUsersNotes(),
              child: const Text('Spróbuj ponownie'),
            )
          ],
        ),
      ),
    );
  }

  // 3. STAN SUKCESU (Pobrano notatki)
  if (viewModel.notes != null) {
    // Sprawdzamy, czy lista z backendu .NET jest pusta
    if (viewModel.notes!.isEmpty) {
      return const Center(
        child: Text(
          'Nie masz jeszcze żadnych notatek.\nStwórz swoją pierwszą notatkę!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Renderujemy listę wszystkich notatek użytkownika
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.notes!.length,
      itemBuilder: (_, i) => SnNoteListItem(
        note: viewModel.notes![i],
        // onTap: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => NotePreviewScreen(
        //         note: viewModel.notes![i],
        //       ),
        //     ),
        //   );
        // },
        onDownload: () {
          // TODO: download notatki
        },
      ),
    );
  }

  return const Center(
    child: Text('Brak danych do wyświetlenia'),
  );
}
}
