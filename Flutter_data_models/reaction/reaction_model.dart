// MODEL 1: Słownik wszystkich dostępnych reakcji (/api/reaction-types)
class ReactionTypeModel {
  final int id;
  final String name;
  final String imageUrl;

  ReactionTypeModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ReactionTypeModel.fromJson(Map<String, dynamic> json) {
    return ReactionTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  static List<ReactionTypeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ReactionTypeModel.fromJson(json)).toList();
  }
}



// MODEL 2: Reakcje przypisane do konkretnej notatki (/api/notes/{id}/reactions)
class NoteReactionModel {
  final int reactionTypeId; 
  final String name;
  final String iconUrl; 
  final int count; // Ilość reakcji pod notatką
  final bool reactedByCurrentUser; 

  NoteReactionModel({
    required this.reactionTypeId,
    required this.name,
    required this.iconUrl,
    required this.count,
    required this.reactedByCurrentUser,
  });

  factory NoteReactionModel.fromJson(Map<String, dynamic> json) {
    return NoteReactionModel(
      reactionTypeId: json['reactionTypeId'] ?? 0,
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      count: json['count'] ?? 0,
      reactedByCurrentUser: json['reactedByCurrentUser'] ?? false,
    );
  }

  static List<NoteReactionModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteReactionModel.fromJson(json)).toList();
  }
}