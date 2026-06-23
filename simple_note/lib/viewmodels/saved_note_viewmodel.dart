import 'package:flutter/foundation.dart';
import '../models/saved_note/saved_note_model.dart';
import '../repositories/saved_note_repository.dart';

class SavedNoteViewModel extends ChangeNotifier {
  final SavedNoteRepository _repository;

  SavedNoteViewModel({required SavedNoteRepository repository})
      : _repository = repository;

  List<SavedNoteModel> _savedNotes = [];
  List<SavedNoteModel> get savedNotes => _savedNotes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSavedNotes() async {
    _start();
    try {
      _savedNotes = await _repository.getSavedNotes();
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  Future<bool> toggleSaveStatus(int noteId, bool isCurrentlySaved) async {
    _errorMessage = null;
    try {
      if (isCurrentlySaved) {
        await _repository.removeNoteFromSaved(noteId);
      } else {
        await _repository.addNoteToSaved(noteId);
      }
      await fetchSavedNotes();
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      notifyListeners();
      return false;
    }
  }

  void clearSavedNotes() {
    _savedNotes = [];
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