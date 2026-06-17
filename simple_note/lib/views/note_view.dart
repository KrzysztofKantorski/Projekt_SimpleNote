import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note/note_model.dart';
import '../viewmodels/comment_viewmodel.dart';
import '../viewmodels/reaction_viewmodel.dart'; // Import nowego ViewModelu

class NoteDetailsTestView extends StatelessWidget {
  final NoteModel note;

  const NoteDetailsTestView({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final commentViewModel = context.watch<CommentViewModel>();
    final reactionViewModel = context.watch<ReactionViewModel>(); // Słuchamy reakcji
    final int noteId = note.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Szczegóły i Komentarze'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === 1. DANE NOTATKI ===
              Text('TYTUŁ: ${note.title}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('TREŚĆ:\n${note.content}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              // === NOWOŚĆ: SEKCJA REAKCJI ===
              _buildReactionsSection(context, reactionViewModel, noteId),
              
              const Divider(height: 40, thickness: 2, color: Colors.black12),
              
              // === 2. DODAWANIE KOMENTARZA ===
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentViewModel.commentController,
                      decoration: const InputDecoration(hintText: 'Napisz komentarz...'),
                    ),
                  ),
                  IconButton(
                    icon: commentViewModel.isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                    onPressed: commentViewModel.isLoading 
                        ? null 
                        : () async {
                            final success = await context.read<CommentViewModel>().addComment(noteId);
                            if (!success && commentViewModel.errorMessage != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(backgroundColor: Colors.red, content: Text(commentViewModel.errorMessage!)),
                              );
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === 3. LISTA KOMENTARZY ===
              const Text('KOMENTARZE:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              
              Expanded(
                child: _buildCommentsList(commentViewModel, noteId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // === BUDOWANIE SEKCJI REAKCJI ===
  Widget _buildReactionsSection(BuildContext context, ReactionViewModel viewModel, int noteId) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // 1. Renderujemy reakcje już dodane pod notatką
        ...viewModel.noteReactions.map((reaction) {
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Jeśli masz obrazki URL z backendu, użyj Image.network, dla testów może być tekst/ikona
                Text(reaction.iconUrl.isNotEmpty ? reaction.iconUrl : "👍"), 
                const SizedBox(width: 4),
                Text('${reaction.count}', style: TextStyle(fontWeight: reaction.reactedByCurrentUser ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
            selected: reaction.reactedByCurrentUser,
            selectedColor: Colors.blue.withOpacity(0.2),
            onSelected: (_) async {
              final success = await viewModel.toggleReaction(noteId, reaction.reactionTypeId, reaction.reactedByCurrentUser);
              if (!success && viewModel.errorMessage != null && context.mounted) {
                _showErrorSnackBar(context, viewModel.errorMessage!);
              }
            },
          );
        }),

        // 2. Przycisk '+' do otwierania panelu wyboru nowej reakcji
        IconButton(
          icon: const Icon(Icons.add_reaction_outlined, color: Colors.grey),
          onPressed: () {
            // Upewniamy się, że słownik jest pobrany przed pokazaniem menu
            context.read<ReactionViewModel>().fetchAvailableReactions();
            _showReactionPicker(context, viewModel, noteId);
          },
        ),
      ],
    );
  }

  // === DOLNY PANEL (BOTTOM SHEET) DO WYBORU REAKCJI ===
  void _showReactionPicker(BuildContext context, ReactionViewModel viewModel, int noteId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<ReactionViewModel>(
          builder: (context, rVM, child) {
            if (rVM.availableReactions.isEmpty) {
              return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dodaj reakcję:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rVM.availableReactions.length,
                      itemBuilder: (context, index) {
                        final type = rVM.availableReactions[index];
                        
                        // Sprawdzamy czy użytkownik przypadkiem już nie zaznaczył tej konkretnej ikony
                        final bool alreadySelected = rVM.noteReactions.any((nr) => nr.reactionTypeId == type.id && nr.reactedByCurrentUser);

                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context); // Zamykamy dolny panel
                            final success = await rVM.toggleReaction(noteId, type.id, alreadySelected);
                            if (!success && rVM.errorMessage != null && context.mounted) {
                              _showErrorSnackBar(context, rVM.errorMessage!);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(type.imageUrl.isNotEmpty ? type.imageUrl : "😀"), // Wyświetla emoji lub grafikę
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text('Akcja niedozwolona: $message')),
    );
  }

  // === ISTNIEJĄCA LISTA KOMENTARZY (Zostaje bez zmian) ===
  Widget _buildCommentsList(CommentViewModel viewModel, int noteId) {
    if (viewModel.isLoading && viewModel.comments.isEmpty) return const Center(child: CircularProgressIndicator());
    if (viewModel.errorMessage != null && viewModel.comments.isEmpty) return Center(child: Text('❌ Błąd: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.red)));
    if (viewModel.comments.isEmpty) return const Center(child: Text('Brak komentarzy dla tej notatki.'));

    return ListView.builder(
      itemCount: viewModel.comments.length,
      itemBuilder: (context, index) {
        final comment = viewModel.comments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(comment.content),
                  ]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  onPressed: () async {
                    final success = await viewModel.deleteComment(comment.id, noteId);
                    if (!success && viewModel.errorMessage != null && context.mounted) {
                      _showErrorSnackBar(context, viewModel.errorMessage!);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}