import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../audio/sound_manager.dart';
import '../monetization/ad_service.dart';
import '../monetization/iap_service.dart';
import '../storage/storage_service.dart';
import '../../features/rewards/domain/player_profile.dart';
import '../../features/rewards/domain/reward_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final soundManagerProvider = Provider<SoundManager>((ref) {
  return SoundManager.instance;
});

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PlayerProfileNotifier(storage);
});

final rewardServiceProvider = Provider<RewardService>((ref) {
  final profileNotifier = ref.watch(playerProfileProvider.notifier);
  return RewardService(profileNotifier);
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdMobService.instance;
});

final iapServiceProvider = Provider<IAPService>((ref) {
  final rewardService = ref.watch(rewardServiceProvider);
  return OfflineIAPService(rewardService);
});
