import 'package:flutter/material.dart';

class KingdomBeat {
  final String id;
  final String title;
  final String worldName;
  final String emoji;
  final int requiredStars;
  final int coinCost;
  final String ruinDescription;
  final String restoredDescription;
  final List<Color> gradientColors;

  const KingdomBeat({
    required this.id,
    required this.title,
    required this.worldName,
    required this.emoji,
    required this.requiredStars,
    required this.coinCost,
    required this.ruinDescription,
    required this.restoredDescription,
    required this.gradientColors,
  });

  static const List<KingdomBeat> allBeats = [
    KingdomBeat(
      id: 'sky_castle',
      title: 'Grand Sky Castle',
      worldName: 'Sunny Sky',
      emoji: '🏰',
      requiredStars: 0,
      coinCost: 25,
      ruinDescription: 'The royal spires are faded and quiet. Let us bring back the cheerful morning banners!',
      restoredDescription: 'The Golden Sky Castle gleams proudly! Flags flutter in the golden morning breeze!',
      gradientColors: [Color(0xFFFFB300), Color(0xFFFF7043)],
    ),
    KingdomBeat(
      id: 'coral_palace',
      title: 'Sunken Coral Palace',
      worldName: 'Ocean Kingdom',
      emoji: '🌊',
      requiredStars: 20,
      coinCost: 45,
      ruinDescription: 'The sea currents have swept away the luminous pearl bridge to the coral kingdom.',
      restoredDescription: 'The iridescent pearl bridge shines bright beneath the ocean tides with playful dolphins!',
      gradientColors: [Color(0xFF00B0FF), Color(0xFF00E5FF)],
    ),
    KingdomBeat(
      id: 'rainbow_bridge',
      title: 'Starlight Rainbow Bridge',
      worldName: 'Space World',
      emoji: '🌉',
      requiredStars: 45,
      coinCost: 65,
      ruinDescription: 'A cosmic meteor shower dimmed the stardust bridge connecting the nebula galaxies.',
      restoredDescription: 'The Rainbow Bridge pulses with vibrant neon light across the twinkling stars!',
      gradientColors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
    ),
    KingdomBeat(
      id: 'dino_village',
      title: 'Ancient Dino Village',
      worldName: 'Dinosaur Valley',
      emoji: '🌿',
      requiredStars: 70,
      coinCost: 85,
      ruinDescription: 'Overgrown vines and moss have hidden the friendly baby dinosaur nests.',
      restoredDescription: 'The ancient valley is lush and green, filled with happy dinosaur hatchlings!',
      gradientColors: [Color(0xFF00C853), Color(0xFF64DD17)],
    ),
    KingdomBeat(
      id: 'candy_forest',
      title: 'Sugar Confectionery Forest',
      worldName: 'Candy Land',
      emoji: '🍭',
      requiredStars: 95,
      coinCost: 105,
      ruinDescription: 'The chocolate rivers froze and the giant swirl lollipops lost their sweet sparkle.',
      restoredDescription: 'Sweet sugar rivers flow with joy! Gumdrops and candy canes blossom everywhere!',
      gradientColors: [Color(0xFFFF4081), Color(0xFFFF80AB)],
    ),
    KingdomBeat(
      id: 'frost_kingdom',
      title: 'Frost Crystal Spire',
      worldName: 'Winter Wonderland',
      emoji: '❄️',
      requiredStars: 120,
      coinCost: 130,
      ruinDescription: 'The legendary frost diamond crown is waiting on top of the silent glacier.',
      restoredDescription: 'The Frost Kingdom sparkles with eternal crystal glory and magical dancing auroras!',
      gradientColors: [Color(0xFF40C4FF), Color(0xFF80D8FF)],
    ),
  ];
}
