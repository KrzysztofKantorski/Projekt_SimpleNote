class NoteModel {
  final int id;
  final String title;
  final String content;
  final String? subjectName; // Może być null
  final List<String> tagNames; // Tablica stringów
  final DateTime createdAt; // Parsujemy bezpośrednio na obiekt DateTime
  final DateTime? updatedAt; // Może być null

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.subjectName,
    required this.tagNames,
    required this.createdAt,
    this.updatedAt,
  });

  String get timeAgo {
    final DateTime displayDate = updatedAt ?? createdAt;

    final now = DateTime.now();
    final difference = now.difference(displayDate);

    if (difference.inMinutes < 1) {
      return 'Przed chwilą';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min temu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} godz. temu';
    } else {
      return '${difference.inDays} dni temu';
    }
  }


  //Map to object
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      subjectName: json['subjectName'],
      tagNames: json['tagNames'] != null 
          ? List<String>.from(json['tagNames']) 
          : [],
      // Bezpieczne parsowanie daty ISO 8601
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }


  static List<NoteModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteModel.fromJson(json)).toList();
  }
}