import 'package:flutter/foundation.dart';
import '../models/comment/comment_model.dart';
import '../repositories/comment_repository.dart';
class CommentViewModel extends ChangeNotifier {
  final CommentRepository _repository;

  CommentViewModel({required CommentRepository repository})
      : _repository = repository;

  List<CommentModel> _comments = [];
  List<CommentModel> get comments => _comments;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchComments(int noteId) async {
    _start();
    try {
      _comments = await _repository.getComments(noteId);
    } catch (e) {
      _errorMessage = _clean(e);
    } finally {
      _stop();
    }
  }

  Future<bool> addComment(int noteId, String text) async {
    if (text.trim().isEmpty) return false;

    _start();
    try {
      await _repository.addComment(noteId: noteId, content: text.trim());
      await fetchComments(noteId);
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> deleteComment(int commentId, int noteId) async {
    _start();
    try {
      await _repository.deleteComment(commentId, noteId);
      await fetchComments(noteId);
      return true;
    } catch (e) {
      _errorMessage = _clean(e);
      return false;
    } finally {
      _stop();
    }
  }

  void clearComments() {
    _comments = [];
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