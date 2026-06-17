import 'package:flutter/material.dart';
import '../models/comment/comment_model.dart';
import '../services/comment_service.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentService _commentService = CommentService();

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final TextEditingController commentController = TextEditingController();

  /// 1. POBIERANIE KOMENTARZY
  Future<void> fetchComments(int noteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _commentService.getCommentsForNote(noteId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2. DODAWANIE KOMENTARZA
  Future<bool> addComment(int noteId) async {
    final text = commentController.text.trim();
    if (text.isEmpty) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentService.addComment(noteId: noteId, content: text);
      commentController.clear(); 
      await fetchComments(noteId); // Re-fetch po sukcesie
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3. USUWANIE KOMENTARZA
  Future<bool> deleteComment(int commentId, int noteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _commentService.deleteComment(commentId, noteId);
      await fetchComments(noteId); // Re-fetch po sukcesie
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// RESETOWANIE STANU PRZY ZMIANIE EKRANU
  void clearComments() {
    _comments = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners(); 
  }
}