import '../../features/rewards/domain/reward_service.dart';

abstract class IAPService {
  Future<bool> buyDeluxePass();
  Future<bool> restorePurchases();
}

class OfflineIAPService implements IAPService {
  final RewardService _rewardService;

  OfflineIAPService(this._rewardService);

  @override
  Future<bool> buyDeluxePass() async {
    await _rewardService.unlockPremiumDeluxe();
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    await _rewardService.unlockPremiumDeluxe();
    return true;
  }
}
