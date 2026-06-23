import 'package:flutter/foundation.dart';
import '../models/reaction/reaction_model.dart';
import '../repositories/reaction_repository.dart';

class ReactionViewModel extends ChangeNotifier {
  final ReactionRepository _repository;

  ReactionViewModel({required ReactionRepository repository})
      : _repository = repository;

  List<ReactionTypeModel> _availableReactions = [];
  List<ReactionTypeModel> get availableReactions => _availableReactions;

  List<NoteReactionModel> _noteReactions = [];
  List<NoteReactionModel> get noteReactions => _noteReactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAvailableReactions() async {
    if (_availableReactions.isNotEmpty) return;
    try {
      _availableReactions = await _repository.getAvailableReactions();
      notifyListeners();
    } catch (e) {
      debugPrint('Błąd ładowania słownika reakcji: $e');
    }
  }

  Future<void> fetchNoteReactions(int noteId) async {
    _start();
    try {
      _noteReactions = await _repository.getNoteReactionsSummary(noteId);
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  Future<bool> toggleReaction(
      int noteId, int reactionTypeId, bool alreadyReacted) async {
    _errorMessage = null;
    try {
      if (alreadyReacted) {
        await _repository.removeReaction(noteId, reactionTypeId);
      } else {
        await _repository.addReaction(noteId, reactionTypeId);
      }
      await fetchNoteReactions(noteId);
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      notifyListeners();
      return false;
    }
  }

  void clearReactions() {
    _noteReactions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // helpers

  void _start() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stop() {
    _isLoading = false;
    notifyListeners();
  }

  String _clean(dynamic e) => e.toString().replaceAll('Exception: ', '');
}