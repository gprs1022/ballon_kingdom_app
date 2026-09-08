import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/learning_item.dart';

class LearningContentProvider {
  static final math.Random _random = math.Random();

  static List<LearningItem> getItemsForCategory(LearningCategory category) {
    switch (category) {
      case LearningCategory.letters:
        return _letters;
      case LearningCategory.numbers:
        return _numbers;
      case LearningCategory.shapes:
        return _shapes;
      case LearningCategory.colors:
        return _colors;
      case LearningCategory.animals:
        return _animals;
    }
  }

  static LearningItem getRandomItem(LearningCategory category) {
    final items = getItemsForCategory(category);
    return items[_random.nextInt(items.length)];
  }

  // --- 1. Letters (A to Z) with Phonics Words ---
  static final List<LearningItem> _letters = [
    const LearningItem(id: 'let_a', category: LearningCategory.letters, label: 'Apple', displaySymbol: 'A', spokenText: 'A! Apple!', color: Color(0xFFFF5252), icon: Icons.eco_rounded),
    const LearningItem(id: 'let_b', category: LearningCategory.letters, label: 'Bear', displaySymbol: 'B', spokenText: 'B! Bear!', color: Color(0xFF8D6E63), icon: Icons.pets_rounded),
    const LearningItem(id: 'let_c', category: LearningCategory.letters, label: 'Cat', displaySymbol: 'C', spokenText: 'C! Cat!', color: Color(0xFFFFB74D), icon: Icons.pets_rounded),
    const LearningItem(id: 'let_d', category: LearningCategory.letters, label: 'Duck', displaySymbol: 'D', spokenText: 'D! Duck!', color: Color(0xFFFFD54F), icon: Icons.cruelty_free_rounded),
    const LearningItem(id: 'let_e', category: LearningCategory.letters, label: 'Elephant', displaySymbol: 'E', spokenText: 'E! Elephant!', color: Color(0xFF90A4AE), icon: Icons.filter_drama_rounded),
    const LearningItem(id: 'let_f', category: LearningCategory.letters, label: 'Fish', displaySymbol: 'F', spokenText: 'F! Fish!', color: Color(0xFF4FC3F7), icon: Icons.water_drop_rounded),
    const LearningItem(id: 'let_g', category: LearningCategory.letters, label: 'Giraffe', displaySymbol: 'G', spokenText: 'G! Giraffe!', color: Color(0xFFFFB300), icon: Icons.height_rounded),
    const LearningItem(id: 'let_h', category: LearningCategory.letters, label: 'Horse', displaySymbol: 'H', spokenText: 'H! Horse!', color: Color(0xFFA1887F), icon: Icons.star_rounded),
    const LearningItem(id: 'let_i', category: LearningCategory.letters, label: 'Ice Cream', displaySymbol: 'I', spokenText: 'I! Ice cream!', color: Color(0xFFFF80AB), icon: Icons.icecream_rounded),
    const LearningItem(id: 'let_j', category: LearningCategory.letters, label: 'Juice', displaySymbol: 'J', spokenText: 'J! Juice!', color: Color(0xFFFF7043), icon: Icons.local_drink_rounded),
    const LearningItem(id: 'let_k', category: LearningCategory.letters, label: 'Kite', displaySymbol: 'K', spokenText: 'K! Kite!', color: Color(0xFF7C4DFF), icon: Icons.air_rounded),
    const LearningItem(id: 'let_l', category: LearningCategory.letters, label: 'Lion', displaySymbol: 'L', spokenText: 'L! Lion!', color: Color(0xFFFFB300), icon: Icons.emoji_nature_rounded),
    const LearningItem(id: 'let_m', category: LearningCategory.letters, label: 'Monkey', displaySymbol: 'M', spokenText: 'M! Monkey!', color: Color(0xFF8D6E63), icon: Icons.sentiment_very_satisfied_rounded),
    const LearningItem(id: 'let_n', category: LearningCategory.letters, label: 'Nest', displaySymbol: 'N', spokenText: 'N! Nest!', color: Color(0xFF795548), icon: Icons.egg_rounded),
    const LearningItem(id: 'let_o', category: LearningCategory.letters, label: 'Orange', displaySymbol: 'O', spokenText: 'O! Orange!', color: Color(0xFFFF6D00), icon: Icons.circle_rounded),
    const LearningItem(id: 'let_p', category: LearningCategory.letters, label: 'Puppy', displaySymbol: 'P', spokenText: 'P! Puppy!', color: Color(0xFF64B5F6), icon: Icons.pets_rounded),
    const LearningItem(id: 'let_q', category: LearningCategory.letters, label: 'Queen', displaySymbol: 'Q', spokenText: 'Q! Queen!', color: Color(0xFFE040FB), icon: Icons.workspace_premium_rounded),
    const LearningItem(id: 'let_r', category: LearningCategory.letters, label: 'Rainbow', displaySymbol: 'R', spokenText: 'R! Rainbow!', color: Color(0xFFFF4081), icon: Icons.looks_rounded),
    const LearningItem(id: 'let_s', category: LearningCategory.letters, label: 'Sun', displaySymbol: 'S', spokenText: 'S! Sun!', color: Color(0xFFFFD600), icon: Icons.wb_sunny_rounded),
    const LearningItem(id: 'let_t', category: LearningCategory.letters, label: 'Tiger', displaySymbol: 'T', spokenText: 'T! Tiger!', color: Color(0xFFFF6F00), icon: Icons.pets_rounded),
    const LearningItem(id: 'let_u', category: LearningCategory.letters, label: 'Umbrella', displaySymbol: 'U', spokenText: 'U! Umbrella!', color: Color(0xFF29B6F6), icon: Icons.umbrella_rounded),
    const LearningItem(id: 'let_v', category: LearningCategory.letters, label: 'Violin', displaySymbol: 'V', spokenText: 'V! Violin!', color: Color(0xFFBA68C8), icon: Icons.music_note_rounded),
    const LearningItem(id: 'let_w', category: LearningCategory.letters, label: 'Whale', displaySymbol: 'W', spokenText: 'W! Whale!', color: Color(0xFF0288D1), icon: Icons.waves_rounded),
    const LearningItem(id: 'let_x', category: LearningCategory.letters, label: 'Xylophone', displaySymbol: 'X', spokenText: 'X! Xylophone!', color: Color(0xFF00E676), icon: Icons.music_note_rounded),
    const LearningItem(id: 'let_y', category: LearningCategory.letters, label: 'Yo-Yo', displaySymbol: 'Y', spokenText: 'Y! Yo-Yo!', color: Color(0xFFFF1744), icon: Icons.toys_rounded),
    const LearningItem(id: 'let_z', category: LearningCategory.letters, label: 'Zebra', displaySymbol: 'Z', spokenText: 'Z! Zebra!', color: Color(0xFF455A64), icon: Icons.line_style_rounded),
  ];

  // --- 2. Numbers (1 to 20) ---
  static final List<LearningItem> _numbers = List.generate(20, (index) {
    final num = index + 1;
    final words = [
      'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten',
      'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen', 'Twenty'
    ];
    final colors = [
      const Color(0xFFFF3366), const Color(0xFFFF6D00), const Color(0xFFFFD600),
      const Color(0xFF00E676), const Color(0xFF00B0FF), const Color(0xFF7C4DFF),
      const Color(0xFFFF4081), const Color(0xFF1DE9B6)
    ];
    return LearningItem(
      id: 'num_$num',
      category: LearningCategory.numbers,
      label: words[index],
      displaySymbol: '$num',
      spokenText: '$num! ${words[index]}!',
      color: colors[index % colors.length],
      icon: Icons.filter_1_rounded,
    );
  });

  // --- 3. Shapes ---
  static final List<LearningItem> _shapes = [
    const LearningItem(id: 'sh_circle', category: LearningCategory.shapes, label: 'Circle', displaySymbol: '●', spokenText: 'Round Circle!', color: Color(0xFFFF5252), icon: Icons.circle),
    const LearningItem(id: 'sh_square', category: LearningCategory.shapes, label: 'Square', displaySymbol: '■', spokenText: 'Square!', color: Color(0xFF00B0FF), icon: Icons.square_rounded),
    const LearningItem(id: 'sh_triangle', category: LearningCategory.shapes, label: 'Triangle', displaySymbol: '▲', spokenText: 'Three-sided Triangle!', color: Color(0xFFFFD600), icon: Icons.change_history_rounded),
    const LearningItem(id: 'sh_star', category: LearningCategory.shapes, label: 'Star', displaySymbol: '★', spokenText: 'Shining Star!', color: Color(0xFFFFC107), icon: Icons.star_rounded),
    const LearningItem(id: 'sh_heart', category: LearningCategory.shapes, label: 'Heart', displaySymbol: '♥', spokenText: 'Lovely Heart!', color: Color(0xFFFF4081), icon: Icons.favorite_rounded),
    const LearningItem(id: 'sh_diamond', category: LearningCategory.shapes, label: 'Diamond', displaySymbol: '◆', spokenText: 'Sparkling Diamond!', color: Color(0xFF7C4DFF), icon: Icons.diamond_rounded),
    const LearningItem(id: 'sh_oval', category: LearningCategory.shapes, label: 'Oval', displaySymbol: '⬭', spokenText: 'Smooth Oval!', color: Color(0xFF00E676), icon: Icons.egg_rounded),
    const LearningItem(id: 'sh_rectangle', category: LearningCategory.shapes, label: 'Rectangle', displaySymbol: '▬', spokenText: 'Rectangle!', color: Color(0xFFFF6D00), icon: Icons.crop_landscape_rounded),
  ];

  // --- 4. Colors ---
  static final List<LearningItem> _colors = [
    const LearningItem(id: 'col_red', category: LearningCategory.colors, label: 'Red', displaySymbol: 'Red', spokenText: 'Bright Red!', color: Color(0xFFFF1744), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_blue', category: LearningCategory.colors, label: 'Blue', displaySymbol: 'Blue', spokenText: 'Ocean Blue!', color: Color(0xFF2979FF), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_yellow', category: LearningCategory.colors, label: 'Yellow', displaySymbol: 'Yellow', spokenText: 'Sunny Yellow!', color: Color(0xFFFFEA00), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_green', category: LearningCategory.colors, label: 'Green', displaySymbol: 'Green', spokenText: 'Grassy Green!', color: Color(0xFF00E676), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_orange', category: LearningCategory.colors, label: 'Orange', displaySymbol: 'Orange', spokenText: 'Juicy Orange!', color: Color(0xFFFF6D00), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_purple', category: LearningCategory.colors, label: 'Purple', displaySymbol: 'Purple', spokenText: 'Royal Purple!', color: Color(0xFF7C4DFF), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_pink', category: LearningCategory.colors, label: 'Pink', displaySymbol: 'Pink', spokenText: 'Sweet Pink!', color: Color(0xFFFF4081), icon: Icons.palette_rounded),
    const LearningItem(id: 'col_cyan', category: LearningCategory.colors, label: 'Cyan', displaySymbol: 'Cyan', spokenText: 'Sky Cyan!', color: Color(0xFF00E5FF), icon: Icons.palette_rounded),
  ];

  // --- 5. Animals ---
  static final List<LearningItem> _animals = [
    const LearningItem(id: 'an_lion', category: LearningCategory.animals, label: 'Lion', displaySymbol: '🦁', spokenText: 'Roar! Lion!', color: Color(0xFFFFB300), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_elephant', category: LearningCategory.animals, label: 'Elephant', displaySymbol: '🐘', spokenText: 'Big Elephant!', color: Color(0xFF78909C), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_puppy', category: LearningCategory.animals, label: 'Puppy', displaySymbol: '🐶', spokenText: 'Woof woof! Puppy!', color: Color(0xFF8D6E63), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_cat', category: LearningCategory.animals, label: 'Kitten', displaySymbol: '🐱', spokenText: 'Meow! Cute Kitten!', color: Color(0xFFFF8A65), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_monkey', category: LearningCategory.animals, label: 'Monkey', displaySymbol: '🐵', spokenText: 'Ooh ooh! Monkey!', color: Color(0xFFA1887F), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_frog', category: LearningCategory.animals, label: 'Frog', displaySymbol: '🐸', spokenText: 'Ribbit! Green Frog!', color: Color(0xFF66BB6A), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_panda', category: LearningCategory.animals, label: 'Panda', displaySymbol: '🐼', spokenText: 'Fluffy Panda!', color: Color(0xFF455A64), icon: Icons.pets_rounded),
    const LearningItem(id: 'an_dolphin', category: LearningCategory.animals, label: 'Dolphin', displaySymbol: '🐬', spokenText: 'Splash! Dolphin!', color: Color(0xFF29B6F6), icon: Icons.pets_rounded),
  ];
}
