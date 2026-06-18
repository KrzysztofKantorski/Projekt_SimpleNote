import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note/note_model.dart';
import '../models/note/update_note_model.dart';
import '../services/note_service.dart';
import '../services/text_recognition_service.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  final TextRecognitionService _recognitionService = TextRecognitionService();

  // Główna lista notatek pobrana z API
  List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  final TextEditingController contentController = TextEditingController();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
  Future<bool> addNewNote({required String title, required String content, required bool isPublic}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _noteService.addNote(
        title: title,
        content: content,
        isPublic: isPublic,
      );

      await fetchUsersNotes(); 
      
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === 3. EDYCJA ISTNIEJĄCEJ NOTATKI (PUT) ===
  Future<bool> updateNote({required bool isPublic}) async {
    if (_editingNoteId == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateNoteRequest(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        isPublic: isPublic,
      );

      await _noteService.editNote(
        id: _editingNoteId!,
        request: request,
      );

      await fetchUsersNotes();
      clearEditor();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // === NOWE POLA DLA EDYCJI ===
  int? _editingNoteId;
  final TextEditingController titleController = TextEditingController();

  void selectNoteForEditing(NoteModel note) {
    _editingNoteId = note.id;
    titleController.text = note.title;
    contentController.text = note.content;
  }

  /// Czyszczenie edytora
  void clearEditor() {
    _editingNoteId = null;
    titleController.clear();
    contentController.clear();
  }
  // === 4. SKANOWANIE TEKSTU ===
  Future<void> scanTextAndAppend(ImageSource source) async {
    _isLoading = true;
    notifyListeners();

    try {
      final scannedText = await _recognitionService.recognizeTextFromImage(source: source);
      
      if (scannedText != null && scannedText.trim().isNotEmpty) {
        // Jeśli w edytorze już coś jest, dodajemy tekst w nowej linii
        if (contentController.text.isNotEmpty) {
          contentController.text += '\n$scannedText';
        } else {
          contentController.text = scannedText;
        }
      }
    } catch (e) {
      _errorMessage = "Nie udało się rozpoznać tekstu: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    _recognitionService.dispose(); // czyścimy zasoby ML Kit
    super.dispose();
  }
}