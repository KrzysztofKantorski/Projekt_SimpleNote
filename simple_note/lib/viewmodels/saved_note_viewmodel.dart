import 'package:flutter/material.dart';
import '../models/saved_note/saved_note_model.dart';
import '../services/saved_note_service.dart';

class SavedNoteViewModel extends ChangeNotifier {
  final SavedNoteService _savedNoteService = SavedNoteService();

  // --- STANY DANYCH ---
  List<SavedNoteModel> _savedNotes = [];
  List<SavedNoteModel> get savedNotes => _savedNotes;

  // --- STANY UI ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// 1. POBIERANIE LISTY ZAPISANYCH NOTATEK
  Future<void> fetchSavedNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _savedNotes = await _savedNoteService.getSavedNotes();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. PRZEŁĄCZANIE STANU ZAPISANIA (Dodaj / Usuń)
  /// Zwraca true w przypadku sukcesu lub false przy błędzie walidacji z backendu
  Future<bool> toggleSaveStatus(int noteId, bool isCurrentlySaved) async {
    _errorMessage = null;
    notifyListeners();

    try {
      if (isCurrentlySaved) {
        // Jeśli już zapisana -> usuwamy z ulubionych
        await _savedNoteService.removeNoteFromSaved(noteId);
      } else {
        // Jeśli nie była zapisana -> dodajemy
        await _savedNoteService.addNoteToSaved(noteId);
      }

      // Po udanej operacji odświeżamy listę zapisanych notatek
      await fetchSavedNotes();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    }
  }

  /// 3. CZYSZCZENIE STANU PRZY ZMIANIE EKRANÓW
  void clearSavedNotes() {
    _savedNotes = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}