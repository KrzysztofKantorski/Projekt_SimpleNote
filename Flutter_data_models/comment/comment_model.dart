class CommentModel {
  final int id; 
  final String content;
  final String authorName;
  final DateTime createdAt;
  final List<CommentModel> replies; //lista odpowiedzi

  CommentModel({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.replies,
  });

  //Map to object
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      replies: json['replies'] != null
          ? (json['replies'] as List).map((reply) => CommentModel.fromJson(reply)).toList()
          : [],
    );
  }

  // Metoda toJson na wypadek, gdyby backend wymagał wysłania pełnej struktury przy POST
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Content': content,
      'AuthorName': authorName,
      'CreatedAt': createdAt.toIso8601String(),
      'Replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }

  // Metoda pomocnicza do mapowania głównej listy komentarzy z endpointu GET
  static List<CommentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CommentModel.fromJson(json)).toList();
  }
}