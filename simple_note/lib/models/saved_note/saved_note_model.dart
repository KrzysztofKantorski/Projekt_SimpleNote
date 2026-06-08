class SavedNoteModel {
  final int id;
  final String title;
  final String authorName;
  final String subjectName;
  final List<String> tagNames;
  final DateTime createdAt;

  SavedNoteModel({
    required this.id,
    required this.title,
    required this.authorName,
    required this.subjectName,
    required this.tagNames,
    required this.createdAt,
  });

  //Map to object
  factory SavedNoteModel.fromJson(Map<String, dynamic> json) {
    return SavedNoteModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      authorName: json['authorName'] ?? 'Anonim',
      subjectName: json['subjectName'] ?? 'Brak przedmiotu',
      tagNames: json['tagNames'] != null 
          ? List<String>.from(json['tagNames']) 
          : [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Pomocnicza metoda do mapowania całej listy zapisanych notatek
  static List<SavedNoteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SavedNoteModel.fromJson(json)).toList();
  }
}