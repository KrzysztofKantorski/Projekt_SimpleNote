import 'package:flutter/material.dart';
import '../models/reaction/reaction_model.dart';
import '../services/reaction_service.dart';

class ReactionViewModel extends ChangeNotifier {
  final ReactionService _reactionService = ReactionService();

  // Słownik wszystkich typów reakcji w systemie
  List<ReactionTypeModel> _availableReactions = [];
  List<ReactionTypeModel> get availableReactions => _availableReactions;

  // Reakcje przypisane do aktualnie otwartej notatki
  List<NoteReactionModel> _noteReactions = [];
  List<NoteReactionModel> get noteReactions => _noteReactions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Pobranie globalnego słownika reakcji (Warto odpalić np. przy starcie aplikacji raz)
  Future<void> fetchAvailableReactions() async {
    if (_availableReactions.isNotEmpty) return; // Zapobiega ponownemu pobieraniu stałych danych
    try {
      _availableReactions = await _reactionService.getAvailableReactions();
      notifyListeners();
    } catch (e) {
      print("Błąd ładowania słownika reakcji: $e");
    }
  }

  /// Pobranie podsumowania reakcji dla wybranej notatki
  Future<void> fetchNoteReactions(int noteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _noteReactions = await _reactionService.getNoteReactionsSummary(noteId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Przełączanie reakcji (Dodaj jeśli nie ma, Usuń jeśli już kliknięta)
  Future<bool> toggleReaction(int noteId, int reactionTypeId, bool alreadyReacted) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (alreadyReacted) {
        // Jeśli użytkownik już to kliknął -> usuwamy
        await _reactionService.removeReaction(noteId, reactionTypeId);
      } else {
        // Jeśli nie klikał -> dodajemy
        await _reactionService.addReaction(noteId, reactionTypeId);
      }

      // Po udanej operacji odświeżamy licznik reakcji dla notatki
      await fetchNoteReactions(noteId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// Czyszczenie pamięci przed wejściem na inną notatkę (podobnie jak przy komentarzach)
  void clearReactions() {
    _noteReactions = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}