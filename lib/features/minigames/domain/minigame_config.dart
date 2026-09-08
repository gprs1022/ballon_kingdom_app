import 'package:flutter/material.dart';

class MiniGameInfo {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<Color> gradientColors;
  final int rewardCoins;
  final int rewardXp;

  const MiniGameInfo({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.gradientColors,
    this.rewardCoins = 15,
    this.rewardXp = 30,
  });

  static const List<MiniGameInfo> allGames = [
    MiniGameInfo(
      id: 'balloon_rush',
      title: 'Balloon Rush',
      emoji: '🎈',
      description: 'Pop as many balloons as you can before time runs out!',
      gradientColors: [Color(0xFFFF5252), Color(0xFFFF7A00)],
      rewardCoins: 20,
      rewardXp: 35,
    ),
    MiniGameInfo(
      id: 'bubble_pop',
      title: 'Bubble Pop',
      emoji: '🫧',
      description: 'Pop gentle floating soap bubbles with soothing splashes!',
      gradientColors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
      rewardCoins: 15,
      rewardXp: 25,
    ),
    MiniGameInfo(
      id: 'fruit_catch',
      title: 'Fruit Catch',
      emoji: '🍎',
      description: 'Move your basket to catch sweet falling fruits!',
      gradientColors: [Color(0xFF69F0AE), Color(0xFF00C853)],
      rewardCoins: 20,
      rewardXp: 30,
    ),
    MiniGameInfo(
      id: 'memory_match',
      title: 'Memory Match',
      emoji: '🃏',
      description: 'Flip cards and find pairs of cute animal companions!',
      gradientColors: [Color(0xFFFFD54F), Color(0xFFFFB300)],
      rewardCoins: 25,
      rewardXp: 40,
    ),
    MiniGameInfo(
      id: 'shape_puzzle',
      title: 'Shape Puzzle',
      emoji: '⭐',
      description: 'Place colorful geometric shapes into their matching cutouts!',
      gradientColors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
      rewardCoins: 20,
      rewardXp: 35,
    ),
    MiniGameInfo(
      id: 'color_sort',
      title: 'Color Sort',
      emoji: '🎨',
      description: 'Sort colorful balloons into their matching colored baskets!',
      gradientColors: [Color(0xFFFF4081), Color(0xFFF50057)],
      rewardCoins: 20,
      rewardXp: 30,
    ),
    MiniGameInfo(
      id: 'balloon_maze',
      title: 'Balloon Maze',
      emoji: '🌀',
      description: 'Guide your balloon safely across breezes to the star goal!',
      gradientColors: [Color(0xFF40C4FF), Color(0xFF536DFE)],
      rewardCoins: 25,
      rewardXp: 40,
    ),
    MiniGameInfo(
      id: 'animal_match',
      title: 'Animal Match',
      emoji: '🦁',
      description: 'Listen to animal sounds and tap the matching animal!',
      gradientColors: [Color(0xFFFFAB40), Color(0xFFFF6D00)],
      rewardCoins: 20,
      rewardXp: 30,
    ),
  ];
}
