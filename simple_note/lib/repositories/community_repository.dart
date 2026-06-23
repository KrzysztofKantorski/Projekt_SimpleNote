import '../models/community/community_note_model.dart';
import '../services/community_service.dart';

abstract class CommunityRepository {
  Future<List<CommunityNoteModel>> getPublicNotes({
    String? phrase,
    String? subject,
    String? tag,
  });
  Future<CommunityNoteModel> getPublicNoteById(int noteId);
  Future<List<String>> getSubjects();
}

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityService _communityService;

  const CommunityRepositoryImpl({required CommunityService communityService})
      : _communityService = communityService;

  @override
  Future<List<CommunityNoteModel>> getPublicNotes({
    String? phrase,
    String? subject,
    String? tag,
  }) =>
      _communityService.getPublicNotes(
          phrase: phrase, subject: subject, tag: tag);

  @override
  Future<CommunityNoteModel> getPublicNoteById(int noteId) =>
      _communityService.getPublicNoteById(noteId);

  @override
  Future<List<String>> getSubjects() =>
      _communityService.getSubjects();
}