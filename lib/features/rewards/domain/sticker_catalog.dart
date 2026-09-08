class StickerData {
  final String id;
  final String category;
  final String title;
  final String emoji;
  final String unlockRequirement;

  const StickerData({
    required this.id,
    required this.category,
    required this.title,
    required this.emoji,
    required this.unlockRequirement,
  });
}

class StickerCatalog {
  static const List<String> categories = [
    'Sky',
    'Animals',
    'Kingdom',
    'Ocean',
    'Space',
    'Dinosaurs',
    'Sweets',
    'Magic',
  ];

  static final List<StickerData> allStickers = [
    // 1. Sky
    const StickerData(id: 'stk_sun', category: 'Sky', title: 'Golden Sun', emoji: '☀️', unlockRequirement: 'Clear Level 1'),
    const StickerData(id: 'stk_cloud', category: 'Sky', title: 'Happy Cloud', emoji: '☁️', unlockRequirement: 'Pop 50 Balloons'),
    const StickerData(id: 'stk_rainbow', category: 'Sky', title: 'Twin Rainbow', emoji: '🌈', unlockRequirement: 'Pop 5 Rainbow Balloons'),
    const StickerData(id: 'stk_lightning', category: 'Sky', title: 'Gentle Spark', emoji: '⚡', unlockRequirement: 'Reach Level 3'),

    // 2. Animals
    const StickerData(id: 'stk_puppy', category: 'Animals', title: 'Playful Pup', emoji: '🐶', unlockRequirement: 'Hatch your 1st pet'),
    const StickerData(id: 'stk_kitten', category: 'Animals', title: 'Calico Cat', emoji: '🐱', unlockRequirement: 'Feed pet 3 times'),
    const StickerData(id: 'stk_bunny', category: 'Animals', title: 'Bouncing Bunny', emoji: '🐰', unlockRequirement: 'Clear 5 Levels'),
    const StickerData(id: 'stk_panda', category: 'Animals', title: 'Bamboo Panda', emoji: '🐼', unlockRequirement: 'Collect 100 Coins'),

    // 3. Kingdom
    const StickerData(id: 'stk_crown', category: 'Kingdom', title: 'Royal Crown', emoji: '👑', unlockRequirement: 'Earn 10 Stars'),
    const StickerData(id: 'stk_castle', category: 'Kingdom', title: 'Sky Castle', emoji: '🏰', unlockRequirement: 'Clear Level 10'),
    const StickerData(id: 'stk_shield', category: 'Kingdom', title: 'Hero Crest', emoji: '🛡️', unlockRequirement: 'Survive 3 Challenge Missions'),
    const StickerData(id: 'stk_flag', category: 'Kingdom', title: 'Victory Flag', emoji: '🚩', unlockRequirement: 'Clear Level 5'),

    // 4. Ocean
    const StickerData(id: 'stk_dolphin', category: 'Ocean', title: 'Sunny Dolphin', emoji: '🐬', unlockRequirement: 'Pop 100 Balloons'),
    const StickerData(id: 'stk_turtle', category: 'Ocean', title: 'Sea Turtle', emoji: '🐢', unlockRequirement: 'Earn a Gold Medal'),
    const StickerData(id: 'stk_whale', category: 'Ocean', title: 'Blue Whale', emoji: '🐳', unlockRequirement: 'Unlock 15 Levels'),
    const StickerData(id: 'stk_shell', category: 'Ocean', title: 'Pearl Shell', emoji: '🐚', unlockRequirement: 'Collect 250 Coins'),

    // 5. Space
    const StickerData(id: 'stk_rocket', category: 'Space', title: 'Star Rocket', emoji: '🚀', unlockRequirement: 'Pop 5 Rocket Balloons'),
    const StickerData(id: 'stk_planet', category: 'Space', title: 'Ring Planet', emoji: '🪐', unlockRequirement: 'Clear Level 15'),
    const StickerData(id: 'stk_star', category: 'Space', title: 'Twinkle Star', emoji: '⭐', unlockRequirement: 'Earn 30 Stars'),
    const StickerData(id: 'stk_ufo', category: 'Space', title: 'Friendly Saucer', emoji: '🛸', unlockRequirement: 'Clear 3 Challenge Missions'),

    // 6. Dinosaurs
    const StickerData(id: 'stk_rex', category: 'Dinosaurs', title: 'Baby Rex', emoji: '🦖', unlockRequirement: 'Hatch Dino Egg'),
    const StickerData(id: 'stk_bronto', category: 'Dinosaurs', title: 'Gentle Giant', emoji: '🦕', unlockRequirement: 'Level pet to Level 3'),
    const StickerData(id: 'stk_fossil', category: 'Dinosaurs', title: 'Fossil Footprint', emoji: '🐾', unlockRequirement: 'Pop 200 Balloons'),
    const StickerData(id: 'stk_dino_egg', category: 'Dinosaurs', title: 'Spotted Egg', emoji: '🥚', unlockRequirement: 'Collect 15 Stars'),

    // 7. Sweets
    const StickerData(id: 'stk_lollipop', category: 'Sweets', title: 'Swirl Pop', emoji: '🍭', unlockRequirement: 'Pop 10 Golden Balloons'),
    const StickerData(id: 'stk_cupcake', category: 'Sweets', title: 'Berry Cupcake', emoji: '🧁', unlockRequirement: 'Feed pet 5 times'),
    const StickerData(id: 'stk_icecream', category: 'Sweets', title: 'Rainbow Sundae', emoji: '🍦', unlockRequirement: 'Earn 20 Stars'),
    const StickerData(id: 'stk_donut', category: 'Sweets', title: 'Glazed Donut', emoji: '🍩', unlockRequirement: 'Collect 300 Coins'),

    // 8. Magic
    const StickerData(id: 'stk_wand', category: 'Magic', title: 'Sparkle Wand', emoji: '🪄', unlockRequirement: 'Pop 5 Magic Balloons'),
    const StickerData(id: 'stk_crystal', category: 'Magic', title: 'Mystic Gem', emoji: '💎', unlockRequirement: 'Clear all 20 Sunny Sky Levels'),
    const StickerData(id: 'stk_sparkles', category: 'Magic', title: 'Stardust', emoji: '✨', unlockRequirement: 'Earn 50 Stars'),
    const StickerData(id: 'stk_potion', category: 'Magic', title: 'Joy Elixir', emoji: '🧪', unlockRequirement: 'Level pet to Level 5'),
  ];

  static List<StickerData> getStickersForCategory(String category) {
    return allStickers.where((s) => s.category == category).toList();
  }
}
