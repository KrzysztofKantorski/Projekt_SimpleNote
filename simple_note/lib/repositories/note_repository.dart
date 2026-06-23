import '../models/note/note_model.dart';
import '../models/note/update_note_model.dart';
import '../services/note_service.dart';

abstract class NoteRepository {
  Future<List<NoteModel>> getNotes();
  Future<void> addNote({
    required String title,
    required String content,
    required bool isPublic,
    String? subject,
  });
  Future<void> editNote({required int id, required UpdateNoteRequest request});
  Future<void> deleteNote(int id);
  Future<NoteModel> getNoteById(int id);
}

class NoteRepositoryImpl implements NoteRepository {
  final NoteService _noteService;

  const NoteRepositoryImpl({required NoteService noteService})
      : _noteService = noteService;

  @override
  Future<List<NoteModel>> getNotes() => _noteService.getNotes();

  @override
  Future<void> addNote({
    required String title,
    required String content,
    required bool isPublic,
    String? subject,
  }) =>
      _noteService.addNote(title: title, content: content, isPublic: isPublic, subjectName: subject);

  @override
  Future<void> editNote({required int id, required UpdateNoteRequest request}) =>
      _noteService.editNote(id: id, request: request);

  @override
  Future<void> deleteNote(int id) => _noteService.deleteNote(id);

  @override
  Future<NoteModel> getNoteById(int id) => _noteService.getNoteById(id);
}
