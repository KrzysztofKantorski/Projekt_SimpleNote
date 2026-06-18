import 'package:flutter/material.dart';
import '../models/community/community_note_model.dart';
import '../services/community_service.dart';
import '../models/note/note_model.dart';
class CommunityViewModel extends ChangeNotifier {
  final CommunityService _communityService = CommunityService();

  List<CommunityNoteModel> _publicNotes = [];
  List<CommunityNoteModel> get publicNotes => _publicNotes;

  CommunityNoteModel? _selectedNoteDetails;
  CommunityNoteModel? get selectedNoteDetails => _selectedNoteDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TextEditingController searchController = TextEditingController();
  String? _selectedSubject;

  String? get selectedSubject => _selectedSubject;

  // Pobieranie publicznych notatek
  Future<void> fetchPublicNotes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _publicNotes = await _communityService.getPublicNotes(
        phrase: searchController.text.trim(),
        subject: _selectedSubject,
        tag: null,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pobieranie szczegółów wybranej notatki
  Future<void> fetchPublicNoteDetails(int noteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedNoteDetails = await _communityService.getPublicNoteById(noteId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
  void setSubjectFilter(String? subject) {
    _selectedSubject = subject;
    fetchPublicNotes(); 
  }

  void clearAllFilters() {
    searchController.clear();
    _selectedSubject = null;
    fetchPublicNotes();
  }

  void clearSelectedNote() {
    _selectedNoteDetails = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}