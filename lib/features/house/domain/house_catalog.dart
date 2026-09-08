import 'package:flutter/material.dart';

class DecorItem {
  final String id;
  final String name;
  final String emoji;
  final String slot; // 'wallpaper', 'flooring', 'furniture', 'accessory', 'lighting'
  final int cost;
  final Color previewColor;

  const DecorItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.slot,
    this.cost = 0,
    required this.previewColor,
  });
}

class HouseRoomInfo {
  final String id;
  final String name;
  final String emoji;
  final Color baseColor;

  const HouseRoomInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.baseColor,
  });

  static const List<HouseRoomInfo> rooms = [
    HouseRoomInfo(id: 'living_room', name: 'Living Room', emoji: '🛋️', baseColor: Color(0xFFFFF3E0)),
    HouseRoomInfo(id: 'bed_room', name: 'Bedroom', emoji: '🛏️', baseColor: Color(0xFFE8EAF6)),
    HouseRoomInfo(id: 'kitchen', name: 'Kitchen', emoji: '🍳', baseColor: Color(0xFFE0F2F1)),
    HouseRoomInfo(id: 'play_room', name: 'Playroom', emoji: '🎨', baseColor: Color(0xFFFCE4EC)),
    HouseRoomInfo(id: 'garden_patio', name: 'Garden Patio', emoji: '🌸', baseColor: Color(0xFFE8F5E9)),
  ];

  static const List<DecorItem> allDecorItems = [
    // Wallpapers
    DecorItem(id: 'wp_sunny', name: 'Sunny Sky', emoji: '☀️', slot: 'wallpaper', cost: 0, previewColor: Color(0xFFFFF9C4)),
    DecorItem(id: 'wp_clouds', name: 'Fluffy Clouds', emoji: '☁️', slot: 'wallpaper', cost: 15, previewColor: Color(0xFFBBDEFB)),
    DecorItem(id: 'wp_rainbow', name: 'Rainbow Swirl', emoji: '🌈', slot: 'wallpaper', cost: 25, previewColor: Color(0xFFFFCDD2)),
    DecorItem(id: 'wp_stars', name: 'Starlight Night', emoji: '✨', slot: 'wallpaper', cost: 35, previewColor: Color(0xFFD1C4E9)),

    // Floorings
    DecorItem(id: 'fl_wood', name: 'Oak Parquet', emoji: '🪵', slot: 'flooring', cost: 0, previewColor: Color(0xFFD7CCC8)),
    DecorItem(id: 'fl_carpet_blue', name: 'Cozy Blue Rug', emoji: '🟦', slot: 'flooring', cost: 15, previewColor: Color(0xFF90CAF9)),
    DecorItem(id: 'fl_puzzle', name: 'Puzzle Tiles', emoji: '🧩', slot: 'flooring', cost: 25, previewColor: Color(0xFFA5D6A7)),
    DecorItem(id: 'fl_grass', name: 'Lawn Grass', emoji: '🌱', slot: 'flooring', cost: 30, previewColor: Color(0xFF81C784)),

    // Furniture
    DecorItem(id: 'fur_sofa', name: 'Plush Sofa', emoji: '🛋️', slot: 'furniture', cost: 0, previewColor: Colors.orangeAccent),
    DecorItem(id: 'fur_bed', name: 'Cloud Bed', emoji: '🛏️', slot: 'furniture', cost: 20, previewColor: Colors.purpleAccent),
    DecorItem(id: 'fur_table', name: 'Tea Table', emoji: '☕', slot: 'furniture', cost: 20, previewColor: Colors.brown),
    DecorItem(id: 'fur_toybox', name: 'Toy Chest', emoji: '🧸', slot: 'furniture', cost: 30, previewColor: Colors.amber),
    DecorItem(id: 'fur_bench', name: 'Garden Bench', emoji: '🪵', slot: 'furniture', cost: 25, previewColor: Colors.teal),

    // Accessories
    DecorItem(id: 'acc_plant', name: 'Fiddle Plant', emoji: '🪴', slot: 'accessory', cost: 0, previewColor: Colors.green),
    DecorItem(id: 'acc_bear', name: 'Teddy Bear', emoji: '🧸', slot: 'accessory', cost: 15, previewColor: Colors.brown),
    DecorItem(id: 'acc_fruit', name: 'Fruit Bowl', emoji: '🍉', slot: 'accessory', cost: 15, previewColor: Colors.red),
    DecorItem(id: 'acc_train', name: 'Mini Train', emoji: '🚂', slot: 'accessory', cost: 25, previewColor: Colors.blue),
    DecorItem(id: 'acc_fountain', name: 'Water Fountain', emoji: '⛲', slot: 'accessory', cost: 40, previewColor: Colors.cyan),

    // Lighting
    DecorItem(id: 'lit_lamp', name: 'Desk Lamp', emoji: '💡', slot: 'lighting', cost: 0, previewColor: Colors.amber),
    DecorItem(id: 'lit_star', name: 'Star Chandelier', emoji: '⭐', slot: 'lighting', cost: 20, previewColor: Colors.yellow),
    DecorItem(id: 'lit_balloons', name: 'Balloon Lights', emoji: '🎈', slot: 'lighting', cost: 25, previewColor: Colors.pinkAccent),
    DecorItem(id: 'lit_lanterns', name: 'Garden Lantern', emoji: '🏮', slot: 'lighting', cost: 30, previewColor: Colors.deepOrange),
  ];
}
