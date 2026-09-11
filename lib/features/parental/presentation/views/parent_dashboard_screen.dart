import '../../../../core/monetization/ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/utils/apk_download_helper.dart';
import '../../../../core/utils/responsive_layout.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset All Progress? ⚠️'),
        content: const Text(
          'This will reset all stars, coins, unlocked levels, pets, and stickers back to the initial state. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(rewardServiceProvider).resetProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All progress has been reset.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Reset Everything',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFF00897B), size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Privacy Policy & Safety',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Balloon Kingdom is committed to protecting children\'s privacy. We strictly comply with COPPA (Children\'s Online Privacy Protection Act), GDPR-K, and Google Play Families Policies.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 14),
              Text(
                '🛡️ Zero Personal Data Collection',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF004D40)),
              ),
              SizedBox(height: 4),
              Text(
                'We do not collect names, email addresses, phone numbers, contact lists, device hardware identifiers, or location data. All game progress, high scores, coins, and educational settings remain strictly stored on your local device.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(height: 14),
              Text(
                '🧸 Child-Safe Advertising (G-Rated)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF004D40)),
              ),
              SizedBox(height: 4),
              Text(
                'Advertisements are strictly filtered for General Audiences (G-rating) with COPPA child-directed treatment enabled. Advertising ID (AD_ID) tracking is completely removed.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              SizedBox(height: 14),
              Text(
                '🔒 Parental Gate Protected',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF004D40)),
              ),
              SizedBox(height: 4),
              Text(
                'All adult settings, analytics, coin upgrades, and privacy options are secured behind a parental multiplication/addition math gate to prevent unintended child access.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _upgradeWithCoins(BuildContext context, WidgetRef ref) async {
    final profile = ref.read(playerProfileProvider);
    const requiredCoins = 10000;

    if (profile.coins < requiredCoins) {
      final needed = requiredCoins - profile.coins;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text('🪙 Not Enough Coins! 🎈'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have ${profile.coins} 🪙 coins.\nYou need 10,000 🪙 coins to unlock Deluxe.',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pop balloons, beat levels, and play mini-games to collect $needed more coins! 🌟',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.brown.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Keep Playing! 🎈', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Upgrade with 10,000 Coins? 👑'),
        content: const Text(
          'Spend 10,000 coins to unlock Balloon Kingdom Deluxe forever?\n\n'
          '✨ All seasonal themes unlocked\n'
          '👑 Special Crown theme equipped\n'
          '🌟 Permanent Deluxe status',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Confirm Upgrade 🚀',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(rewardServiceProvider)
        .unlockDeluxeWithCoins(coinCost: requiredCoins);

    if (success && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🎉 Deluxe Pass Activated! 👑'),
          content: const Text(
            'Congratulations! You have upgraded to Balloon Kingdom Deluxe for 10,000 coins.\n\n'
            'All seasonal themes and Deluxe perks are permanently unlocked! ✨',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Awesome! 🌟', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }


  void _restorePurchases(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(iapServiceProvider).restorePurchases();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchases successfully restored! ✨'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveContainer(
            maxWidth: 740,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 28,
                          color: AppColors.textDark,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parent Dashboard 🛡️',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Learning analytics & parental controls',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Dashboard Scrollable Body
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      // 1. Learning Progress Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '📊',
                                  style: TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Learning Progress & Playtime',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _buildMetricTile(
                                  '🔤 Letters',
                                  '26 / 26',
                                  Colors.blue.shade50,
                                  Colors.blue.shade900,
                                ),
                                const SizedBox(width: 10),
                                _buildMetricTile(
                                  '🔢 Numbers',
                                  '20 / 20',
                                  Colors.green.shade50,
                                  Colors.green.shade900,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildMetricTile(
                                  '⏱️ Play Time',
                                  '${profile.playTimeMinutes} mins',
                                  Colors.purple.shade50,
                                  Colors.purple.shade900,
                                ),
                                const SizedBox(width: 10),
                                _buildMetricTile(
                                  '🎈 Balloons',
                                  '${profile.totalBalloonsPopped}',
                                  Colors.orange.shade50,
                                  Colors.orange.shade900,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildMetricTile(
                                  '⭐ Total Stars',
                                  '${profile.stars}',
                                  Colors.amber.shade50,
                                  Colors.amber.shade900,
                                ),
                                const SizedBox(width: 10),
                                _buildMetricTile(
                                  '🐾 Pets & Stickers',
                                  '${profile.pets.length} / 8 Pets',
                                  Colors.teal.shade50,
                                  Colors.teal.shade900,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. Parental Controls & Screen Time Limit Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('⏰', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Daily Screen Time Limit',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Select how long your child can play before a friendly rest prompt appears:',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [0, 15, 30, 45, 60].map((mins) {
                                final isSelected =
                                    profile.screenTimeLimitMinutes == mins;
                                return ChoiceChip(
                                  label: Text(
                                    mins == 0 ? 'No Limit' : '$mins mins',
                                  ),
                                  selected: isSelected,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSelected: (_) {
                                    ref
                                        .read(rewardServiceProvider)
                                        .updateParentalSettings(
                                          screenTimeLimitMinutes: mins,
                                        );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3. Accessibility Controls Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('♿', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Accessibility & Audio Options',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'High Contrast Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: const Text(
                                'Enhances balloon outlines & visual text contrast',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: profile.isHighContrastMode,
                              onChanged: (val) {
                                ref
                                    .read(rewardServiceProvider)
                                    .updateParentalSettings(
                                      isHighContrastMode: val,
                                    );
                              },
                            ),
                            const Divider(),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Colorblind-Safe Balloon Palette',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: const Text(
                                'Adjusts balloon colors for high distinguishability',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: profile.isColorblindSafeMode,
                              onChanged: (val) {
                                ref
                                    .read(rewardServiceProvider)
                                    .updateParentalSettings(
                                      isColorblindSafeMode: val,
                                    );
                              },
                            ),
                            const Divider(),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Phonics & Voice Narration',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: const Text(
                                'Pronounces letters, numbers, and colors on pop',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: profile.isVoiceNarrationEnabled,
                              onChanged: (val) {
                                ref
                                    .read(rewardServiceProvider)
                                    .updateParentalSettings(
                                      isVoiceNarrationEnabled: val,
                                    );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Deluxe Pass & Purchases Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.amber.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '👑',
                                  style: TextStyle(fontSize: 26),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Balloon Kingdom Deluxe',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber.shade400,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🪙 ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${profile.coins}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: Colors.amber.shade900,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Upgrade with 10,000 coins: Unlocks all seasonal theme packs forever, grants special Crown theme, and permanent Deluxe status.',
                              style: TextStyle(fontSize: 13, height: 1.3),
                            ),
                            const SizedBox(height: 14),
                            if (profile.isPremiumUnlocked)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Deluxe Pass Active ✨',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _upgradeWithCoins(context, ref),
                                  icon: const Text(
                                    '🪙',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  label: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Upgrade with 10,000 Coins 👑',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber.shade800,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      _restorePurchases(context, ref),
                                  child: Text(
                                    'Restore Previous Unlock ✨',
                                    style: TextStyle(
                                      color: Colors.amber.shade900,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // 5. Android APK Download Card (Web Only)
                      if (kIsWeb) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFA5D6A7),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.android_rounded,
                                    color: Color(0xFF2E7D32),
                                    size: 26,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Download Android App (APK)',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1B5E20),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Install the latest official release build directly on your child\'s Android tablet or phone for offline play and smoother touch response.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.download_rounded,
                                        color: Colors.white,
                                      ),
                                      label: const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Download Release APK (51.3 MB)',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF2E7D32,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 16,
                                        ),
                                      ),
                                      onPressed: () {
                                        ApkDownloadHelper.downloadReleaseApk();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              '📥 Downloading Balloon Kingdom Release APK... 🚀',
                                            ),
                                            duration: Duration(seconds: 3),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // 6. Family Safety & Privacy Policy Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.teal.shade200,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_rounded,
                                  color: Color(0xFF00897B),
                                  size: 26,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Family Safety & Privacy',
                                    style: AppTextStyles.headingSmall.copyWith(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF004D40),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Balloon Kingdom is certified for kids and families under Google Play & COPPA standards. We never collect personal data.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.policy_outlined,
                                      size: 18,
                                      color: Color(0xFF00897B),
                                    ),
                                    label: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF00897B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.teal.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showPrivacyPolicyDialog(context),
                                  ),
                                ),
                                if (AdMobUnitIds.supported) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.privacy_tip_outlined,
                                        size: 18,
                                        color: Colors.blueGrey,
                                      ),
                                      label: const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Ad Privacy (EEA)',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.blueGrey.shade200,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 8,
                                        ),
                                      ),
                                      onPressed: () => AdMobService.instance
                                          .showPrivacyOptions(context),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 7. Data Reset Section
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _confirmReset(context, ref),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'Reset All Progress Data',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    String title,
    String value,
    Color bg,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdTestingCard extends ConsumerStatefulWidget {
  const _AdTestingCard();

  @override
  ConsumerState<_AdTestingCard> createState() => _AdTestingCardState();
}

class _AdTestingCardState extends ConsumerState<_AdTestingCard> {
  String _status = '';
  bool _loading = false;

  void _setStatus(String msg) {
    if (mounted) setState(() => _status = msg);
  }

  @override
  Widget build(BuildContext context) {
    final adService = ref.watch(adServiceProvider);
    final isReady = AdMobService.instance.ready.value;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF90CAF9), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🧪', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AdMob Ads Testing Suite',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0D47A1),
                      ),
                    ),
                    Text(
                      AdMobUnitIds.useTestAds
                          ? '✅ Google Test Ad Units Active'
                          : '⚠️ Live Ads Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdMobUnitIds.useTestAds
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isReady ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isReady ? Colors.green : Colors.amber,
                  ),
                ),
                child: Text(
                  isReady ? 'Ready' : 'Initializing...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isReady ? Colors.green.shade800 : Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Test all 4 Google AdMob formats instantly with official sample IDs:',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 14),

          // 1. Live Banner Ad Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Text(
                  '📌 Banner Ad (Test Unit)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Center(child: adService.getBannerAdWidget()),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 2. Action Buttons for Interstitial, Rewarded, and App Open
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Interstitial Test
              ElevatedButton.icon(
                icon: const Icon(Icons.fullscreen_rounded, size: 18),
                label: const Text('Test Interstitial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        _setStatus('Loading Interstitial Ad...');
                        final shown = await adService.showInterstitialAd(
                          context,
                          placement: 'next_level',
                        );
                        _setStatus(shown
                            ? '✅ Interstitial Ad completed'
                            : '❌ Interstitial unavailable');
                        if (mounted) setState(() => _loading = false);
                      },
              ),

              // Rewarded Video Test
              ElevatedButton.icon(
                icon: const Icon(Icons.videocam_rounded, size: 18),
                label: const Text('Test Rewarded'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        _setStatus('Loading Rewarded Video Ad...');
                        var rewarded = false;
                        final shown = await adService.showRewardedVideo(
                          context,
                          placement: 'home_screen_gift',
                          onReward: () {
                            rewarded = true;
                            ref
                                .read(playerProfileProvider.notifier)
                                .addRewards(coins: 25);
                          },
                        );
                        _setStatus(shown
                            ? (rewarded
                                ? '🎉 Rewarded Ad watched & 25 coins granted!'
                                : 'Rewarded Ad closed')
                            : '❌ Rewarded Ad unavailable');
                        if (mounted) setState(() => _loading = false);
                      },
              ),

              // App Open Test
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Test App Open Ad'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        _setStatus('Loading App Open Ad...');
                        final shown =
                            await adService.loadAndShowAppOpenAd(context);
                        _setStatus(shown
                            ? '✅ App Open Ad displayed'
                            : '❌ App Open Ad unavailable');
                        if (mounted) setState(() => _loading = false);
                      },
              ),
            ],
          ),

          if (_status.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF283593),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
