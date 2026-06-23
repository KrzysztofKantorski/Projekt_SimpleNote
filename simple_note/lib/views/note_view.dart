import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note/note_model.dart';
import '../viewmodels/comment_viewmodel.dart';
import '../viewmodels/reaction_viewmodel.dart';

class NoteDetailsTestView extends StatefulWidget {
  final NoteModel note;

  const NoteDetailsTestView({super.key, required this.note});

  @override
  State<NoteDetailsTestView> createState() => _NoteDetailsTestViewState();
}

class _NoteDetailsTestViewState extends State<NoteDetailsTestView> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentViewModel = context.watch<CommentViewModel>();
    final reactionViewModel = context.watch<ReactionViewModel>();
    final int noteId = widget.note.id;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.note.title.isNotEmpty ? widget.note.title : 'Notes Title',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dane notatki
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    widget.note.content.isNotEmpty
                        ? widget.note.content
                        : 'Notes Sample / first side of notes here',
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                  const Divider(
                      height: 1, thickness: 1, color: Colors.black12),
                  const SizedBox(height: 16),

                  // Nagłówek komentarzy i reakcje
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Komentarze',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      _buildReactionsSection(
                          context, reactionViewModel, noteId),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Lista komentarzy
            Expanded(
              child: _buildCommentsList(context, commentViewModel, noteId),
            ),

            // Dodawanie komentarza
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.comment_outlined,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: ' Dodaj komentarz',
                          hintStyle: TextStyle(
                              color: Colors.black54, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: commentViewModel.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : const Icon(Icons.send,
                              size: 16, color: Colors.black54),
                      onPressed: commentViewModel.isLoading
                          ? null
                          : () async {
                              final success = await context
                                  .read<CommentViewModel>()
                                  .addComment(
                                      noteId, _commentController.text);
                              if (success) {
                                _commentController.clear();
                              } else if (commentViewModel.errorMessage !=
                                      null &&
                                  context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                        commentViewModel.errorMessage!),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactionsSection(
      BuildContext context, ReactionViewModel viewModel, int noteId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...viewModel.noteReactions.map((reaction) {
          return InkWell(
            onTap: () async {
              final success = await viewModel.toggleReaction(
                  noteId,
                  reaction.reactionTypeId,
                  reaction.reactedByCurrentUser);
              if (!success &&
                  viewModel.errorMessage != null &&
                  context.mounted) {
                _showErrorSnackBar(context, viewModel.errorMessage!);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Row(
                children: [
                  Text(
                    reaction.iconUrl.isNotEmpty ? reaction.iconUrl : '♡',
                    style: TextStyle(
                      fontSize: 16,
                      color: reaction.reactedByCurrentUser
                          ? Colors.red
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reaction.count}',
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }),
        InkWell(
          onTap: () {
            context.read<ReactionViewModel>().fetchAvailableReactions();
            _showReactionPicker(context, viewModel, noteId);
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Icon(Icons.add_reaction_outlined,
                size: 18, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  void _showReactionPicker(
      BuildContext context, ReactionViewModel viewModel, int noteId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer<ReactionViewModel>(
          builder: (context, rVM, child) {
            if (rVM.isLoading) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              );
            }

            if (rVM.availableReactions.isEmpty) {
              return const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Brak dostępnych reakcji',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(16.0),
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dodaj reakcję:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: rVM.availableReactions.length,
                      itemBuilder: (context, index) {
                        final type = rVM.availableReactions[index];
                        final bool alreadySelected = rVM.noteReactions
                            .any((nr) =>
                                nr.reactionTypeId == type.id &&
                                nr.reactedByCurrentUser);

                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            final success = await rVM.toggleReaction(
                                noteId, type.id, alreadySelected);
                            if (!success &&
                                rVM.errorMessage != null &&
                                context.mounted) {
                              _showErrorSnackBar(
                                  context, rVM.errorMessage!);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey.shade100,
                              child: Text(
                                  type.imageUrl.isNotEmpty
                                      ? type.imageUrl
                                      : '😀'),
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
      SnackBar(
          backgroundColor: Colors.red,
          content: Text('Akcja niedozwolona: $message')),
    );
  }

  Widget _buildCommentsList(
      BuildContext context, CommentViewModel viewModel, int noteId) {
    if (viewModel.isLoading && viewModel.comments.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.black));
    }
    if (viewModel.errorMessage != null && viewModel.comments.isEmpty) {
      return Center(
          child: Text('Błąd: ${viewModel.errorMessage}',
              style: const TextStyle(color: Colors.red)));
    }
    if (viewModel.comments.isEmpty) {
      return const Center(
          child: Text('Brak komentarzy dla tej notatki.',
              style: TextStyle(color: Colors.black54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: viewModel.comments.length,
      itemBuilder: (context, index) {
        final comment = viewModel.comments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName
                          : 'User name',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(
                          color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline,
                    size: 16, color: Colors.black26),
                onPressed: () async {
                  final success =
                      await viewModel.deleteComment(comment.id, noteId);
                  if (!success &&
                      viewModel.errorMessage != null &&
                      context.mounted) {
                    _showErrorSnackBar(context, viewModel.errorMessage!);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}