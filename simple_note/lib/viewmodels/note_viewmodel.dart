import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note/note_model.dart';
import '../models/saved_note/saved_note_model.dart';
import '../models/note/update_note_model.dart';
import '../services/note_service.dart';
import '../services/text_recognition_service.dart'; // Twój serwis od ML Kit

class NoteViewModel extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  final TextRecognitionService _recognitionService = TextRecognitionService();

  // Główna lista notatek pobrana z API
  List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  String _query = '';
  String get query => _query;

  List<NoteModel> _results = [];
  List<NoteModel> get results => _results;

  // Kontrolery i stan dla widoku dodawania/edycji (ML Kit)
  final TextEditingController contentController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // === 1. POBIERANIE NOTATEK Z API ===

  void search(String q) {
    _query = q;
    if (q.trim().isEmpty) {
      _results = [];
    } else {
      // Filtrujemy po tytule lub treści notatki (ignorując wielkość liter)
      _results = _notes.where((note) {
        final titleMatch = note.title.toLowerCase().contains(q.toLowerCase());
        final contentMatch = note.content.toLowerCase().contains(q.toLowerCase());
        return titleMatch || contentMatch;
      }).toList();
    }
    notifyListeners(); // Odświeża widok wyszukiwania przy każdej wpisanej literze
  }

  // === 1. POBIERANIE NOTATEK Z API ===
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

 // === 2. DODAWANIE NOWEJ NOTATKI (POST) ===
  Future<bool> addNewNote({required String title, required String content}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Wysyłamy dane na serwer (zapis do bazy)
      await _noteService.addNote(
        title: title,
        content: content,
        isPublic: true,
      );

      // 2. Skoro zapisało się w bazie, pobieramy całą listę na nowo jako NoteModel
      await fetchUsersNotes(); 
      
      return true; // Sukces, widok może się zamknąć
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === 3. EDYCJA ISTNIEJĄCEJ NOTATKI (PUT) ===
  Future<bool> updateNote() async {
    if (_editingNoteId == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateNoteRequest(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        isPublic: true,
      );

      await _noteService.editNote(
        id: _editingNoteId!,
        request: request,
      );

      await fetchUsersNotes();
      clearEditor(); // Czyścimy po udanym zapisie
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // === NOWE POLA DLA EDYCJI (MVVM) ===
  int? _editingNoteId;
  final TextEditingController titleController = TextEditingController(); // Przenosimy kontroler tytułu tutaj!

  /// Metoda przygotowująca ViewModel do edycji konkretnej notatki
  void selectNoteForEditing(NoteModel note) {
    _editingNoteId = note.id;
    titleController.text = note.title;
    contentController.text = note.content;
    // Nie potrzebujemy notifyListeners(), bo wywołamy to tuż przed wejściem na ekran
  }

  /// Czyszczenie edytora
  void clearEditor() {
    _editingNoteId = null;
    titleController.clear();
    contentController.clear();
  }
  // === 4. SKANOWANIE TEKSTU (ML KIT INTEGATION) ===
  Future<void> scanTextFromCamera() async {
    _isLoading = true;
    notifyListeners();

    // Serwis odpala aparat i wyciąga tekst
    final String? scannedText = await _recognitionService.scanFromCamera();

    if (scannedText != null && scannedText.isNotEmpty) {
      // Jeśli w polu coś już było, doklejamy od nowej linii
      if (contentController.text.isEmpty) {
        contentController.text = scannedText;
      } else {
        contentController.text += "\n$scannedText";
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    contentController.dispose();
    _recognitionService.dispose(); // czyścimy zasoby ML Kit
    super.dispose();
  }
}