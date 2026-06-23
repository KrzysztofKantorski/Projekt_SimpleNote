import 'package:flutter/foundation.dart';
import '../models/community/community_note_model.dart';
import '../models/note/note_model.dart';
import '../repositories/community_repository.dart';

class CommunityViewModel extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityViewModel({required CommunityRepository repository})
      : _repository = repository;

  List<CommunityNoteModel> _publicNotes = [];
  List<CommunityNoteModel> get publicNotes => _publicNotes;

  List<String> _subjects = [];
  List<String> get subjects => _subjects;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _selectedSubject;
  String? get selectedSubject => _selectedSubject;

  bool _isSubjectsLoading = false;
  bool get isSubjectsLoading => _isSubjectsLoading;

  CommunityNoteModel? _currentDetailsNote;
  CommunityNoteModel? get currentDetailsNote => _currentDetailsNote;

  // Operacje

  Future<void> fetchPublicNotes({String phrase = ''}) async {
    _start();
    try {
      _publicNotes = await _repository.getPublicNotes(
        phrase: phrase.trim().isEmpty ? null : phrase.trim(),
        subject: _selectedSubject,
        tag: null,
      );
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  Future<CommunityNoteModel?> fetchPublicNoteById(int noteId) async {
    _start();
    try {
      final fullNote = await _repository.getPublicNoteById(noteId);
      _currentDetailsNote = fullNote;
      return fullNote;
    } catch (e) {
      _errorMessage = _clean(e);
      return null;
    } finally {
      _stop();
    }
  }

  void clearCurrentDetailsNote() {
    _currentDetailsNote = null;
    notifyListeners();
  }

  void setSubjectFilter(String? subject, {String phrase = ''}) {
    _selectedSubject = subject;
    fetchPublicNotes(phrase: phrase);
  }

  void clearAllFilters() {
    _selectedSubject = null;
    fetchPublicNotes();
  }

  NoteModel convertToNoteModel(CommunityNoteModel communityNote) {
    return NoteModel(
      id: communityNote.id,
      title: communityNote.title,
      content: communityNote.content ?? '',
      subjectName: communityNote.subjectName,
      tagNames: communityNote.tagNames,
      createdAt: communityNote.createdAt,
      updatedAt: communityNote.updatedAt,
    );
  }
  // przedmioty

  Future<void> fetchSubjects() async {
    _isSubjectsLoading = true;
    notifyListeners();

    try {
      _subjects = await _repository.getSubjects();
    } catch (e) {
      _subjects = [];
    } finally {
      _isSubjectsLoading = false;
      notifyListeners();
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
}