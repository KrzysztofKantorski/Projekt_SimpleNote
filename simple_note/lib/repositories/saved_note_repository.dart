import '../models/saved_note/saved_note_model.dart';
import '../services/saved_note_service.dart';

abstract class SavedNoteRepository {
  Future<List<SavedNoteModel>> getSavedNotes();
  Future<void> addNoteToSaved(int noteId);
  Future<void> removeNoteFromSaved(int noteId);
}

class SavedNoteRepositoryImpl implements SavedNoteRepository {
  final SavedNoteService _savedNoteService;

  const SavedNoteRepositoryImpl({required SavedNoteService savedNoteService})
      : _savedNoteService = savedNoteService;

  @override
  Future<List<SavedNoteModel>> getSavedNotes() =>
      _savedNoteService.getSavedNotes();

  @override
  Future<void> addNoteToSaved(int noteId) =>
      _savedNoteService.addNoteToSaved(noteId);

  @override
  Future<void> removeNoteFromSaved(int noteId) =>
      _savedNoteService.removeNoteFromSaved(noteId);
}
