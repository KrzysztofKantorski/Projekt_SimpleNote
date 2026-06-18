import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/viewmodels/auth_viewmodel.dart';
import 'package:simple_note/viewmodels/comment_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/note_viewmodel.dart';
import '../viewmodels/app_state_viewmodel.dart';
import '../components/menu_widgets/menu_widgets.dart';
import '../viewmodels/reaction_viewmodel.dart';
import '../viewmodels/saved_note_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}
class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pobieranie własnych notatek
      Provider.of<NoteViewModel>(context, listen: false).fetchUsersNotes();
      // POBIERANIE ZAPISANYCH NOTATEK
      Provider.of<SavedNoteViewModel>(context, listen: false).fetchSavedNotes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    if (index == 1) context.pushNamed('add_note');
    if (index == 2) context.goNamed('community');
  }

  @override
  Widget build(BuildContext context) {
    final noteViewModel = Provider.of<NoteViewModel>(context);
    final savedNoteViewModel = Provider.of<SavedNoteViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await Provider.of<AuthViewModel>(context, listen: false).logout();
                      Provider.of<UserViewModel>(context, listen: false).clearUser();
                      Provider.of<AppStateViewModel>(context, listen: false).logoutSuccess();
                    },
                    tooltip: 'Wyloguj',
                  ),
                ],
              ),
            ),
            
            // — Przełącznik sekcji (Moje lub Zapisane) —
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: 'Moje'),
                  Tab(text: 'Zapisane'),
                ],
              ),
            ),
            
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Zakładka 1: Twoje notatki własne
                  _buildBodyContent(noteViewModel),
                  // Zakładka 2: Notatki zapisane ze społeczności
                  _buildSavedNotesContent(savedNoteViewModel),
                ],
              ),
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

  //Moje notatki===
  Widget _buildBodyContent(NoteViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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

    if (viewModel.notes != null) {
      if (viewModel.notes!.isEmpty) {
        return const Center(
          child: Text(
            'Nie masz jeszcze żadnych notatek.\nStwórz swoją pierwszą notatkę!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: viewModel.notes.length, 
        itemBuilder: (context, index) {
          final currentNote = viewModel.notes[index];

          return SnNoteListItem(
            title: currentNote.title,
            content: currentNote.content,
            timeAgo: currentNote.timeAgo, 
            onTap: () {
              context.read<CommentViewModel>().clearComments();
              context.read<CommentViewModel>().fetchComments(currentNote.id);

              context.read<ReactionViewModel>().clearReactions();
              context.read<ReactionViewModel>().fetchNoteReactions(currentNote.id);

              context.pushNamed(
                'note_details',
                extra: currentNote,
              );
            },
            onEditClick: () {
              context.read<NoteViewModel>().selectNoteForEditing(currentNote);
              context.pushNamed('edit_note');
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  // Zapisane Notatki
  Widget _buildSavedNotesContent(SavedNoteViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                onPressed: () => viewModel.fetchSavedNotes(),
                child: const Text('Spróbuj ponownie'),
              )
            ],
          ),
        ),
      );
    }

    if (viewModel.savedNotes.isEmpty) {
      return const Center(
        child: Text(
          'Nie masz żadnych zapisanych notatek.\nZnajdź ciekawe materiały w zakładce społeczności!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: viewModel.savedNotes.length,
      itemBuilder: (context, index) {
        final savedNote = viewModel.savedNotes[index];

        return SnNoteListItem(
          title: savedNote.title,
          content: 'Autor: ${savedNote.authorName} • ${savedNote.subjectName}',
          timeAgo: '',
          onTap: () {
            context.read<CommentViewModel>().clearComments();
            context.read<CommentViewModel>().fetchComments(savedNote.id);

            context.read<ReactionViewModel>().clearReactions();
            context.read<ReactionViewModel>().fetchNoteReactions(savedNote.id);

            context.pushNamed(
              'note_details',
              extra: savedNote, 
            );
          },
          onEditClick: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nie możesz edytować zapisanych notatek innych użytkowników.')),
            );
          },
        );
      },
    );
  }
}