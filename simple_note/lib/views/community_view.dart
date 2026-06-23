import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/community_viewmodel.dart';
import '../viewmodels/reaction_viewmodel.dart';
import '../viewmodels/saved_note_viewmodel.dart';
import '../viewmodels/comment_viewmodel.dart';
import '../components/menu_widgets/bottom_nav_bar.dart';

class CommunityTestView extends StatefulWidget {
  const CommunityTestView({super.key});

  @override
  State<CommunityTestView> createState() => _CommunityTestViewState();
}

class _CommunityTestViewState extends State<CommunityTestView> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityViewModel>().fetchPublicNotes();
      context.read<ReactionViewModel>().fetchAvailableReactions();
      context.read<CommunityViewModel>().fetchSubjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    if (index == 0) context.goNamed('home');
    if (index == 1) context.goNamed('add_note');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        title: const Text(
          'Społeczność',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _searchController.clear();
              viewModel.clearAllFilters();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Pasek Wyszukiwania
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Szukaj publicznych notatek...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (phrase) =>
                      viewModel.fetchPublicNotes(phrase: phrase),
                ),
              ),
            ),

            // Filtry Przedmiotów
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: _buildSubjectFilters(viewModel),
            ),

            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),

            // Lista Notatek
            Expanded(
              child: _buildNotesList(viewModel),
            ),
          ],
        ),
      ),

      // Navbar
      bottomNavigationBar: SnBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }

  // Poziome filtry przedmiotów
  Widget _buildSubjectFilters(CommunityViewModel viewModel) {
    if (viewModel.isSubjectsLoading) {
    return const SizedBox(
      height: 40,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
        ),
      ),
    );
    }

    if (viewModel.subjects.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: viewModel.subjects.map((subject) {
          final isSelected =
              viewModel.selectedSubject?.toLowerCase() ==
                  subject.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(subject),
              selected: isSelected,
              selectedColor: Colors.black,
              backgroundColor: const Color(0xFFF5F5F5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              showCheckmark: false,
              onSelected: (selected) {
                viewModel.setSubjectFilter(
                  selected ? subject : null,
                  phrase: _searchController.text,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesList(CommunityViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          'Błąd: ${viewModel.errorMessage}',
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (viewModel.publicNotes.isEmpty) {
      return const Center(
        child: Text(
          'Brak publicznych notatek.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final savedViewModel = context.watch<SavedNoteViewModel>();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: viewModel.publicNotes.length,
      itemBuilder: (context, index) {
        final note = viewModel.publicNotes[index];
        final formattedDate =
            DateFormat('dd.MM.yyyy').format(note.createdAt);

        final isSaved =
            savedViewModel.savedNotes.any((sn) => sn.id == note.id);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nagłówek: Autor i Data
              Row(
                children: [
                  Text(
                    note.authorName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tytuł notatki
              Text(
                note.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 4),

              // Przedmiot / Kategoria
              Text(
                'Przedmiot: ${note.subjectName}',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),

              // Dolny panel akcji
              Row(
                children: [
                  // Przycisk Zapisz / Usuń z zapisanych
                  InkWell(
                    onTap: () async {
                      await context
                          .read<SavedNoteViewModel>()
                          .toggleSaveStatus(note.id, isSaved);
                    },
                    child: Row(
                      children: [
                        Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 20,
                          color:
                              isSaved ? Colors.black : Colors.black87,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSaved ? 'Zapisano' : 'Zapisz',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSaved
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Przycisk wejścia w szczegóły
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded,
                        size: 20, color: Colors.black),
                    onPressed: () async {
                      final commentVM = context.read<CommentViewModel>();
                      final reactionVM = context.read<ReactionViewModel>();
                      final communityVM = context.read<CommunityViewModel>();
                      
                      final router = GoRouter.of(context);
                      
                      final messenger = ScaffoldMessenger.of(context);
                      commentVM.clearComments();
                      commentVM.fetchComments(note.id);
                      
                      reactionVM.clearReactions();
                      reactionVM.fetchNoteReactions(note.id);

                      final fetchedNote = await communityVM.fetchPublicNoteById(note.id);


                      if (fetchedNote != null) {
                        final noteForDetails = communityVM.convertToNoteModel(fetchedNote);
                        
                        router.pushNamed(
                          'note_details',
                          extra: noteForDetails,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}