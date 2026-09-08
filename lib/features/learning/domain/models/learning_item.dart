import 'package:flutter/material.dart';

enum LearningCategory {
  letters,
  numbers,
  shapes,
  colors,
  animals,
}

extension LearningCategoryExtension on LearningCategory {
  String get displayName {
    switch (this) {
      case LearningCategory.letters:
        return 'ABC Letters';
      case LearningCategory.numbers:
        return '123 Numbers';
      case LearningCategory.shapes:
        return 'Fun Shapes';
      case LearningCategory.colors:
        return 'Bright Colors';
      case LearningCategory.animals:
        return 'Cute Animals';
    }
  }

  IconData get icon {
    switch (this) {
      case LearningCategory.letters:
        return Icons.text_fields_rounded;
      case LearningCategory.numbers:
        return Icons.pin_rounded;
      case LearningCategory.shapes:
        return Icons.category_rounded;
      case LearningCategory.colors:
        return Icons.palette_rounded;
      case LearningCategory.animals:
        return Icons.pets_rounded;
    }
  }

  Color get primaryColor {
    switch (this) {
      case LearningCategory.letters:
        return const Color(0xFFFF5252);
      case LearningCategory.numbers:
        return const Color(0xFF00B0FF);
      case LearningCategory.shapes:
        return const Color(0xFFFFB300);
      case LearningCategory.colors:
        return const Color(0xFFE040FB);
      case LearningCategory.animals:
        return const Color(0xFF00E676);
    }
  }
}

class LearningItem {
  final String id;
  final LearningCategory category;
  final String label;
  final String displaySymbol;
  final String spokenText;
  final Color color;
  final IconData? icon;

  const LearningItem({
    required this.id,
    required this.category,
    required this.label,
    required this.displaySymbol,
    required this.spokenText,
    required this.color,
    this.icon,
  });
}
