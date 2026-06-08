//Request
class UpdateNoteRequest {
  final String title;
  final String content;
  final String? subjectName; 
  final List<String>? tagNames; 
  final bool isPublic;

  UpdateNoteRequest({
    required this.title,
    required this.content,
    this.subjectName,
    this.tagNames,
    required this.isPublic,
  });

  // Mapowanie na JSON
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Content': content,
      'SubjectName': subjectName,
      'TagNames': tagNames,
      'IsPublic': isPublic,
    };
  }
}