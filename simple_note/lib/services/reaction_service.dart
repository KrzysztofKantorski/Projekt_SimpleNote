import 'package:dio/dio.dart';
import 'dio_error_helper.dart';
import '../models/reaction/reaction_model.dart';

class ReactionService {
  final Dio _dio;

  const ReactionService({required Dio dio}) : _dio = dio;

  Future<List<ReactionTypeModel>> getAvailableReactions() async {
    try {
      final response = await _dio.get('/api/reaction-types');
      final List<dynamic> raw = response.data;
      return ReactionTypeModel.fromJsonList(raw);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<List<NoteReactionModel>> getNoteReactionsSummary(int noteId) async {
    try {
      final response = await _dio.get('/api/notes/$noteId/reactions');
      final List<dynamic> raw = response.data;
      return NoteReactionModel.fromJsonList(raw);
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> addReaction(int noteId, int reactionTypeId) async {
    try {
      await _dio.post('/api/notes/$noteId/reactions/$reactionTypeId');
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }

  Future<void> removeReaction(int noteId, int reactionTypeId) async {
    try {
      await _dio.delete('/api/notes/$noteId/reactions/$reactionTypeId');
    } on DioException catch (e) {
      throw Exception(extractDioErrorMessage(e));
    }
  }
}