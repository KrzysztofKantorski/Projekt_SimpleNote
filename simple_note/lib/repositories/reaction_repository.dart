import '../models/reaction/reaction_model.dart';
import '../services/reaction_service.dart';

abstract class ReactionRepository {
  Future<List<ReactionTypeModel>> getAvailableReactions();
  Future<List<NoteReactionModel>> getNoteReactionsSummary(int noteId);
  Future<void> addReaction(int noteId, int reactionTypeId);
  Future<void> removeReaction(int noteId, int reactionTypeId);
}

class ReactionRepositoryImpl implements ReactionRepository {
  final ReactionService _reactionService;

  const ReactionRepositoryImpl({required ReactionService reactionService})
      : _reactionService = reactionService;

  @override
  Future<List<ReactionTypeModel>> getAvailableReactions() =>
      _reactionService.getAvailableReactions();

  @override
  Future<List<NoteReactionModel>> getNoteReactionsSummary(int noteId) =>
      _reactionService.getNoteReactionsSummary(noteId);

  @override
  Future<void> addReaction(int noteId, int reactionTypeId) =>
      _reactionService.addReaction(noteId, reactionTypeId);

  @override
  Future<void> removeReaction(int noteId, int reactionTypeId) =>
      _reactionService.removeReaction(noteId, reactionTypeId);
}
