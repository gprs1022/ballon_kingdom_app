import 'package:flutter/material.dart';

class ThemeSkinPack {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final int cost;
  final List<Color> previewColors;
  final String festiveOccasion;

  const ThemeSkinPack({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.cost,
    required this.previewColors,
    required this.festiveOccasion,
  });

  static const List<ThemeSkinPack> allThemes = [
    ThemeSkinPack(
      id: 'theme_classic',
      name: 'Classic Sky',
      emoji: '🎈',
      description: 'The cheerful timeless balloon kingdom look with bright primary colors.',
      cost: 0,
      previewColors: [Color(0xFF4FC3F7), Color(0xFFFF5252)],
      festiveOccasion: 'Classic',
    ),
    ThemeSkinPack(
      id: 'theme_rainbow',
      name: 'Rainbow Sparkle',
      emoji: '🌈',
      description: 'Luminous pastel ribbons and sparkling celestial iridescence.',
      cost: 0,
      previewColors: [Color(0xFFFF80AB), Color(0xFFFFD54F), Color(0xFF80D8FF)],
      festiveOccasion: 'Magical',
    ),
    ThemeSkinPack(
      id: 'theme_halloween',
      name: 'Halloween Spooky',
      emoji: '🎃',
      description: 'Gentle pumpkin orange and candy-corn purples with soft giggly spirits.',
      cost: 50,
      previewColors: [Color(0xFFFF6D00), Color(0xFF6A1B9A)],
      festiveOccasion: 'Halloween',
    ),
    ThemeSkinPack(
      id: 'theme_christmas',
      name: 'Christmas Winter',
      emoji: '🎄',
      description: 'Festive berry reds, pine greens, and frosted golden holiday bells.',
      cost: 50,
      previewColors: [Color(0xFFD32F2F), Color(0xFF388E3C)],
      festiveOccasion: 'Christmas',
    ),
    ThemeSkinPack(
      id: 'theme_diwali',
      name: 'Diwali Festival',
      emoji: '🪔',
      description: 'Golden glowing diyas, radiant marigold orange, and celebration sparklers.',
      cost: 50,
      previewColors: [Color(0xFFFFB300), Color(0xFFFF3D00)],
      festiveOccasion: 'Diwali',
    ),
    ThemeSkinPack(
      id: 'theme_summer',
      name: 'Summer Sunshine',
      emoji: '☀️',
      description: 'Tropical aqua breezes, lemonade yellows, and seaside sunny vibes.',
      cost: 40,
      previewColors: [Color(0xFFFFEE58), Color(0xFF26C6DA)],
      festiveOccasion: 'Summer',
    ),
    ThemeSkinPack(
      id: 'theme_birthday',
      name: 'Birthday Party',
      emoji: '🎂',
      description: 'Confetti sprinkles, festive party hats, and delicious frosted cupcakes.',
      cost: 40,
      previewColors: [Color(0xFFFF4081), Color(0xFF7C4DFF)],
      festiveOccasion: 'Celebration',
    ),
    ThemeSkinPack(
      id: 'theme_jungle',
      name: 'Jungle Safari',
      emoji: '🌴',
      description: 'Vibrant tropical emerald leaves, golden tigers, and jungle melodies.',
      cost: 45,
      previewColors: [Color(0xFF2E7D32), Color(0xFFFFB300)],
      festiveOccasion: 'Safari',
    ),
    ThemeSkinPack(
      id: 'theme_ocean',
      name: 'Ocean Deep',
      emoji: '🌊',
      description: 'Deep azure waters, glowing jellyfish, and sparkling mermaid pearls.',
      cost: 45,
      previewColors: [Color(0xFF0091EA), Color(0xFF00BFA5)],
      festiveOccasion: 'Marine',
    ),
    ThemeSkinPack(
      id: 'theme_space',
      name: 'Space Galaxy',
      emoji: '🚀',
      description: 'Cosmic deep violet starfields, orbiting planets, and neon stardust.',
      cost: 50,
      previewColors: [Color(0xFF311B92), Color(0xFF00E5FF)],
      festiveOccasion: 'Cosmic',
    ),
    ThemeSkinPack(
      id: 'theme_crown',
      name: 'Royal Crown',
      emoji: '👑',
      description: 'Gleaming royal gold and regal imperial velvet fit for a balloon king/queen.',
      cost: 80,
      previewColors: [Color(0xFFFFD700), Color(0xFF800080)],
      festiveOccasion: 'Royal',
    ),
  ];
}
