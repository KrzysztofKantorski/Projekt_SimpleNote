import 'package:flutter/material.dart';
import '../services/note_service.dart';
import 'package:simple_note/models/note/note_model.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  String _query = '';
  List<NoteModel>? _notes;
  List<NoteModel> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NoteModel>? get notes => _notes;
  String get query => _query;
  List<NoteModel> get results => _results;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  //Get data
  Future<void> fetchUsersNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _notes = await _noteService.getNotes();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<void> search(String query) async {
    _query = query;

    if (query.trim().isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (_notes == null) {
    try {
      _notes = await _noteService.getNotes();
    } catch (_) {
      _notes = [];
    }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: zastąpić prawdziwym wywołaniem serwisu
    _results = _mockSearch(query);

    _isLoading = false;
    notifyListeners();
  }

List<NoteModel> _mockSearch(String query) {
    final q = query.toLowerCase();
    return notes!
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q))
        .toList();
  }

  //Clear state after logout
  void clearNotes() {
    _notes = null;
    notifyListeners();
  }
}