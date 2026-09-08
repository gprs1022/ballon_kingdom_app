import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../domain/house_catalog.dart';

class BalloonHouseScreen extends ConsumerStatefulWidget {
  const BalloonHouseScreen({super.key});

  @override
  ConsumerState<BalloonHouseScreen> createState() => _BalloonHouseScreenState();
}

class _BalloonHouseScreenState extends ConsumerState<BalloonHouseScreen> with SingleTickerProviderStateMixin {
  int _selectedRoomIndex = 0;
  String _selectedSlot = 'furniture';
  late AnimationController _petAnimController;

  @override
  void initState() {
    super.initState();
    _petAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _petAnimController.dispose();
    super.dispose();
  }

  void _applyDecor(DecorItem item) async {
    final currentRoom = HouseRoomInfo.rooms[_selectedRoomIndex];
    final profile = ref.read(playerProfileProvider);

    final currentSlotValue = profile.houseRooms[currentRoom.id]?[item.slot];
    if (currentSlotValue == item.id) return;

    final success = await ref.read(rewardServiceProvider).updateHouseDecor(
          currentRoom.id,
          item.slot,
          item.id,
          cost: item.cost > 0 ? item.cost : 0,
        );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins to buy this decor! 🪙'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final currentRoom = HouseRoomInfo.rooms[_selectedRoomIndex];
    final roomDecor = profile.houseRooms[currentRoom.id] ?? {};
    final activePet = profile.activePet;

    // Resolve current decor items
    final wallpaperId = roomDecor['wallpaper'] ?? 'wp_sunny';
    final flooringId = roomDecor['flooring'] ?? 'fl_wood';
    final furnitureId = roomDecor['furniture'] ?? 'fur_sofa';
    final accessoryId = roomDecor['accessory'] ?? 'acc_plant';
    final lightingId = roomDecor['lighting'] ?? 'lit_lamp';

    final wallpaperItem = HouseRoomInfo.allDecorItems.firstWhere(
      (d) => d.id == wallpaperId,
      orElse: () => HouseRoomInfo.allDecorItems.first,
    );
    final flooringItem = HouseRoomInfo.allDecorItems.firstWhere(
      (d) => d.id == flooringId,
      orElse: () => HouseRoomInfo.allDecorItems[4],
    );
    final furnitureItem = HouseRoomInfo.allDecorItems.firstWhere(
      (d) => d.id == furnitureId,
      orElse: () => HouseRoomInfo.allDecorItems[8],
    );
    final accessoryItem = HouseRoomInfo.allDecorItems.firstWhere(
      (d) => d.id == accessoryId,
      orElse: () => HouseRoomInfo.allDecorItems[13],
    );
    final lightingItem = HouseRoomInfo.allDecorItems.firstWhere(
      (d) => d.id == lightingId,
      orElse: () => HouseRoomInfo.allDecorItems[18],
    );

    final slotItems = HouseRoomInfo.allDecorItems.where((d) => d.slot == _selectedSlot).toList();

    return Scaffold(
      body: SafeArea(
        child: ResponsiveContainer(
          maxWidth: 860,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, size: 28, color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Balloon House 🏡',
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.coins}',
                            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Room Tabs
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: HouseRoomInfo.rooms.length,
                itemBuilder: (context, index) {
                  final room = HouseRoomInfo.rooms[index];
                  final isSelected = _selectedRoomIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedRoomIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withAlpha(60),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '${room.emoji} ${room.name}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Interactive Room Stage
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Wallpaper (Top 70%)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            color: wallpaperItem.previewColor,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                wallpaperItem.previewColor,
                                wallpaperItem.previewColor.withAlpha(160),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: 0.15,
                              child: Text(wallpaperItem.emoji, style: const TextStyle(fontSize: 140)),
                            ),
                          ),
                        ),
                      ),

                      // Flooring (Bottom 90px)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 90,
                        child: Container(
                          decoration: BoxDecoration(
                            color: flooringItem.previewColor,
                            border: const Border(
                              top: BorderSide(color: Colors.black26, width: 2),
                            ),
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: 0.25,
                              child: Text(flooringItem.emoji, style: const TextStyle(fontSize: 48)),
                            ),
                          ),
                        ),
                      ),

                      // Lighting fixture at top
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Column(
                            children: [
                              Container(width: 2, height: 20, color: Colors.grey[700]),
                              Text(lightingItem.emoji, style: const TextStyle(fontSize: 42)),
                            ],
                          ),
                        ),
                      ),

                      // Main Furniture (Center)
                      Positioned(
                        bottom: 50,
                        left: 30,
                        child: Column(
                          children: [
                            Text(furnitureItem.emoji, style: const TextStyle(fontSize: 70)),
                          ],
                        ),
                      ),

                      // Accessory (Right)
                      Positioned(
                        bottom: 50,
                        right: 35,
                        child: Text(accessoryItem.emoji, style: const TextStyle(fontSize: 54)),
                      ),

                      // Roaming Companion Pet
                      if (activePet != null)
                        AnimatedBuilder(
                          animation: _petAnimController,
                          builder: (context, child) {
                            final bob = 8.0 * _petAnimController.value;
                            return Positioned(
                              bottom: 60 + bob,
                              left: 130,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      'I love this room! 🥰',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activePet.emoji,
                                    style: const TextStyle(fontSize: 58),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Slot Selector Tabs (Wallpaper, Flooring, Furniture, Accessory, Lighting)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildSlotButton('furniture', '🛋️ Furniture'),
                  const SizedBox(width: 8),
                  _buildSlotButton('accessory', '🪴 Decor'),
                  const SizedBox(width: 8),
                  _buildSlotButton('wallpaper', '🖼️ Wall'),
                  const SizedBox(width: 8),
                  _buildSlotButton('flooring', '🪵 Floor'),
                  const SizedBox(width: 8),
                  _buildSlotButton('lighting', '💡 Light'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Decor Items Selection Tray
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: slotItems.length,
                  itemBuilder: (context, index) {
                    final item = slotItems[index];
                    final isEquipped = roomDecor[item.slot] == item.id;

                    return GestureDetector(
                      onTap: () => _applyDecor(item),
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isEquipped ? Colors.amber.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEquipped ? Colors.amber : Colors.grey.shade300,
                            width: isEquipped ? 2.5 : 1,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 34)),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              if (isEquipped)
                                const Text(
                                  'Equipped',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10),
                                )
                              else if (item.cost == 0)
                                const Text(
                                  'Free',
                                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10),
                                )
                              else
                                Text(
                                  '🪙 ${item.cost}',
                                  style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildSlotButton(String slot, String label) {
    final isSelected = _selectedSlot == slot;
    return GestureDetector(
      onTap: () => setState(() => _selectedSlot = slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.shade800 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
