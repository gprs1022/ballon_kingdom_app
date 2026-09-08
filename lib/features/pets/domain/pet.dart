import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String species;
  final String name;
  final int level;
  final int xp;
  final String emoji;
  final Color primaryColor;
  final Color accentColor;
  final String animationSet;

  const Pet({
    required this.id,
    required this.species,
    required this.name,
    this.level = 1,
    this.xp = 0,
    required this.emoji,
    required this.primaryColor,
    required this.accentColor,
    this.animationSet = 'idle',
  });

  int get maxLevel => 10;
  int get xpForNextLevel => level * 40;
  double get xpProgress => (xp / xpForNextLevel).clamp(0.0, 1.0);

  Pet copyWith({
    String? id,
    String? species,
    String? name,
    int? level,
    int? xp,
    String? emoji,
    Color? primaryColor,
    Color? accentColor,
    String? animationSet,
  }) {
    return Pet(
      id: id ?? this.id,
      species: species ?? this.species,
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      emoji: emoji ?? this.emoji,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      animationSet: animationSet ?? this.animationSet,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'species': species,
        'name': name,
        'level': level,
        'xp': xp,
        'emoji': emoji,
        'primaryColor': primaryColor.toARGB32(),
        'accentColor': accentColor.toARGB32(),
        'animationSet': animationSet,
      };

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      species: json['species'] as String,
      name: json['name'] as String? ?? json['species'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      emoji: json['emoji'] as String? ?? '🐶',
      primaryColor: Color(json['primaryColor'] as int? ?? 0xFF8D6E63),
      accentColor: Color(json['accentColor'] as int? ?? 0xFFFFD54F),
      animationSet: json['animationSet'] as String? ?? 'idle',
    );
  }

  static List<Pet> getSpeciesPresets() {
    return const [
      Pet(
        id: 'pet_puppy',
        species: 'Puppy',
        name: 'Barnaby',
        emoji: '🐶',
        primaryColor: Color(0xFF8D6E63),
        accentColor: Color(0xFFFFD54F),
      ),
      Pet(
        id: 'pet_kitten',
        species: 'Kitten',
        name: 'Mochi',
        emoji: '🐱',
        primaryColor: Color(0xFFFF8A65),
        accentColor: Color(0xFFFF80AB),
      ),
      Pet(
        id: 'pet_dragon',
        species: 'Dragon',
        name: 'Sparky',
        emoji: '🐲',
        primaryColor: Color(0xFF7C4DFF),
        accentColor: Color(0xFF00E676),
      ),
      Pet(
        id: 'pet_penguin',
        species: 'Penguin',
        name: 'Pippin',
        emoji: '🐧',
        primaryColor: Color(0xFF455A64),
        accentColor: Color(0xFF80D8FF),
      ),
      Pet(
        id: 'pet_baby_dino',
        species: 'Baby Dino',
        name: 'Rexy',
        emoji: '🦖',
        primaryColor: Color(0xFF4CAF50),
        accentColor: Color(0xFFFFEB3B),
      ),
      Pet(
        id: 'pet_unicorn',
        species: 'Unicorn',
        name: 'Stardust',
        emoji: '🦄',
        primaryColor: Color(0xFFE040FB),
        accentColor: Color(0xFF80D8FF),
      ),
      Pet(
        id: 'pet_rabbit',
        species: 'Rabbit',
        name: 'Clover',
        emoji: '🐰',
        primaryColor: Color(0xFFFF80AB),
        accentColor: Color(0xFFE1F5FE),
      ),
      Pet(
        id: 'pet_panda',
        species: 'Panda',
        name: 'Bao',
        emoji: '🐼',
        primaryColor: Color(0xFF263238),
        accentColor: Color(0xFFB0BEC5),
      ),
    ];
  }
}
