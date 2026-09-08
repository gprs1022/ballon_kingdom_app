class Sticker {
  final String id;
  final String category;
  final bool unlocked;

  const Sticker({
    required this.id,
    required this.category,
    this.unlocked = false,
  });

  Sticker copyWith({
    String? id,
    String? category,
    bool? unlocked,
  }) {
    return Sticker(
      id: id ?? this.id,
      category: category ?? this.category,
      unlocked: unlocked ?? this.unlocked,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'unlocked': unlocked,
      };

  factory Sticker.fromJson(Map<String, dynamic> json) {
    return Sticker(
      id: json['id'] as String,
      category: json['category'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
    );
  }
}
