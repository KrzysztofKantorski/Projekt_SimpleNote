import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/note/note_model.dart';
import '../models/note/update_note_model.dart';
import '../repositories/note_repository.dart';
import '../services/text_recognition_service.dart';

class NoteViewModel extends ChangeNotifier {
  final NoteRepository _repository;
  final TextRecognitionService _recognitionService;

  NoteViewModel({
    required NoteRepository repository,
    TextRecognitionService? recognitionService,
  })  : _repository = repository,
        _recognitionService = recognitionService ?? TextRecognitionService();

  // Stan Listy

  List<NoteModel> _notes = [];
  List<NoteModel> get notes => _notes;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Stan edycji

  NoteModel? _editingNote;
  NoteModel? get editingNote => _editingNote;

  // Stan OCR

  String? _scannedText;
  String? get scannedText => _scannedText;

  // Operacje

  Future<void> fetchUsersNotes() async {
    _start();
    try {
      _notes = await _repository.getNotes();
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  Future<NoteModel?> fetchNoteById(int id) async {
    _start();
    try {
      final note = await _repository.getNoteById(id);
      return note;
    } catch (e, stackTrace) {
      debugPrint('BŁĄD POBIERANIA NOTATKI: $e');
      debugPrint('STACK TRACE: $stackTrace');
      _errorMessage = _clean(e);
      return null;
    } finally {
      _stop();
    }
  } 

  Future<bool> addNewNote({
    required String title,
    required String content,
    required bool isPublic,
    String? subject,
  }) async {
    _start();
    try {
      await _repository.addNote(
          title: title, content: content, isPublic: isPublic, subject: subject);
      await fetchUsersNotes();
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> updateNote({
    required String title,
    required String content,
    required bool isPublic,
    String? subject,
  }) async {
    if (_editingNote == null) return false;

    _start();
    try {
      await _repository.editNote(
        id: _editingNote!.id,
        request: UpdateNoteRequest(
            title: title, content: content, isPublic: isPublic, subjectName: subject),
      );
      await fetchUsersNotes();
      clearEditor();
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> deleteNote(int id) async {
  _start();
  try {
    await _repository.deleteNote(id);
    await fetchUsersNotes();
    return true;
  } catch (e) {
    _errorMessage = _clean(e);
    return false;
  } finally {
    _stop();
  }
}

  

  void selectNoteForEditing(NoteModel note) {
    _editingNote = note;
    notifyListeners();
  }

  void clearEditor() {
    _editingNote = null;
    _scannedText = null;
    notifyListeners();
  }

  Future<void> scanTextFromImage(ImageSource source) async {
    _start();
    try {
      final result =
          await _recognitionService.recognizeTextFromImage(source: source);
      _scannedText = (result != null && result.trim().isNotEmpty) ? result : null;
    } catch (e) {
      _errorMessage = 'Nie udało się rozpoznać tekstu: $e';
    } finally {
      _stop();
    }
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

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }
}