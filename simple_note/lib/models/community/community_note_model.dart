class CommunityNoteModel {
  final int id;
  final String title;
  final String? content; // Obecne tylko w widoku szczegółów
  final String authorName;
  final String subjectName;
  final List<String> tagNames;
  final DateTime createdAt;
  final DateTime? updatedAt; // Może być null
  final bool? isSavedByCurrentUser; // Obecne tylko w widoku szczegółów

  CommunityNoteModel({
    required this.id,
    required this.title,
    this.content,
    required this.authorName,
    required this.subjectName,
    required this.tagNames,
    required this.createdAt,
    this.updatedAt,
    this.isSavedByCurrentUser,
  });

  // Map to object
  factory CommunityNoteModel.fromJson(Map<String, dynamic> json) {
    return CommunityNoteModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'], // Jeśli klucza nie ma w JSON (na liście), przypisze null
      authorName: json['authorName'] ?? 'Anonim',
      subjectName: json['subjectName'] ?? 'Brak przedmiotu',
      tagNames: json['tagNames'] != null 
          ? List<String>.from(json['tagNames']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isSavedByCurrentUser: json['isSavedByCurrentUser'], // Przypisze null lub wartość bool
    );
  }

  // Pomocnicza metoda do mapowania całej tablicy JSON na Listę obiektów Dart
  static List<CommunityNoteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CommunityNoteModel.fromJson(json)).toList();
  }
}